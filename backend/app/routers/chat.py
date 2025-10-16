from datetime import datetime
import uuid
from typing import List

from fastapi import APIRouter, Depends, HTTPException, Request, status

from app.dependencies import get_current_user
from app.schemas.chat import ChatCreate, ChatPublic, MessageCreate, MessagePublic

router = APIRouter(prefix="/chat", tags=["chat"])


@router.post("/", response_model=ChatPublic, status_code=status.HTTP_201_CREATED)
async def start_chat(
    request: Request,
    payload: ChatCreate,
    current_user=Depends(get_current_user),
):
    if payload.participant_id == current_user["_id"]:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Cannot chat with yourself")

    users = request.app.database["users"]
    other_user = users.find_one({"_id": payload.participant_id})
    if not other_user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Participant not found")

    chats = request.app.database["chats"]
    participants = sorted([current_user["_id"], payload.participant_id])
    participants_hash = "::".join(participants)

    existing = chats.find_one({"participants_hash": participants_hash})
    if existing:
        return ChatPublic(**existing)

    chat_document = {
        "_id": str(uuid.uuid4()),
        "participants": participants,
        "participants_hash": participants_hash,
        "created_at": datetime.utcnow(),
    }
    chats.insert_one(chat_document)
    return ChatPublic(**chat_document)


@router.get("/", response_model=List[ChatPublic])
async def my_chats(request: Request, current_user=Depends(get_current_user)):
    chats = request.app.database["chats"].find({"participants": current_user["_id"]}).sort("created_at", -1)
    return [ChatPublic(**chat) for chat in chats]


def _ensure_chat_access(chat: dict, user_id: str):
    if user_id not in chat.get("participants", []):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not a participant of this chat")


@router.get("/{chat_id}/messages", response_model=List[MessagePublic])
async def get_messages(
    request: Request,
    chat_id: str,
    current_user=Depends(get_current_user),
):
    chats = request.app.database["chats"]
    chat = chats.find_one({"_id": chat_id})
    if not chat:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Chat not found")

    _ensure_chat_access(chat, current_user["_id"])

    messages_cursor = (
        request.app.database["messages"]
        .find({"chat_id": chat_id})
        .sort("created_at", 1)
    )
    return [MessagePublic(**message) for message in messages_cursor]


@router.post("/{chat_id}/messages", response_model=MessagePublic, status_code=status.HTTP_201_CREATED)
async def send_message(
    request: Request,
    chat_id: str,
    payload: MessageCreate,
    current_user=Depends(get_current_user),
):
    chats = request.app.database["chats"]
    chat = chats.find_one({"_id": chat_id})
    if not chat:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Chat not found")

    _ensure_chat_access(chat, current_user["_id"])

    message_document = {
        "_id": str(uuid.uuid4()),
        "chat_id": chat_id,
        "sender_id": current_user["_id"],
        "content": payload.content,
        "created_at": datetime.utcnow(),
    }
    request.app.database["messages"].insert_one(message_document)
    return MessagePublic(**message_document)


@router.post("/listing/{listing_id}", response_model=ChatPublic, status_code=status.HTTP_201_CREATED)
async def start_listing_chat(
    request: Request,
    listing_id: str,
    current_user=Depends(get_current_user),
):
    """Start a chat with the owner of a specific listing"""
    listings = request.app.database["listings"]
    listing = listings.find_one({"_id": listing_id, "is_active": True})
    if not listing:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Listing not found")
    
    # Prevent owners from chatting with themselves
    if listing["owner_id"] == current_user["_id"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, 
            detail="Cannot chat with yourself about your own listing"
        )

    # Check if listing owner exists
    users = request.app.database["users"]
    owner = users.find_one({"_id": listing["owner_id"]})
    if not owner:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Listing owner not found")

    # Create or find existing chat
    chats = request.app.database["chats"]
    participants = sorted([current_user["_id"], listing["owner_id"]])
    participants_hash = "::".join(participants)

    existing = chats.find_one({"participants_hash": participants_hash})
    if existing:
        # Update chat to include listing context if it doesn't exist
        if not existing.get("listing_context"):
            chats.update_one(
                {"_id": existing["_id"]},
                {"$set": {"listing_context": {
                    "listing_id": listing_id,
                    "listing_title": listing["title"],
                    "listing_price": listing.get("price", 0)
                }}}
            )
            existing["listing_context"] = {
                "listing_id": listing_id,
                "listing_title": listing["title"],
                "listing_price": listing.get("price", 0)
            }
        return ChatPublic(**existing)

    # Create new chat with listing context
    chat_document = {
        "_id": str(uuid.uuid4()),
        "participants": participants,
        "participants_hash": participants_hash,
        "listing_context": {
            "listing_id": listing_id,
            "listing_title": listing["title"],
            "listing_price": listing.get("price", 0)
        },
        "created_at": datetime.utcnow(),
    }
    chats.insert_one(chat_document)
    
    # Send automatic introductory message
    intro_message = {
        "_id": str(uuid.uuid4()),
        "chat_id": chat_document["_id"],
        "sender_id": "system",
        "content": f"💬 Chat started about listing: {listing['title']} (${listing.get('price', 0)})",
        "created_at": datetime.utcnow(),
    }
    request.app.database["messages"].insert_one(intro_message)
    
    return ChatPublic(**chat_document)


@router.get("/listing/{listing_id}/chats", response_model=List[ChatPublic])
async def get_listing_chats(
    request: Request,
    listing_id: str,
    current_user=Depends(get_current_user),
):
    """Get all chats for a listing (only for listing owner)"""
    listings = request.app.database["listings"]
    listing = listings.find_one({"_id": listing_id})
    if not listing:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Listing not found")
    
    # Only listing owner can see all chats for their listing
    if listing["owner_id"] != current_user["_id"]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, 
            detail="Only listing owner can view listing chats"
        )

    chats = request.app.database["chats"].find({
        "listing_context.listing_id": listing_id,
        "participants": current_user["_id"]
    }).sort("created_at", -1)
    
    return [ChatPublic(**chat) for chat in chats]
