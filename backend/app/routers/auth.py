from datetime import datetime
import uuid

from fastapi import APIRouter, Depends, HTTPException, Request, status
from fastapi.security import OAuth2PasswordRequestForm
from pymongo.errors import DuplicateKeyError

from app.core.security import create_access_token, get_password_hash, verify_password
from app.dependencies import get_current_user
from app.schemas.user import Token, UserCreate, UserPublic

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register", response_model=UserPublic, status_code=status.HTTP_201_CREATED)
async def register_user(request: Request, payload: UserCreate):
    users = request.app.database["users"]
    user_document = {
        "_id": str(uuid.uuid4()),
        "name": payload.name,
        "email": payload.email.lower(),
        "hashed_password": get_password_hash(payload.password),
        "created_at": datetime.utcnow(),
        "bio": None,
        "avatar_url": None,
    }

    try:
        users.insert_one(user_document)
    except DuplicateKeyError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered",
        ) from exc

    user_document.pop("hashed_password", None)
    return UserPublic(**user_document)


@router.post("/login", response_model=Token)
async def login_user(request: Request, form_data: OAuth2PasswordRequestForm = Depends()):
    users = request.app.database["users"]
    user = users.find_one({"email": form_data.username.lower()})
    if not user or not verify_password(form_data.password, user.get("hashed_password", "")):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    access_token = create_access_token(user["_id"])
    return Token(access_token=access_token)


@router.get("/me", response_model=UserPublic)
async def get_profile(current_user=Depends(get_current_user)):
    return UserPublic(**current_user)
