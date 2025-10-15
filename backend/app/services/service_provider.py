"""
Service Provider Interface

Universal adapter pattern for integrating various service providers
(UberEats, DoorDash, Uber, Lyft, TaskRabbit, etc.)
"""

from abc import ABC, abstractmethod
from typing import List, Optional, Dict, Any
from pydantic import BaseModel, Field
from datetime import datetime
from enum import Enum


class ServiceCategory(str, Enum):
    """Service categories"""
    FOOD = "food"
    TRANSPORTATION = "transportation"
    GROCERY = "grocery"
    HOME_SERVICE = "home_service"
    SHOPPING = "shopping"
    HEALTHCARE = "healthcare"
    ENTERTAINMENT = "entertainment"


class SearchCriteria(BaseModel):
    """Criteria for searching services"""
    category: ServiceCategory
    location: Dict[str, float]  # {"lat": 37.7749, "lng": -122.4194}
    query: Optional[str] = None  # "pizza", "italian", etc.
    filters: Dict[str, Any] = Field(default_factory=dict)  # price_range, rating, etc.
    limit: int = 10


class ServiceOption(BaseModel):
    """A service option (restaurant, ride type, service provider)"""
    id: str
    provider: str  # "ubereats", "doordash", etc.
    name: str
    description: Optional[str] = None
    category: str
    image_url: Optional[str] = None
    rating: Optional[float] = None
    price_level: Optional[int] = None  # 1-4 ($, $$, $$$, $$$$)
    delivery_time: Optional[int] = None  # minutes
    delivery_fee: Optional[float] = None
    minimum_order: Optional[float] = None
    tags: List[str] = Field(default_factory=list)
    distance: Optional[float] = None  # miles/km
    available: bool = True
    metadata: Dict[str, Any] = Field(default_factory=dict)


class ServiceDetails(BaseModel):
    """Detailed information about a service"""
    id: str
    provider: str
    name: str
    description: str
    category: str
    menu_items: Optional[List[Dict[str, Any]]] = None  # For food
    options: Optional[List[Dict[str, Any]]] = None  # For other services
    pricing: Dict[str, Any] = Field(default_factory=dict)
    availability: Dict[str, Any] = Field(default_factory=dict)
    location: Optional[Dict[str, float]] = None
    contact: Optional[Dict[str, str]] = None
    images: List[str] = Field(default_factory=list)
    reviews: Optional[Dict[str, Any]] = None


class OrderRequest(BaseModel):
    """Request to place an order"""
    service_id: str
    provider: str
    items: List[Dict[str, Any]]
    customizations: Dict[str, Any] = Field(default_factory=dict)
    delivery_address: Dict[str, Any]
    delivery_time: Optional[str] = None  # "now" or specific time
    payment_method_id: str
    special_instructions: Optional[str] = None
    tip_amount: Optional[float] = None
    user_id: str
    contact: Dict[str, str]  # phone, email


class Order(BaseModel):
    """Placed order"""
    order_id: str
    provider: str
    provider_order_id: str
    status: str
    service_name: str
    items: List[Dict[str, Any]]
    subtotal: float
    delivery_fee: float
    tax: float
    tip: float
    total: float
    currency: str = "USD"
    estimated_delivery_time: Optional[datetime] = None
    delivery_address: Dict[str, Any]
    tracking_url: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)


class OrderStatusUpdate(BaseModel):
    """Real-time order status update"""
    order_id: str
    status: str
    message: str
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    driver_location: Optional[Dict[str, float]] = None
    estimated_minutes: Optional[int] = None
    metadata: Dict[str, Any] = Field(default_factory=dict)


class ServiceProvider(ABC):
    """
    Abstract base class for all service providers
    
    Each service (UberEats, DoorDash, Uber, etc.) implements this interface
    """
    
    def __init__(self, api_key: str, config: Dict[str, Any] = None):
        self.api_key = api_key
        self.config = config or {}
    
    @property
    @abstractmethod
    def provider_name(self) -> str:
        """Unique provider identifier"""
        pass
    
    @property
    @abstractmethod
    def supported_categories(self) -> List[ServiceCategory]:
        """Categories this provider supports"""
        pass
    
    @abstractmethod
    async def search_options(
        self, 
        criteria: SearchCriteria
    ) -> List[ServiceOption]:
        """
        Search for available services
        
        Example:
            - Search for restaurants near user
            - Search for available rides
            - Search for grocery stores
        """
        pass
    
    @abstractmethod
    async def get_details(self, service_id: str) -> ServiceDetails:
        """
        Get detailed information about a specific service
        
        Example:
            - Get restaurant menu
            - Get ride pricing options
            - Get service provider details
        """
        pass
    
    @abstractmethod
    async def place_order(self, request: OrderRequest) -> Order:
        """
        Place an order with the service provider
        
        Returns order confirmation with tracking info
        """
        pass
    
    @abstractmethod
    async def get_order_status(self, order_id: str) -> OrderStatusUpdate:
        """
        Get current status of an order
        """
        pass
    
    @abstractmethod
    async def cancel_order(self, order_id: str) -> bool:
        """
        Cancel an existing order
        
        Returns True if cancellation successful
        """
        pass
    
    async def estimate_cost(
        self, 
        service_id: str, 
        items: List[Dict[str, Any]],
        delivery_address: Dict[str, Any]
    ) -> Dict[str, float]:
        """
        Estimate total cost before placing order
        
        Returns breakdown: subtotal, delivery_fee, tax, total
        """
        # Default implementation, can be overridden
        return {
            "subtotal": 0.0,
            "delivery_fee": 0.0,
            "tax": 0.0,
            "total": 0.0
        }
    
    async def validate_delivery_address(
        self, 
        address: Dict[str, Any]
    ) -> tuple[bool, Optional[str]]:
        """
        Validate if delivery address is serviceable
        
        Returns (is_valid, error_message)
        """
        # Default implementation
        return True, None


class ServiceProviderRegistry:
    """
    Registry for all service providers
    
    Manages multiple providers and routes requests to appropriate one
    """
    
    def __init__(self):
        self._providers: Dict[str, ServiceProvider] = {}
    
    def register(self, provider: ServiceProvider):
        """Register a service provider"""
        self._providers[provider.provider_name] = provider
    
    def get_provider(self, provider_name: str) -> Optional[ServiceProvider]:
        """Get provider by name"""
        return self._providers.get(provider_name)
    
    def get_providers_for_category(
        self, 
        category: ServiceCategory
    ) -> List[ServiceProvider]:
        """Get all providers supporting a category"""
        return [
            provider for provider in self._providers.values()
            if category in provider.supported_categories
        ]
    
    async def search_all_providers(
        self, 
        criteria: SearchCriteria
    ) -> Dict[str, List[ServiceOption]]:
        """
        Search across all providers for a category
        
        Returns results grouped by provider
        """
        providers = self.get_providers_for_category(criteria.category)
        results = {}
        
        for provider in providers:
            try:
                options = await provider.search_options(criteria)
                results[provider.provider_name] = options
            except Exception as e:
                # Log error but continue with other providers
                print(f"Error searching {provider.provider_name}: {e}")
                results[provider.provider_name] = []
        
        return results
    
    async def aggregate_search_results(
        self, 
        criteria: SearchCriteria
    ) -> List[ServiceOption]:
        """
        Search all providers and return aggregated sorted results
        """
        results = await self.search_all_providers(criteria)
        
        # Flatten results
        all_options = []
        for provider_results in results.values():
            all_options.extend(provider_results)
        
        # Sort by rating and delivery time
        all_options.sort(
            key=lambda x: (
                -(x.rating or 0),  # Higher rating first
                x.delivery_time or 999  # Faster delivery first
            )
        )
        
        return all_options[:criteria.limit]


# Global registry instance
service_registry = ServiceProviderRegistry()
