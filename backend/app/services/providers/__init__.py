"""
Service Providers Module

This module initializes and registers all service providers with the service registry.
"""

from ..service_provider import service_registry, ServiceCategory
from .mock_food_delivery import MockFoodDeliveryProvider

# Initialize providers
mock_food_provider = MockFoodDeliveryProvider()

# Register providers
service_registry.register(mock_food_provider)

# Export for convenience
__all__ = [
    "mock_food_provider",
    "service_registry",
]
