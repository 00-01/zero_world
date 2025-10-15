"""
Enhanced listings router demonstrating CRUD usage.
This is an example of how to integrate the new CRUD functions.
"""
from datetime import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Request, status, Query

from app.dependencies import get_current_user
from app.schemas.listing import ListingCreate, ListingPublic, ListingUpdate
from app.crud.service import get_listing_crud
from app.crud.listing import CRUDListing

router = APIRouter(prefix="/listings", tags=["listings"])


@router.post("/", response_model=ListingPublic, status_code=status.HTTP_201_CREATED)
async def create_listing(
    payload: ListingCreate,
    current_user=Depends(get_current_user),
    listing_crud: CRUDListing = Depends(get_listing_crud)
):
    """Create a new listing using CRUD functions."""
    listing = listing_crud.create_listing(
        listing_in=payload,
        owner_id=current_user["_id"]
    )
    return ListingPublic(**listing)


@router.get("/", response_model=List[ListingPublic])
async def list_listings(
    limit: int = Query(50, le=100, ge=1),
    skip: int = Query(0, ge=0),
    category: Optional[str] = Query(None),
    location: Optional[str] = Query(None),
    min_price: Optional[float] = Query(None, ge=0),
    max_price: Optional[float] = Query(None, ge=0),
    listing_crud: CRUDListing = Depends(get_listing_crud)
):
    """Get listings with advanced filtering."""
    listings = listing_crud.get_active_listings(
        skip=skip,
        limit=limit,
        category=category,
        location=location,
        min_price=min_price,
        max_price=max_price
    )
    return [ListingPublic(**listing) for listing in listings]


@router.get("/search", response_model=List[ListingPublic])
async def search_listings(
    q: str = Query(..., min_length=2),
    limit: int = Query(50, le=100, ge=1),
    skip: int = Query(0, ge=0),
    listing_crud: CRUDListing = Depends(get_listing_crud)
):
    """Search listings by text query."""
    listings = listing_crud.search_listings(
        query=q,
        skip=skip,
        limit=limit
    )
    return [ListingPublic(**listing) for listing in listings]


@router.get("/categories", response_model=List[str])
async def get_categories(listing_crud: CRUDListing = Depends(get_listing_crud)):
    """Get all available categories."""
    return listing_crud.get_categories()


@router.get("/popular", response_model=List[ListingPublic])
async def get_popular_listings(
    limit: int = Query(10, le=50, ge=1),
    listing_crud: CRUDListing = Depends(get_listing_crud)
):
    """Get most viewed listings."""
    listings = listing_crud.get_popular_listings(limit=limit)
    return [ListingPublic(**listing) for listing in listings]


@router.get("/recent", response_model=List[ListingPublic])
async def get_recent_listings(
    limit: int = Query(10, le=50, ge=1),
    listing_crud: CRUDListing = Depends(get_listing_crud)
):
    """Get most recent listings."""
    listings = listing_crud.get_recent_listings(limit=limit)
    return [ListingPublic(**listing) for listing in listings]


@router.get("/my-listings", response_model=List[ListingPublic])
async def get_my_listings(
    limit: int = Query(50, le=100, ge=1),
    skip: int = Query(0, ge=0),
    include_inactive: bool = Query(False),
    current_user=Depends(get_current_user),
    listing_crud: CRUDListing = Depends(get_listing_crud)
):
    """Get current user's listings."""
    listings = listing_crud.get_user_listings(
        owner_id=current_user["_id"],
        skip=skip,
        limit=limit,
        include_inactive=include_inactive
    )
    return [ListingPublic(**listing) for listing in listings]


@router.get("/{listing_id}", response_model=ListingPublic)
async def get_listing(
    listing_id: str,
    listing_crud: CRUDListing = Depends(get_listing_crud)
):
    """Get a specific listing and increment view count."""
    listing = listing_crud.get(listing_id)
    if not listing:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, 
            detail="Listing not found"
        )
    
    # Increment view count
    listing_crud.increment_view_count(listing_id=listing_id)
    
    return ListingPublic(**listing)


@router.patch("/{listing_id}", response_model=ListingPublic)
async def update_listing(
    listing_id: str,
    payload: ListingUpdate,
    current_user=Depends(get_current_user),
    listing_crud: CRUDListing = Depends(get_listing_crud)
):
    """Update a listing."""
    listing = listing_crud.update_listing(
        listing_id=listing_id,
        listing_update=payload,
        owner_id=current_user["_id"]
    )
    
    if not listing:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, 
            detail="Listing not found or not owned by user"
        )
    
    return ListingPublic(**listing)


@router.patch("/{listing_id}/deactivate", response_model=ListingPublic)
async def deactivate_listing(
    listing_id: str,
    current_user=Depends(get_current_user),
    listing_crud: CRUDListing = Depends(get_listing_crud)
):
    """Deactivate a listing (soft delete)."""
    listing = listing_crud.deactivate_listing(
        listing_id=listing_id,
        owner_id=current_user["_id"]
    )
    
    if not listing:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, 
            detail="Listing not found or not owned by user"
        )
    
    return ListingPublic(**listing)


@router.patch("/{listing_id}/reactivate", response_model=ListingPublic)
async def reactivate_listing(
    listing_id: str,
    current_user=Depends(get_current_user),
    listing_crud: CRUDListing = Depends(get_listing_crud)
):
    """Reactivate a listing."""
    listing = listing_crud.reactivate_listing(
        listing_id=listing_id,
        owner_id=current_user["_id"]
    )
    
    if not listing:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, 
            detail="Listing not found or not owned by user"
        )
    
    return ListingPublic(**listing)


@router.delete("/{listing_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_listing(
    listing_id: str,
    current_user=Depends(get_current_user),
    listing_crud: CRUDListing = Depends(get_listing_crud)
):
    """Delete a listing permanently."""
    # Check if listing exists and belongs to user
    listing = listing_crud.get(listing_id)
    if not listing:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, 
            detail="Listing not found"
        )
    
    if listing.get("owner_id") != current_user["_id"]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, 
            detail="Not permitted"
        )
    
    # For production, you might want to use deactivate instead of delete
    success = listing_crud.delete(id=listing_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete listing"
        )
    
    return None