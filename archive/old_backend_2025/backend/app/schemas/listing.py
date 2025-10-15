from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel, Field, ConfigDict


class ListingBase(BaseModel):
    title: str = Field(..., min_length=3, max_length=140)
    description: str = Field(..., min_length=10, max_length=4000)
    price: float = Field(..., ge=0)
    category: Optional[str] = Field(default=None, max_length=80)
    location: Optional[str] = Field(default=None, max_length=120)
    image_urls: List[str] = Field(default_factory=list)


class ListingCreate(ListingBase):
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "title": "Mountain Bike",
                "description": "Lightly used trail bike in great condition.",
                "price": 450.0,
                "category": "Sports",
                "location": "Cape Town",
                "image_urls": [
                    "https://example.com/bike-front.jpg",
                    "https://example.com/bike-side.jpg",
                ],
            }
        }
    )


class ListingUpdate(BaseModel):
    title: Optional[str] = Field(default=None, min_length=3, max_length=140)
    description: Optional[str] = Field(default=None, min_length=10, max_length=4000)
    price: Optional[float] = Field(default=None, ge=0)
    category: Optional[str] = Field(default=None, max_length=80)
    location: Optional[str] = Field(default=None, max_length=120)
    image_urls: Optional[List[str]] = None
    is_active: Optional[bool] = None


class ListingPublic(ListingBase):
    id: str = Field(alias="_id")
    owner_id: str
    is_active: bool = True
    created_at: datetime
    updated_at: Optional[datetime] = None

    model_config = ConfigDict(populate_by_name=True)
