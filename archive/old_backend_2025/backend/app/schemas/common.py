from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class DateTrackingModel(BaseModel):
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: Optional[datetime] = None

    model_config = {
        "json_schema_extra": {
            "example": {
                "created_at": "2025-01-01T12:00:00Z",
                "updated_at": "2025-01-02T12:00:00Z",
            }
        }
    }
