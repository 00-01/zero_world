"""
AI Concierge API Endpoints

This module provides REST API endpoints for the AI Concierge system.
It handles conversation management, service search, order placement, and real-time tracking.

Endpoints:
    - POST /api/concierge/conversation/start - Start a new conversation
    - POST /api/concierge/conversation/{id}/message - Send a message
    - GET /api/concierge/conversation/{id} - Get conversation state
    - DELETE /api/concierge/conversation/{id}/cancel - Cancel conversation
    
    - GET /api/concierge/services/search - Search for services
    - GET /api/concierge/services/{id}/details - Get service details
    - POST /api/concierge/services/{id}/estimate - Get cost estimate
    
    - POST /api/concierge/orders/place - Place an order
    - GET /api/concierge/orders/{id} - Get order details
    - GET /api/concierge/orders/{id}/status - Get order status
    - POST /api/concierge/orders/{id}/cancel - Cancel order
"""

from fastapi import APIRouter, HTTPException, Depends, WebSocket, WebSocketDisconnect
from typing import List, Dict, Any, Optional
from pydantic import BaseModel, Field
from datetime import datetime
import asyncio
import logging

from ..services.conversation_state import (
    ConversationState,
    ConversationStateMachine,
    ConversationStage,
    ServiceType,
    OrderStatus,
    Intent,
    get_or_create_conversation,
    save_conversation_state,
    get_active_conversations,
)
from ..services.service_provider import (
    ServiceProvider,
    ServiceProviderRegistry,
    SearchCriteria,
    ServiceOption,
    ServiceDetails,
    OrderRequest,
    Order,
    OrderStatusUpdate,
    ServiceCategory,
    service_registry,
)
from ..dependencies import get_current_user

# Set up logging
logger = logging.getLogger(__name__)

# Create router
router = APIRouter(prefix="/api/concierge", tags=["AI Concierge"])

# Initialize conversation state machine
state_machine = ConversationStateMachine()


# ============================================================================
#                           REQUEST/RESPONSE MODELS
# ============================================================================

class StartConversationRequest(BaseModel):
    """Request to start a new conversation"""
    initial_message: Optional[str] = Field(None, description="Optional initial user message")
    session_id: Optional[str] = Field(None, description="Optional session ID for tracking")


class StartConversationResponse(BaseModel):
    """Response when starting a conversation"""
    conversation_id: str
    message: str
    stage: ConversationStage
    progress_percentage: int
    suggested_replies: Optional[List[str]] = None


class SendMessageRequest(BaseModel):
    """Request to send a message in a conversation"""
    message: str
    extracted_data: Optional[Dict[str, Any]] = Field(
        default_factory=dict,
        description="Optional pre-extracted structured data from the message"
    )


class SendMessageResponse(BaseModel):
    """Response after sending a message"""
    conversation_id: str
    message: str
    stage: ConversationStage
    progress_percentage: int
    collected_data: Dict[str, Any]
    pending_questions: List[str]
    service_options: Optional[List[ServiceOption]] = None
    order_summary: Optional[Dict[str, Any]] = None
    suggested_replies: Optional[List[str]] = None


class ConversationStateResponse(BaseModel):
    """Full conversation state"""
    conversation_id: str
    user_id: str
    service_type: Optional[ServiceType]
    provider: Optional[str]
    stage: ConversationStage
    collected_data: Dict[str, Any]
    pending_questions: List[str]
    order_id: Optional[str]
    order_status: Optional[OrderStatus]
    progress_percentage: int
    created_at: datetime
    last_update: datetime


class SearchServicesRequest(BaseModel):
    """Request to search for services"""
    category: ServiceCategory
    query: Optional[str] = None
    location: Optional[Dict[str, float]] = None  # {"lat": 37.7749, "lng": -122.4194}
    filters: Optional[Dict[str, Any]] = None
    limit: int = 10


class CostEstimateRequest(BaseModel):
    """Request to estimate cost"""
    service_id: str
    items: List[Dict[str, Any]]
    delivery_address: Optional[Dict[str, Any]] = None
    customizations: Optional[Dict[str, Any]] = None


class PlaceOrderRequest(BaseModel):
    """Request to place an order"""
    conversation_id: str
    service_id: str
    items: List[Dict[str, Any]]
    delivery_address: Dict[str, Any]
    payment_method_id: str
    customizations: Optional[Dict[str, Any]] = None
    tip_amount: Optional[float] = 0.0
    notes: Optional[str] = None


# ============================================================================
#                           CONVERSATION ENDPOINTS
# ============================================================================

@router.post("/conversation/start", response_model=StartConversationResponse)
async def start_conversation(
    request: StartConversationRequest,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Start a new conversation with the AI Concierge.
    
    This initializes a conversation state and optionally processes an initial message.
    """
    try:
        user_id = current_user["user_id"]
        
        # Create new conversation
        conversation = get_or_create_conversation(
            user_id=user_id,
            session_id=request.session_id
        )
        
        # Process initial message if provided
        if request.initial_message:
            # Simple intent extraction (in production, use NLU service)
            extracted_data = _extract_intent_simple(request.initial_message)
            
            conversation = state_machine.handle_user_input(
                state=conversation,
                user_input=request.initial_message,
                extracted_data=extracted_data
            )
            
            save_conversation_state(conversation)
        
        # Generate response
        response_message = state_machine.get_next_prompt(conversation)
        
        return StartConversationResponse(
            conversation_id=conversation.conversation_id,
            message=response_message,
            stage=conversation.stage,
            progress_percentage=conversation.get_progress_percentage(),
            suggested_replies=_get_suggested_replies(conversation)
        )
        
    except Exception as e:
        logger.error(f"Error starting conversation: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/conversation/{conversation_id}/message", response_model=SendMessageResponse)
async def send_message(
    conversation_id: str,
    request: SendMessageRequest,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Send a message in an ongoing conversation.
    
    This processes the user's message, updates the conversation state,
    and generates an appropriate response.
    """
    try:
        # Get existing conversation
        conversation = get_or_create_conversation(
            user_id=current_user["user_id"],
            conversation_id=conversation_id
        )
        
        # Extract data from message if not provided
        if not request.extracted_data:
            request.extracted_data = _extract_data_simple(
                request.message,
                conversation.stage
            )
        
        # Handle user input
        conversation = state_machine.handle_user_input(
            state=conversation,
            user_input=request.message,
            extracted_data=request.extracted_data
        )
        
        save_conversation_state(conversation)
        
        # Generate response
        response_message = state_machine.get_next_prompt(conversation)
        
        # Get service options if in selection stage
        service_options = None
        if conversation.stage == ConversationStage.ITEM_SELECTION:
            service_options = await _get_service_options(conversation)
        
        # Generate order summary if in confirmation stage
        order_summary = None
        if conversation.stage == ConversationStage.CONFIRMATION:
            order_summary = _generate_order_summary(conversation)
        
        return SendMessageResponse(
            conversation_id=conversation.conversation_id,
            message=response_message,
            stage=conversation.stage,
            progress_percentage=conversation.get_progress_percentage(),
            collected_data=conversation.collected_data,
            pending_questions=conversation.pending_questions,
            service_options=service_options,
            order_summary=order_summary,
            suggested_replies=_get_suggested_replies(conversation)
        )
        
    except Exception as e:
        logger.error(f"Error sending message: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/conversation/{conversation_id}", response_model=ConversationStateResponse)
async def get_conversation_state(
    conversation_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """Get the current state of a conversation."""
    try:
        conversation = get_or_create_conversation(
            user_id=current_user["user_id"],
            conversation_id=conversation_id
        )
        
        return ConversationStateResponse(
            conversation_id=conversation.conversation_id,
            user_id=conversation.user_id,
            service_type=conversation.service_type,
            provider=conversation.provider,
            stage=conversation.stage,
            collected_data=conversation.collected_data,
            pending_questions=conversation.pending_questions,
            order_id=conversation.order_id,
            order_status=conversation.order_status,
            progress_percentage=conversation.get_progress_percentage(),
            created_at=conversation.created_at,
            last_update=conversation.last_update
        )
        
    except Exception as e:
        logger.error(f"Error getting conversation state: {e}")
        raise HTTPException(status_code=404, detail="Conversation not found")


@router.delete("/conversation/{conversation_id}/cancel")
async def cancel_conversation(
    conversation_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """Cancel an active conversation."""
    try:
        conversation = get_or_create_conversation(
            user_id=current_user["user_id"],
            conversation_id=conversation_id
        )
        
        # Update to completed stage
        conversation.update_stage(ConversationStage.COMPLETED)
        conversation.add_history("conversation_cancelled", "User cancelled conversation")
        save_conversation_state(conversation)
        
        return {"message": "Conversation cancelled successfully"}
        
    except Exception as e:
        logger.error(f"Error cancelling conversation: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# ============================================================================
#                           SERVICE ENDPOINTS
# ============================================================================

@router.get("/services/search")
async def search_services(
    category: ServiceCategory,
    query: Optional[str] = None,
    lat: Optional[float] = None,
    lng: Optional[float] = None,
    limit: int = 10,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Search for services across all providers.
    
    Returns aggregated and sorted results from all available providers.
    """
    try:
        criteria = SearchCriteria(
            category=category,
            query=query,
            location={"lat": lat, "lng": lng} if lat and lng else None,
            limit=limit
        )
        
        # Search across all providers
        results = await service_registry.aggregate_search_results(criteria)
        
        return {
            "results": results,
            "total": len(results)
        }
        
    except Exception as e:
        logger.error(f"Error searching services: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/services/{service_id}/details")
async def get_service_details(
    service_id: str,
    provider: str,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """Get detailed information about a specific service."""
    try:
        # Get provider
        providers = service_registry.get_providers_for_category(ServiceCategory.FOOD)
        matching_provider = None
        
        for p in providers:
            if p.provider_name == provider:
                matching_provider = p
                break
        
        if not matching_provider:
            raise HTTPException(status_code=404, detail="Provider not found")
        
        # Get details
        details = await matching_provider.get_details(service_id)
        
        return details
        
    except Exception as e:
        logger.error(f"Error getting service details: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/services/{service_id}/estimate")
async def estimate_cost(
    service_id: str,
    provider: str,
    request: CostEstimateRequest,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """Get a cost estimate for a service."""
    try:
        # Get provider
        providers = service_registry.get_providers_for_category(ServiceCategory.FOOD)
        matching_provider = None
        
        for p in providers:
            if p.provider_name == provider:
                matching_provider = p
                break
        
        if not matching_provider:
            raise HTTPException(status_code=404, detail="Provider not found")
        
        # Estimate cost
        estimate = await matching_provider.estimate_cost(
            service_id=service_id,
            items=request.items,
            delivery_address=request.delivery_address,
            customizations=request.customizations
        )
        
        return estimate
        
    except Exception as e:
        logger.error(f"Error estimating cost: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# ============================================================================
#                           ORDER ENDPOINTS
# ============================================================================

@router.post("/orders/place")
async def place_order(
    request: PlaceOrderRequest,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """Place an order through a service provider."""
    try:
        # Get conversation
        conversation = get_or_create_conversation(
            user_id=current_user["user_id"],
            conversation_id=request.conversation_id
        )
        
        if not conversation.provider:
            raise HTTPException(status_code=400, detail="No provider selected")
        
        # Get provider
        providers = service_registry.get_providers_for_category(ServiceCategory.FOOD)
        matching_provider = None
        
        for p in providers:
            if p.provider_name == conversation.provider:
                matching_provider = p
                break
        
        if not matching_provider:
            raise HTTPException(status_code=404, detail="Provider not found")
        
        # Create order request
        order_request = OrderRequest(
            service_id=request.service_id,
            user_id=current_user["user_id"],
            items=request.items,
            delivery_address=request.delivery_address,
            payment_method_id=request.payment_method_id,
            customizations=request.customizations,
            tip_amount=request.tip_amount,
            notes=request.notes
        )
        
        # Place order
        order = await matching_provider.place_order(order_request)
        
        # Update conversation
        conversation.order_id = order.order_id
        conversation.order_status = order.status
        conversation.update_stage(ConversationStage.TRACKING)
        conversation.add_history("order_placed", {"order_id": order.order_id})
        save_conversation_state(conversation)
        
        return order
        
    except Exception as e:
        logger.error(f"Error placing order: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/orders/{order_id}")
async def get_order(
    order_id: str,
    provider: str,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """Get order details."""
    try:
        # Get provider
        providers = service_registry.get_providers_for_category(ServiceCategory.FOOD)
        matching_provider = None
        
        for p in providers:
            if p.provider_name == provider:
                matching_provider = p
                break
        
        if not matching_provider:
            raise HTTPException(status_code=404, detail="Provider not found")
        
        # Get order status (which includes full order details)
        status = await matching_provider.get_order_status(order_id)
        
        return status
        
    except Exception as e:
        logger.error(f"Error getting order: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/orders/{order_id}/status")
async def get_order_status(
    order_id: str,
    provider: str,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """Get real-time order status."""
    try:
        # Get provider
        providers = service_registry.get_providers_for_category(ServiceCategory.FOOD)
        matching_provider = None
        
        for p in providers:
            if p.provider_name == provider:
                matching_provider = p
                break
        
        if not matching_provider:
            raise HTTPException(status_code=404, detail="Provider not found")
        
        # Get status
        status = await matching_provider.get_order_status(order_id)
        
        return status
        
    except Exception as e:
        logger.error(f"Error getting order status: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/orders/{order_id}/cancel")
async def cancel_order(
    order_id: str,
    provider: str,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """Cancel an active order."""
    try:
        # Get provider
        providers = service_registry.get_providers_for_category(ServiceCategory.FOOD)
        matching_provider = None
        
        for p in providers:
            if p.provider_name == provider:
                matching_provider = p
                break
        
        if not matching_provider:
            raise HTTPException(status_code=404, detail="Provider not found")
        
        # Cancel order
        success = await matching_provider.cancel_order(order_id)
        
        if success:
            return {"message": "Order cancelled successfully"}
        else:
            raise HTTPException(status_code=400, detail="Unable to cancel order")
        
    except Exception as e:
        logger.error(f"Error cancelling order: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# ============================================================================
#                           WEBSOCKET ENDPOINT
# ============================================================================

@router.websocket("/orders/{order_id}/track")
async def track_order_websocket(
    websocket: WebSocket,
    order_id: str,
    provider: str
):
    """
    WebSocket endpoint for real-time order tracking.
    
    Sends status updates every few seconds until the order is completed.
    """
    await websocket.accept()
    
    try:
        # Get provider
        providers = service_registry.get_providers_for_category(ServiceCategory.FOOD)
        matching_provider = None
        
        for p in providers:
            if p.provider_name == provider:
                matching_provider = p
                break
        
        if not matching_provider:
            await websocket.send_json({"error": "Provider not found"})
            await websocket.close()
            return
        
        # Stream updates
        while True:
            try:
                # Get current status
                status = await matching_provider.get_order_status(order_id)
                
                # Send to client
                await websocket.send_json({
                    "order_id": status.order_id,
                    "status": status.status,
                    "message": status.message,
                    "timestamp": status.timestamp.isoformat(),
                    "driver_location": status.driver_location,
                    "estimated_minutes": status.estimated_minutes
                })
                
                # Check if order is complete
                if status.status in [OrderStatus.DELIVERED, OrderStatus.COMPLETED, OrderStatus.CANCELLED]:
                    break
                
                # Wait before next update
                await asyncio.sleep(5)
                
            except WebSocketDisconnect:
                logger.info(f"WebSocket disconnected for order {order_id}")
                break
                
    except Exception as e:
        logger.error(f"Error in order tracking WebSocket: {e}")
        await websocket.send_json({"error": str(e)})
    finally:
        await websocket.close()


# ============================================================================
#                           HELPER FUNCTIONS
# ============================================================================

def _extract_intent_simple(message: str) -> Dict[str, Any]:
    """
    Simple intent extraction (placeholder for NLU service).
    
    In production, this would use a proper NLU service like:
    - OpenAI GPT for intent/entity extraction
    - DialogFlow
    - Rasa NLU
    - Custom ML model
    """
    message_lower = message.lower()
    extracted = {}
    
    # Service type detection
    if any(word in message_lower for word in ["food", "pizza", "burger", "restaurant", "eat", "hungry"]):
        extracted["service_type"] = ServiceType.FOOD_DELIVERY
    elif any(word in message_lower for word in ["ride", "uber", "lyft", "taxi", "drive"]):
        extracted["service_type"] = ServiceType.RIDE_HAILING
    elif any(word in message_lower for word in ["grocery", "groceries", "shopping", "store"]):
        extracted["service_type"] = ServiceType.GROCERY_DELIVERY
    
    # Food type detection
    if "pizza" in message_lower:
        extracted["food_type"] = "pizza"
    elif any(word in message_lower for word in ["burger", "hamburger"]):
        extracted["food_type"] = "burger"
    elif "sushi" in message_lower:
        extracted["food_type"] = "sushi"
    elif any(word in message_lower for word in ["taco", "mexican"]):
        extracted["food_type"] = "mexican"
    
    return extracted


def _extract_data_simple(message: str, stage: ConversationStage) -> Dict[str, Any]:
    """
    Extract structured data from message based on current stage.
    
    In production, use proper NLU service.
    """
    extracted = {}
    message_lower = message.lower()
    
    # Stage-specific extraction
    if stage == ConversationStage.CATEGORY_SELECTION:
        extracted.update(_extract_intent_simple(message))
    
    elif stage == ConversationStage.DELIVERY_DETAILS:
        # Simple address extraction (very basic)
        if "deliver" in message_lower or "address" in message_lower:
            # In production, use proper address parsing
            extracted["delivery_address"] = {"raw": message}
    
    return extracted


async def _get_service_options(conversation: ConversationState) -> Optional[List[ServiceOption]]:
    """Get service options for the current conversation."""
    try:
        if not conversation.service_type:
            return None
        
        # Map service type to category
        category_map = {
            ServiceType.FOOD_DELIVERY: ServiceCategory.FOOD,
            ServiceType.RIDE_HAILING: ServiceCategory.TRANSPORTATION,
            ServiceType.GROCERY_DELIVERY: ServiceCategory.GROCERY,
        }
        
        category = category_map.get(conversation.service_type)
        if not category:
            return None
        
        # Get query from collected data
        query = conversation.collected_data.get("food_type") or conversation.collected_data.get("category")
        
        # Search
        criteria = SearchCriteria(
            category=category,
            query=query,
            limit=5
        )
        
        results = await service_registry.aggregate_search_results(criteria)
        return results
        
    except Exception as e:
        logger.error(f"Error getting service options: {e}")
        return None


def _generate_order_summary(conversation: ConversationState) -> Dict[str, Any]:
    """Generate order summary for confirmation."""
    return {
        "service_type": conversation.service_type,
        "provider": conversation.provider,
        "items": conversation.collected_data.get("items", []),
        "delivery_address": conversation.collected_data.get("delivery_address"),
        "estimated_cost": conversation.collected_data.get("estimated_cost"),
        "customizations": conversation.collected_data.get("customizations"),
    }


def _get_suggested_replies(conversation: ConversationState) -> Optional[List[str]]:
    """Generate suggested quick replies based on current stage."""
    suggestions = {
        ConversationStage.INTENT_RECOGNITION: [
            "I want food delivery",
            "I need a ride",
            "Order groceries",
        ],
        ConversationStage.CATEGORY_SELECTION: [
            "Pizza",
            "Burgers",
            "Sushi",
            "Show me all options",
        ],
        ConversationStage.CONFIRMATION: [
            "Yes, place the order",
            "No, let me make changes",
            "Cancel",
        ],
    }
    
    return suggestions.get(conversation.stage)
