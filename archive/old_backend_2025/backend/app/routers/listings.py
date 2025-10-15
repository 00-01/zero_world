from datetime import datetime
import uuid
from typing import List

from fastapi import APIRouter, Depends, HTTPException, Request, status

from app.dependencies import get_current_user
from app.schemas.listing import ListingCreate, ListingPublic, ListingUpdate

router = APIRouter(prefix="/listings", tags=["listings"])


@router.post("/", response_model=ListingPublic, status_code=status.HTTP_201_CREATED)
async def create_listing(
    request: Request,
    payload: ListingCreate,
    current_user=Depends(get_current_user),
):
    listings = request.app.database["listings"]
    listing_document = {
        "_id": str(uuid.uuid4()),
        "owner_id": current_user["_id"],
        "is_active": True,
        "created_at": datetime.utcnow(),
        "updated_at": None,
        **payload.model_dump(),
    }
    listings.insert_one(listing_document)
    return ListingPublic(**listing_document)


@router.get("/", response_model=List[ListingPublic])
async def list_listings(request: Request, limit: int = 50, skip: int = 0):
    limit = max(1, min(limit, 100))
    listings = (
        request.app.database["listings"]
        .find({"is_active": True})
        .skip(skip)
        .limit(limit)
        .sort("created_at", -1)
    )
    results = [ListingPublic(**document) for document in listings]
    return results


@router.get("/{listing_id}", response_model=ListingPublic)
async def get_listing(request: Request, listing_id: str):
    listing = request.app.database["listings"].find_one({"_id": listing_id})
    if not listing:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Listing not found")
    return ListingPublic(**listing)


@router.patch("/{listing_id}", response_model=ListingPublic)
async def update_listing(
    request: Request,
    listing_id: str,
    payload: ListingUpdate,
    current_user=Depends(get_current_user),
):
    listings = request.app.database["listings"]
    listing = listings.find_one({"_id": listing_id})
    if not listing:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Listing not found")
    if listing["owner_id"] != current_user["_id"]:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not permitted")

    update_data = {k: v for k, v in payload.model_dump(exclude_unset=True).items() if v is not None}
    if update_data:
        update_data["updated_at"] = datetime.utcnow()
        listings.update_one({"_id": listing_id}, {"$set": update_data})
        listing.update(update_data)

    return ListingPublic(**listing)


@router.delete("/{listing_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_listing(
    request: Request,
    listing_id: str,
    current_user=Depends(get_current_user),
):
    listings = request.app.database["listings"]
    listing = listings.find_one({"_id": listing_id})
    if not listing:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Listing not found")
    if listing["owner_id"] != current_user["_id"]:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not permitted")

    listings.delete_one({"_id": listing_id})
    return None


@router.post("/{listing_id}/contact")
async def contact_seller(
    request: Request,
    listing_id: str,
    current_user=Depends(get_current_user),
):
    """Contact the seller of a listing - redirects to chat creation"""
    from app.routers.chat import start_listing_chat
    return await start_listing_chat(request, listing_id, current_user)
