from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel, Field, ConfigDict


class ListingContext(BaseModel):
    listing_id: str
    listing_title: str
    listing_price: float = 0


class ChatCreate(BaseModel):
    participant_id: str = Field(..., min_length=1)


class ChatPublic(BaseModel):
    id: str = Field(alias="_id")
    participants: List[str]
    created_at: datetime
    listing_context: Optional[ListingContext] = None

    model_config = ConfigDict(populate_by_name=True)


class MessageCreate(BaseModel):
    content: str = Field(..., min_length=1, max_length=2000)


class MessagePublic(BaseModel):
    id: str = Field(alias="_id")
    chat_id: str
    sender_id: str
    content: str
    created_at: datetime

    model_config = ConfigDict(populate_by_name=True)
