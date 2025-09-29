from datetime import datetime, timedelta, timezone
from typing import Any, Dict, Optional

import jwt
from fastapi import HTTPException, status
from passlib.context import CryptContext

from app.config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def get_jwt_secret() -> str:
    return settings.JWT_SECRET_KEY


def get_jwt_algorithm() -> str:
    return settings.JWT_ALGORITHM


def get_access_token_expiry_minutes() -> int:
    return settings.ACCESS_TOKEN_EXPIRE_MINUTES


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)


def create_access_token(
    subject: str,
    additional_claims: Optional[Dict[str, Any]] = None,
    expires_delta: Optional[timedelta] = None,
) -> str:
    to_encode: Dict[str, Any] = {"sub": subject}
    if additional_claims:
        to_encode.update(additional_claims)

    expire = datetime.now(timezone.utc) + (
        expires_delta
        if expires_delta is not None
        else timedelta(minutes=get_access_token_expiry_minutes())
    )
    to_encode.update({"exp": expire})
    token = jwt.encode(to_encode, get_jwt_secret(), algorithm=get_jwt_algorithm())
    return token


def decode_token(token: str) -> Dict[str, Any]:
    try:
        payload = jwt.decode(token, get_jwt_secret(), algorithms=[get_jwt_algorithm()])
    except jwt.ExpiredSignatureError as exc:  # type: ignore[attr-defined]
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token expired",
            headers={"WWW-Authenticate": "Bearer"},
        ) from exc
    except jwt.InvalidTokenError as exc:  # type: ignore[attr-defined]
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        ) from exc

    return payload
