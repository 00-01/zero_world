# Project Structure

```
zero_world/
├── README.md                    # Project overview and setup instructions
├── LICENSE                     # MIT License
├── docker-compose.yml          # Container orchestration configuration
├── .env.example               # Environment variables template
├── .gitignore                 # Git ignore rules for security
│
├── backend/                   # FastAPI Python Backend
│   ├── Dockerfile            # Backend container configuration
│   ├── requirements.txt      # Python dependencies
│   └── app/
│       ├── main.py          # FastAPI application entry point
│       ├── config.py        # Application configuration
│       ├── dependencies.py  # Dependency injection
│       ├── core/
│       │   ├── __init__.py
│       │   └── security.py  # JWT and password handling
│       ├── routers/         # API route handlers
│       │   ├── auth.py     # Authentication endpoints
│       │   ├── listings.py # Listing CRUD operations
│       │   ├── chat.py     # Chat functionality
│       │   └── community.py # Community features
│       ├── schemas/         # Pydantic models
│       │   ├── __init__.py
│       │   ├── user.py     # User data models
│       │   ├── listing.py  # Listing data models
│       │   ├── chat.py     # Chat data models
│       │   ├── community.py # Community data models
│       │   └── common.py   # Shared models
│       └── crud/            # Database operations
│           ├── __init__.py
│           ├── base.py     # Base CRUD operations
│           ├── user.py     # User database operations
│           ├── listing.py  # Listing database operations
│           ├── chat.py     # Chat database operations
│           └── community.py # Community database operations
│
├── frontend/                 # Flutter Web Frontend
│   └── zero_world/
│       ├── lib/             # Dart source code
│       │   ├── main.dart   # Flutter app entry point
│       │   ├── app.dart    # App configuration
│       │   ├── models/     # Data models
│       │   ├── screens/    # UI screens
│       │   ├── widgets/    # Reusable UI components
│       │   ├── services/   # API and business logic
│       │   └── state/      # State management
│       ├── web/            # Web-specific files
│       ├── android/        # Android platform files
│       ├── ios/           # iOS platform files
│       ├── linux/         # Linux platform files
│       ├── macos/         # macOS platform files
│       ├── windows/       # Windows platform files
│       ├── pubspec.yaml   # Flutter dependencies
│       ├── Dockerfile     # Frontend container configuration
│       └── README.md      # Flutter-specific documentation
│
├── nginx/                   # Reverse Proxy Configuration
│   ├── Dockerfile          # Nginx container configuration
│   └── nginx.conf         # Nginx server configuration
│
├── mongodb/                # MongoDB Configuration
│   ├── mongod.conf        # MongoDB server configuration
│   └── init-mongo.sh      # Database initialization script
│
├── scripts/                # Utility Scripts
│   ├── manage_env.sh      # Environment variable management
│   ├── setup_wan_mongodb.sh # MongoDB WAN setup
│   ├── cleanup_database.sh # Database cleanup
│   ├── setup_ssl.sh       # SSL certificate setup
│   └── test_mongodb_compass.sh # MongoDB connection testing
│
├── docs/                   # Documentation
│   ├── security_configuration.md # Security setup guide
│   ├── mongodb_wan_access.md # MongoDB external access
│   ├── ssl_option_1_cloudflare.md # SSL setup with Cloudflare
│   ├── security_implementation_summary.md # Security overview
│   └── final_status.md    # Project status summary
│
└── certbot/               # SSL Certificate Management
    └── www/              # ACME challenge files
```

## Key Components

### Backend (FastAPI)
- **Authentication**: JWT-based user authentication and authorization
- **API Routes**: RESTful API endpoints for all features
- **Database**: MongoDB integration with PyMongo
- **Security**: Password hashing, JWT tokens, CORS handling
- **CRUD Operations**: Complete Create, Read, Update, Delete functionality

### Frontend (Flutter Web)
- **Responsive UI**: Modern web interface built with Flutter
- **State Management**: Efficient state handling for user interactions
- **API Integration**: HTTP client for backend communication
- **Authentication**: Login/register screens and token management
- **Real-time Features**: WebSocket support for chat functionality

### Infrastructure
- **Docker**: Containerized deployment with Docker Compose
- **Nginx**: Reverse proxy with SSL termination
- **MongoDB**: NoSQL database with authentication and external access
- **SSL**: HTTPS support with custom certificates
- **Environment Variables**: Secure configuration management

### Security Features
- **Environment Protection**: Sensitive data in environment variables
- **Git Security**: Comprehensive .gitignore for sensitive files
- **Database Security**: MongoDB authentication and access controls
- **SSL/TLS**: Encrypted communication
- **JWT Security**: Secure token-based authentication

## Development Workflow

1. **Environment Setup**: Configure `.env` file with secure credentials
2. **Database Initialization**: MongoDB with proper collections and indexes
3. **Container Deployment**: Docker Compose for all services
4. **SSL Configuration**: HTTPS setup for secure communication
5. **Testing**: API endpoints and frontend functionality
6. **Production**: WAN access and external database connectivity