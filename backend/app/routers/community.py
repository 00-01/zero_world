from datetime import datetime
import uuid
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, Request, status

from app.dependencies import get_current_user
from app.schemas.community import (
    CommunityCommentCreate,
    CommunityCommentPublic,
    CommunityPostCreate,
    CommunityPostPublic,
)

router = APIRouter(prefix="/community", tags=["community"])


@router.post("/posts", response_model=CommunityPostPublic, status_code=status.HTTP_201_CREATED)
async def create_post(
    request: Request,
    payload: CommunityPostCreate,
    current_user=Depends(get_current_user),
):
    posts = request.app.database["community_posts"]
    post_document = {
        "_id": str(uuid.uuid4()),
        "author_id": current_user["_id"],
        "title": payload.title,
        "content": payload.content,
        "tags": payload.tags,
        "created_at": datetime.utcnow(),
        "updated_at": None,
        "like_count": 0,
    }
    posts.insert_one(post_document)
    return CommunityPostPublic(**post_document)


@router.get("/posts", response_model=List[CommunityPostPublic])
async def list_posts(request: Request, tag: Optional[str] = None, limit: int = 50, skip: int = 0):
    query = {}
    if tag:
        query["tags"] = tag

    posts_cursor = (
        request.app.database["community_posts"]
        .find(query)
        .skip(skip)
        .limit(max(1, min(limit, 100)))
        .sort("created_at", -1)
    )
    return [CommunityPostPublic(**doc) for doc in posts_cursor]


@router.post(
    "/posts/{post_id}/comments",
    response_model=CommunityCommentPublic,
    status_code=status.HTTP_201_CREATED,
)
async def add_comment(
    request: Request,
    post_id: str,
    payload: CommunityCommentCreate,
    current_user=Depends(get_current_user),
):
    posts = request.app.database["community_posts"]
    post = posts.find_one({"_id": post_id})
    if not post:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Post not found")

    comments = request.app.database["community_comments"]
    comment_document = {
        "_id": str(uuid.uuid4()),
        "post_id": post_id,
        "author_id": current_user["_id"],
        "content": payload.content,
        "created_at": datetime.utcnow(),
    }
    comments.insert_one(comment_document)
    return CommunityCommentPublic(**comment_document)


@router.get("/posts/{post_id}/comments", response_model=List[CommunityCommentPublic])
async def list_comments(request: Request, post_id: str):
    comments_cursor = (
        request.app.database["community_comments"]
        .find({"post_id": post_id})
        .sort("created_at", 1)
    )
    return [CommunityCommentPublic(**doc) for doc in comments_cursor]
