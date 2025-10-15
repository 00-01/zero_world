import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pymongo import MongoClient
from pymongo.errors import OperationFailure, PyMongoError

from app.routers import auth, chat, community, listings, concierge

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
def startup_db_client():
    from app.config import settings
    
    mongodb_url = settings.get_mongodb_connection_string()
    app.mongodb_client = MongoClient(mongodb_url)
    app.database = app.mongodb_client[settings.MONGODB_DATABASE]
    print(f"Connected to the {settings.MONGODB_DATABASE} database!")

    try:
        # Test database connection first
        app.database.command("ismaster")
        print("Database connection verified successfully!")
        
        # Create indexes only if we have proper permissions
        app.database["users"].create_index("email", unique=True)
        app.database["chats"].create_index("participants_hash", unique=True)
        app.database["messages"].create_index([("chat_id", 1), ("created_at", 1)])
        app.database["listings"].create_index([("is_active", 1), ("created_at", -1)])
        app.database["community_posts"].create_index([("created_at", -1)])
        app.database["community_posts"].create_index("tags")
        
        # AI Concierge indexes
        app.database["conversation_states"].create_index("conversation_id", unique=True)
        app.database["conversation_states"].create_index([("user_id", 1), ("created_at", -1)])
        app.database["conversation_states"].create_index("session_id")
        app.database["orders"].create_index("order_id", unique=True)
        app.database["orders"].create_index([("user_id", 1), ("created_at", -1)])
        app.database["orders"].create_index("conversation_id")
        
        print("Database indexes created successfully!")
    except OperationFailure as exc:
        print(f"Database operation note: {exc}. Application will continue with existing indexes.")
    except Exception as exc:
        print(f"Database connection warning: {exc}. Some features may be limited.")
    
    # Initialize AI Concierge service providers
    try:
        from app.services.providers import service_registry
        print(f"AI Concierge service providers initialized: {len(service_registry._providers)} providers registered")
    except Exception as exc:
        print(f"Warning: Could not initialize service providers: {exc}")

@app.on_event("shutdown")
def shutdown_db_client():
    app.mongodb_client.close()

app.include_router(auth.router)
app.include_router(listings.router)
app.include_router(chat.router)
app.include_router(community.router)
app.include_router(concierge.router)

@app.get("/")
def read_root():
    return {"status": "ok"}


@app.get("/health", tags=["health"])
def healthcheck():
    try:
        app.database.command("ping")
        database_status = "ok"
    except PyMongoError:
        database_status = "error"

    return {"status": "ok", "database": database_status}
