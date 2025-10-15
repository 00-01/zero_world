"""
AI Concierge - Conversation State Machine

Manages multi-step conversations for service delivery.
Tracks user intent, collects required information, and orchestrates service fulfillment.
"""

from enum import Enum
from typing import Dict, List, Optional, Any
from datetime import datetime, timedelta
from pydantic import BaseModel, Field
import uuid


class ConversationStage(str, Enum):
    """Stages in the conversation flow"""
    INTENT_RECOGNITION = "intent_recognition"
    CATEGORY_SELECTION = "category_selection"
    ITEM_SELECTION = "item_selection"
    CUSTOMIZATION = "customization"
    DELIVERY_DETAILS = "delivery_details"
    PAYMENT_SETUP = "payment_setup"
    CONFIRMATION = "confirmation"
    TRACKING = "tracking"
    COMPLETED = "completed"
    CANCELLED = "cancelled"


class ServiceType(str, Enum):
    """Available service types"""
    FOOD_DELIVERY = "food_delivery"
    RIDE_HAILING = "ride_hailing"
    GROCERY_DELIVERY = "grocery_delivery"
    HOME_SERVICE = "home_service"
    SHOPPING = "shopping"
    HEALTHCARE = "healthcare"
    ENTERTAINMENT = "entertainment"


class OrderStatus(str, Enum):
    """Order tracking statuses"""
    PLACED = "placed"
    CONFIRMED = "confirmed"
    PREPARING = "preparing"
    READY = "ready"
    PICKED_UP = "picked_up"
    IN_TRANSIT = "in_transit"
    NEARBY = "nearby"
    ARRIVED = "arrived"
    DELIVERED = "delivered"
    COMPLETED = "completed"
    CANCELLED = "cancelled"


class Intent(BaseModel):
    """Recognized user intent"""
    intent_type: str
    service_type: Optional[ServiceType] = None
    confidence: float
    entities: Dict[str, Any] = Field(default_factory=dict)
    timestamp: datetime = Field(default_factory=datetime.utcnow)


class ConversationState(BaseModel):
    """
    Tracks the state of an ongoing conversation
    
    This is the core state machine that manages the entire user journey
    from initial intent to final delivery.
    """
    # Identifiers
    conversation_id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    user_id: str
    session_id: str
    
    # Service details
    service_type: Optional[ServiceType] = None
    provider: Optional[str] = None  # e.g., "ubereats", "doordash"
    
    # State tracking
    stage: ConversationStage = ConversationStage.INTENT_RECOGNITION
    intent: Optional[Intent] = None
    
    # Collected data throughout conversation
    collected_data: Dict[str, Any] = Field(default_factory=dict)
    
    # Questions that still need answers
    pending_questions: List[str] = Field(default_factory=list)
    
    # Order tracking
    order_id: Optional[str] = None
    order_status: Optional[OrderStatus] = None
    
    # Timing
    created_at: datetime = Field(default_factory=datetime.utcnow)
    last_update: datetime = Field(default_factory=datetime.utcnow)
    expires_at: datetime = Field(
        default_factory=lambda: datetime.utcnow() + timedelta(hours=24)
    )
    completed_at: Optional[datetime] = None
    
    # Context for AI
    context: Dict[str, Any] = Field(default_factory=dict)
    
    # History for debugging and analytics
    history: List[Dict[str, Any]] = Field(default_factory=list)
    
    class Config:
        use_enum_values = True
    
    def add_history(self, event_type: str, data: Dict[str, Any]):
        """Add event to history"""
        self.history.append({
            "timestamp": datetime.utcnow().isoformat(),
            "event": event_type,
            "stage": self.stage,
            "data": data
        })
        self.last_update = datetime.utcnow()
    
    def update_stage(self, new_stage: ConversationStage):
        """Move to next stage"""
        old_stage = self.stage
        self.stage = new_stage
        self.add_history("stage_change", {
            "from": old_stage,
            "to": new_stage
        })
    
    def collect_data(self, key: str, value: Any):
        """Store collected information"""
        self.collected_data[key] = value
        self.add_history("data_collected", {
            "key": key,
            "value": value
        })
        self.last_update = datetime.utcnow()
    
    def is_expired(self) -> bool:
        """Check if conversation has expired"""
        return datetime.utcnow() > self.expires_at
    
    def get_progress_percentage(self) -> int:
        """Calculate conversation completion percentage"""
        stage_order = [
            ConversationStage.INTENT_RECOGNITION,
            ConversationStage.CATEGORY_SELECTION,
            ConversationStage.ITEM_SELECTION,
            ConversationStage.CUSTOMIZATION,
            ConversationStage.DELIVERY_DETAILS,
            ConversationStage.PAYMENT_SETUP,
            ConversationStage.CONFIRMATION,
            ConversationStage.TRACKING,
            ConversationStage.COMPLETED
        ]
        
        try:
            current_index = stage_order.index(self.stage)
            return int((current_index / len(stage_order)) * 100)
        except ValueError:
            return 0


class ConversationStateMachine:
    """
    Manages conversation state transitions and data collection
    """
    
    def __init__(self):
        # Define required data for each service type at each stage
        self.required_data = {
            ServiceType.FOOD_DELIVERY: {
                ConversationStage.ITEM_SELECTION: ["restaurant_id", "items"],
                ConversationStage.CUSTOMIZATION: ["customizations"],
                ConversationStage.DELIVERY_DETAILS: ["delivery_address", "delivery_time"],
                ConversationStage.PAYMENT_SETUP: ["payment_method_id"],
            },
            ServiceType.RIDE_HAILING: {
                ConversationStage.ITEM_SELECTION: ["pickup_location", "destination"],
                ConversationStage.CUSTOMIZATION: ["vehicle_type"],
                ConversationStage.DELIVERY_DETAILS: ["pickup_time"],
                ConversationStage.PAYMENT_SETUP: ["payment_method_id"],
            }
        }
    
    def can_advance_stage(
        self, 
        state: ConversationState, 
        next_stage: ConversationStage
    ) -> tuple[bool, List[str]]:
        """
        Check if conversation can advance to next stage
        
        Returns:
            (can_advance, missing_data)
        """
        if state.service_type is None:
            return False, ["service_type"]
        
        current_stage = state.stage
        required = self.required_data.get(state.service_type, {}).get(current_stage, [])
        
        missing = [
            field for field in required 
            if field not in state.collected_data or state.collected_data[field] is None
        ]
        
        return len(missing) == 0, missing
    
    def advance_stage(self, state: ConversationState) -> ConversationState:
        """
        Automatically advance to next appropriate stage
        """
        can_advance, missing = self.can_advance_stage(state, state.stage)
        
        if not can_advance:
            # Store what's missing
            state.pending_questions = [
                self._generate_question(field) for field in missing
            ]
            return state
        
        # Clear pending questions
        state.pending_questions = []
        
        # Determine next stage
        stage_flow = {
            ConversationStage.INTENT_RECOGNITION: ConversationStage.CATEGORY_SELECTION,
            ConversationStage.CATEGORY_SELECTION: ConversationStage.ITEM_SELECTION,
            ConversationStage.ITEM_SELECTION: ConversationStage.CUSTOMIZATION,
            ConversationStage.CUSTOMIZATION: ConversationStage.DELIVERY_DETAILS,
            ConversationStage.DELIVERY_DETAILS: ConversationStage.PAYMENT_SETUP,
            ConversationStage.PAYMENT_SETUP: ConversationStage.CONFIRMATION,
            ConversationStage.CONFIRMATION: ConversationStage.TRACKING,
            ConversationStage.TRACKING: ConversationStage.COMPLETED,
        }
        
        next_stage = stage_flow.get(state.stage)
        if next_stage:
            state.update_stage(next_stage)
        
        return state
    
    def _generate_question(self, field: str) -> str:
        """Generate natural language question for missing data"""
        questions = {
            "restaurant_id": "Which restaurant would you like to order from?",
            "items": "What would you like to order?",
            "customizations": "Any special instructions or modifications?",
            "delivery_address": "Where should we deliver this?",
            "delivery_time": "When would you like it delivered?",
            "pickup_location": "Where should we pick you up?",
            "destination": "Where are you going?",
            "vehicle_type": "What type of vehicle do you prefer?",
            "pickup_time": "When do you need the ride?",
            "payment_method_id": "How would you like to pay?",
        }
        return questions.get(field, f"Please provide: {field}")
    
    def handle_user_input(
        self, 
        state: ConversationState, 
        user_input: str,
        extracted_data: Dict[str, Any]
    ) -> ConversationState:
        """
        Process user input and update state
        
        Args:
            state: Current conversation state
            user_input: Raw user message
            extracted_data: Data extracted from user input by NLU
        """
        # Store raw input
        state.add_history("user_input", {
            "message": user_input,
            "extracted": extracted_data
        })
        
        # Add extracted data to collected data
        for key, value in extracted_data.items():
            state.collect_data(key, value)
        
        # Try to advance stage
        state = self.advance_stage(state)
        
        return state
    
    def get_next_prompt(self, state: ConversationState) -> str:
        """
        Generate next AI prompt based on current state
        """
        if state.pending_questions:
            return state.pending_questions[0]
        
        # Stage-specific prompts
        prompts = {
            ConversationStage.INTENT_RECOGNITION: 
                "What can I help you with today?",
            
            ConversationStage.CATEGORY_SELECTION: 
                "What type of food are you interested in?",
            
            ConversationStage.CONFIRMATION: 
                f"Ready to place your order? Total: ${state.collected_data.get('total_amount', 0):.2f}",
            
            ConversationStage.TRACKING: 
                "I'm tracking your order. I'll keep you updated!",
            
            ConversationStage.COMPLETED: 
                "Your order has been delivered! Enjoy! 🎉"
        }
        
        return prompts.get(state.stage, "How can I assist you further?")


# Conversation state storage (in-memory for now, will use MongoDB)
_conversation_states: Dict[str, ConversationState] = {}


def get_or_create_conversation(
    user_id: str, 
    session_id: str
) -> ConversationState:
    """Get existing conversation or create new one"""
    key = f"{user_id}:{session_id}"
    
    if key not in _conversation_states:
        _conversation_states[key] = ConversationState(
            user_id=user_id,
            session_id=session_id
        )
    
    return _conversation_states[key]


def save_conversation_state(state: ConversationState):
    """Save conversation state"""
    key = f"{state.user_id}:{state.session_id}"
    _conversation_states[key] = state


def get_active_conversations(user_id: str) -> List[ConversationState]:
    """Get all active conversations for user"""
    return [
        state for state in _conversation_states.values()
        if state.user_id == user_id and not state.is_expired()
    ]
