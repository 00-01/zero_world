from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel, Field, ConfigDict


class CommunityPostCreate(BaseModel):
    title: str = Field(..., min_length=3, max_length=140)
    content: str = Field(..., min_length=10, max_length=6000)
    tags: List[str] = Field(default_factory=list)


class CommunityPostPublic(BaseModel):
    id: str = Field(alias="_id")
    author_id: str
    title: str
    content: str
    tags: List[str]
    created_at: datetime
    updated_at: Optional[datetime] = None
    like_count: int = 0

    model_config = ConfigDict(populate_by_name=True)


class CommunityCommentCreate(BaseModel):
    content: str = Field(..., min_length=1, max_length=2000)


class CommunityCommentPublic(BaseModel):
    id: str = Field(alias="_id")
    post_id: str
    author_id: str
    content: str
    created_at: datetime

    model_config = ConfigDict(populate_by_name=True)
