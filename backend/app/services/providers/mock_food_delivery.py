"""
Mock Food Delivery Provider

Simulates UberEats/DoorDash for testing the AI concierge system.
Will be replaced with real API integrations.
"""

import asyncio
import random
from typing import List, Dict, Any
from datetime import datetime, timedelta
import uuid

from app.services.service_provider import (
    ServiceProvider,
    ServiceCategory,
    SearchCriteria,
    ServiceOption,
    ServiceDetails,
    OrderRequest,
    Order,
    OrderStatusUpdate
)


class MockFoodDeliveryProvider(ServiceProvider):
    """
    Mock food delivery service for development and testing
    """
    
    def __init__(self):
        """Initialize mock provider (no API key needed)"""
        super().__init__(api_key="mock_api_key", config={})
    
    # Mock restaurant database
    MOCK_RESTAURANTS = [
        {
            "id": "rest_1",
            "name": "Papa's Pizza Palace",
            "description": "Authentic Italian pizza made fresh daily",
            "category": "Italian",
            "rating": 4.7,
            "price_level": 2,
            "delivery_time": 30,
            "delivery_fee": 2.99,
            "minimum_order": 15.00,
            "tags": ["Pizza", "Italian", "Fast Delivery"],
            "image_url": "https://example.com/papas-pizza.jpg",
            "menu": [
                {"id": "item_1", "name": "Pepperoni Pizza", "price": 18.99, "size": "Large"},
                {"id": "item_2", "name": "Margherita Pizza", "price": 16.99, "size": "Large"},
                {"id": "item_3", "name": "Hawaiian Pizza", "price": 19.99, "size": "Large"},
                {"id": "item_4", "name": "Veggie Supreme", "price": 17.99, "size": "Large"},
                {"id": "item_5", "name": "Caesar Salad", "price": 8.99},
                {"id": "item_6", "name": "Garlic Bread", "price": 5.99},
            ]
        },
        {
            "id": "rest_2",
            "name": "Burger Kingdom",
            "description": "Gourmet burgers and shakes",
            "category": "American",
            "rating": 4.5,
            "price_level": 2,
            "delivery_time": 25,
            "delivery_fee": 3.49,
            "minimum_order": 12.00,
            "tags": ["Burgers", "American", "Fast Food"],
            "image_url": "https://example.com/burger-kingdom.jpg",
            "menu": [
                {"id": "item_7", "name": "Classic Cheeseburger", "price": 12.99},
                {"id": "item_8", "name": "Bacon BBQ Burger", "price": 14.99},
                {"id": "item_9", "name": "Veggie Burger", "price": 11.99},
                {"id": "item_10", "name": "Chicken Sandwich", "price": 13.99},
                {"id": "item_11", "name": "Fries", "price": 4.99},
                {"id": "item_12", "name": "Milkshake", "price": 5.99},
            ]
        },
        {
            "id": "rest_3",
            "name": "Sushi Sensation",
            "description": "Fresh sushi and Japanese cuisine",
            "category": "Japanese",
            "rating": 4.8,
            "price_level": 3,
            "delivery_time": 40,
            "delivery_fee": 4.99,
            "minimum_order": 20.00,
            "tags": ["Sushi", "Japanese", "Healthy"],
            "image_url": "https://example.com/sushi-sensation.jpg",
            "menu": [
                {"id": "item_13", "name": "California Roll", "price": 12.99},
                {"id": "item_14", "name": "Spicy Tuna Roll", "price": 14.99},
                {"id": "item_15", "name": "Rainbow Roll", "price": 16.99},
                {"id": "item_16", "name": "Salmon Sashimi", "price": 18.99},
                {"id": "item_17", "name": "Edamame", "price": 5.99},
                {"id": "item_18", "name": "Miso Soup", "price": 3.99},
            ]
        },
        {
            "id": "rest_4",
            "name": "Taco Fiesta",
            "description": "Authentic Mexican street food",
            "category": "Mexican",
            "rating": 4.6,
            "price_level": 1,
            "delivery_time": 20,
            "delivery_fee": 2.49,
            "minimum_order": 10.00,
            "tags": ["Mexican", "Tacos", "Budget-Friendly"],
            "image_url": "https://example.com/taco-fiesta.jpg",
            "menu": [
                {"id": "item_19", "name": "Street Tacos (3pc)", "price": 9.99},
                {"id": "item_20", "name": "Burrito Bowl", "price": 11.99},
                {"id": "item_21", "name": "Quesadilla", "price": 10.99},
                {"id": "item_22", "name": "Nachos Supreme", "price": 12.99},
                {"id": "item_23", "name": "Guacamole & Chips", "price": 6.99},
                {"id": "item_24", "name": "Horchata", "price": 3.99},
            ]
        },
        {
            "id": "rest_5",
            "name": "Thai Orchid",
            "description": "Traditional Thai flavors",
            "category": "Thai",
            "rating": 4.7,
            "price_level": 2,
            "delivery_time": 35,
            "delivery_fee": 3.99,
            "minimum_order": 15.00,
            "tags": ["Thai", "Asian", "Spicy"],
            "image_url": "https://example.com/thai-orchid.jpg",
            "menu": [
                {"id": "item_25", "name": "Pad Thai", "price": 13.99},
                {"id": "item_26", "name": "Green Curry", "price": 14.99},
                {"id": "item_27", "name": "Tom Yum Soup", "price": 12.99},
                {"id": "item_28", "name": "Spring Rolls", "price": 6.99},
                {"id": "item_29", "name": "Mango Sticky Rice", "price": 7.99},
            ]
        }
    ]
    
    @property
    def provider_name(self) -> str:
        return "mock_food_delivery"
    
    @property
    def supported_categories(self) -> List[ServiceCategory]:
        return [ServiceCategory.FOOD]
    
    async def search_options(
        self, 
        criteria: SearchCriteria
    ) -> List[ServiceOption]:
        """Search for restaurants"""
        # Simulate API delay
        await asyncio.sleep(0.5)
        
        results = []
        query = criteria.query.lower() if criteria.query else ""
        
        for restaurant in self.MOCK_RESTAURANTS:
            # Simple matching logic
            matches = True
            if query:
                matches = (
                    query in restaurant["name"].lower() or
                    query in restaurant["category"].lower() or
                    any(query in tag.lower() for tag in restaurant["tags"])
                )
            
            if matches:
                # Calculate mock distance (random for now)
                distance = round(random.uniform(0.5, 5.0), 1)
                
                results.append(ServiceOption(
                    id=restaurant["id"],
                    provider=self.provider_name,
                    name=restaurant["name"],
                    description=restaurant["description"],
                    category=restaurant["category"],
                    image_url=restaurant.get("image_url"),
                    rating=restaurant["rating"],
                    price_level=restaurant["price_level"],
                    delivery_time=restaurant["delivery_time"],
                    delivery_fee=restaurant["delivery_fee"],
                    minimum_order=restaurant["minimum_order"],
                    tags=restaurant["tags"],
                    distance=distance,
                    available=True
                ))
        
        # Sort by rating
        results.sort(key=lambda x: x.rating, reverse=True)
        
        return results[:criteria.limit]
    
    async def get_details(self, service_id: str) -> ServiceDetails:
        """Get restaurant menu and details"""
        await asyncio.sleep(0.3)
        
        # Find restaurant
        restaurant = next(
            (r for r in self.MOCK_RESTAURANTS if r["id"] == service_id),
            None
        )
        
        if not restaurant:
            raise ValueError(f"Restaurant {service_id} not found")
        
        return ServiceDetails(
            id=restaurant["id"],
            provider=self.provider_name,
            name=restaurant["name"],
            description=restaurant["description"],
            category=restaurant["category"],
            menu_items=restaurant["menu"],
            pricing={
                "delivery_fee": restaurant["delivery_fee"],
                "minimum_order": restaurant["minimum_order"],
                "price_level": restaurant["price_level"]
            },
            availability={
                "is_open": True,
                "hours": "10:00 AM - 11:00 PM",
                "delivery_time": restaurant["delivery_time"]
            },
            images=[restaurant.get("image_url")],
            reviews={
                "rating": restaurant["rating"],
                "total_reviews": random.randint(100, 500)
            }
        )
    
    async def place_order(self, request: OrderRequest) -> Order:
        """Place food order"""
        await asyncio.sleep(1.0)
        
        # Calculate costs
        subtotal = sum(item.get("price", 0) * item.get("quantity", 1) 
                      for item in request.items)
        delivery_fee = 2.99  # Mock fee
        tax = subtotal * 0.08  # 8% tax
        tip = request.tip_amount or 0
        total = subtotal + delivery_fee + tax + tip
        
        # Get restaurant details
        restaurant = next(
            (r for r in self.MOCK_RESTAURANTS if r["id"] == request.service_id),
            None
        )
        
        if not restaurant:
            raise ValueError(f"Restaurant {request.service_id} not found")
        
        # Create order
        order_id = str(uuid.uuid4())
        provider_order_id = f"MOCK-{random.randint(10000, 99999)}"
        
        estimated_delivery = datetime.utcnow() + timedelta(
            minutes=restaurant["delivery_time"]
        )
        
        return Order(
            order_id=order_id,
            provider=self.provider_name,
            provider_order_id=provider_order_id,
            status="placed",
            service_name=restaurant["name"],
            items=request.items,
            subtotal=round(subtotal, 2),
            delivery_fee=round(delivery_fee, 2),
            tax=round(tax, 2),
            tip=round(tip, 2),
            total=round(total, 2),
            currency="USD",
            estimated_delivery_time=estimated_delivery,
            delivery_address=request.delivery_address,
            tracking_url=f"https://mock-tracking.com/{order_id}"
        )
    
    async def get_order_status(self, order_id: str) -> OrderStatusUpdate:
        """Get order status (mock progression)"""
        await asyncio.sleep(0.2)
        
        # Mock status based on order age (in real app, query actual status)
        # For now, return random status
        statuses = [
            ("placed", "Order placed! Restaurant is confirming.", None),
            ("confirmed", "Restaurant confirmed your order!", None),
            ("preparing", "Your food is being prepared.", 25),
            ("ready", "Your order is ready for pickup!", 20),
            ("picked_up", "Driver picked up your order.", 15),
            ("in_transit", "On the way to you!", 10),
            ("nearby", "Driver is 5 minutes away!", 5),
            ("arrived", "Driver has arrived!", 0),
        ]
        
        status_data = random.choice(statuses)
        
        return OrderStatusUpdate(
            order_id=order_id,
            status=status_data[0],
            message=status_data[1],
            estimated_minutes=status_data[2],
            driver_location={
                "lat": 37.7749 + random.uniform(-0.01, 0.01),
                "lng": -122.4194 + random.uniform(-0.01, 0.01)
            } if status_data[0] in ["in_transit", "nearby"] else None
        )
    
    async def cancel_order(self, order_id: str) -> bool:
        """Cancel order"""
        await asyncio.sleep(0.5)
        # Mock cancellation
        return True
    
    async def estimate_cost(
        self, 
        service_id: str, 
        items: List[Dict[str, Any]],
        delivery_address: Dict[str, Any]
    ) -> Dict[str, float]:
        """Estimate order cost"""
        subtotal = sum(item.get("price", 0) * item.get("quantity", 1) 
                      for item in items)
        delivery_fee = 2.99
        tax = subtotal * 0.08
        total = subtotal + delivery_fee + tax
        
        return {
            "subtotal": round(subtotal, 2),
            "delivery_fee": round(delivery_fee, 2),
            "tax": round(tax, 2),
            "total": round(total, 2)
        }
