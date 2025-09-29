# Zero World 🌍

A comprehensive full-stack marketplace application built with FastAPI backend, Flutter frontend, and MongoDB database. Zero World provides secure user authentication, real-time chat, community features, and complete listing management with CRUD operations.

## 🚀 Features

- **User Authentication** - JWT-based secure authentication system
- **Listings Management** - Full CRUD operations for marketplace listings  
- **Real-time Chat** - WebSocket-based chat system for listings
- **Community Posts** - Social features with posts and comments
- **WAN Database Access** - External MongoDB access with secure credentials
- **SSL Support** - HTTPS with custom certificates
- **Docker Deployment** - Complete containerized setup
- **Security** - Environment variable protection and secure configuration
- **Community**: Posts, comments, and user interactions
- **Security**: HTTPS encryption, JWT authentication, rate limiting
- **Responsive Design**: Modern Material Design UI with Flutter Web

## 🏗️ Architecture

- **Backend**: FastAPI (Python 3.9+) with MongoDB
- **Frontend**: Flutter web application
- **Database**: MongoDB with authentication
- **Reverse Proxy**: Nginx with SSL termination
- **Deployment**: Docker Compose

## 📁 Project Structure

```
zero_world/
├── backend/              # FastAPI backend
│   ├── app/
│   │   ├── crud/        # Database operations
│   │   ├── routers/     # API endpoints
│   │   ├── schemas/     # Pydantic models
│   │   └── core/        # Security and config
│   ├── Dockerfile
│   └── requirements.txt
├── frontend/            # Flutter web app
│   └── zero_world/
├── nginx/               # Nginx configuration
├── scripts/             # Setup and utility scripts
├── docs/                # Documentation
├── backup/              # Backup files
└── docker-compose.yml   # Container orchestration
```

## 🔧 Quick Start

### Prerequisites
- Docker and Docker Compose
- Domain name (optional for local development)

### Setup
1. Clone the repository
2. Copy environment file:
   ```bash
   cp .env.example .env
   ```
3. Start the application:
   ```bash
   docker-compose up -d
   ```

### Access the Application
- **Website**: https://www.zn-01.com (or your domain)
- **API**: https://www.zn-01.com/api/
- **Health Check**: https://www.zn-01.com/health

### New Features Added
1. **Complete Login System**: 
   - User registration and authentication
   - JWT token-based security
   - Profile management
   
2. **Listing Chat Feature**:
   - Click on any listing to view details
   - "Contact Seller" button starts a chat about that specific listing
   - System messages show listing context in chat
   - Only works for other users' listings (not your own)

## 🔐 SSL Certificate

The application uses self-signed SSL certificates by default. For production:

1. **Self-signed** (current): Works immediately with browser warning
2. **Cloudflare**: Recommended for production (see `docs/ssl_option_1_cloudflare.md`)
3. **Let's Encrypt**: Free trusted certificates (see setup scripts)

## 🛠️ Development

### Backend Development
```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Frontend Development
```bash
cd frontend/zero_world
flutter pub get
flutter run -d web-server --web-port 3000
```

### Database Access
**MongoDB Connection:**
- **Host**: localhost:27017
- **Username**: root
- **Password**: example
- **Database**: zero_world
- **Connection String**: `mongodb://root:example@localhost:27017/zero_world?authSource=admin`

**MongoDB Compass Setup:**
1. Install MongoDB Compass
2. Use connection string above
3. Browse collections: users, listings, chats, messages, community_posts

See `docs/mongodb_compass_setup.md` for detailed instructions.

## 📚 API Documentation

Once running, visit:
- **Swagger UI**: https://www.zn-01.com/api/docs
- **ReDoc**: https://www.zn-01.com/api/redoc

## 🔧 Available Scripts

Located in `scripts/` directory:
- `setup_self_signed_ssl.sh`: Set up self-signed SSL certificates
- `setup_manual_ssl.sh`: Set up Let's Encrypt certificates
- `check_site_access.sh`: Test site accessibility

## 🚀 Deployment

The application is containerized and ready for production deployment:

1. **Local**: Use docker-compose (current setup)
2. **Cloud**: Deploy containers to AWS, GCP, or Azure
3. **Kubernetes**: Scale with k8s manifests (can be generated)

## 🔒 Security Features

- JWT authentication with secure tokens
- Rate limiting (API: 10 req/s, Web: 30 req/s)
- HTTPS encryption with modern TLS
- Security headers (XSS, CSRF protection)
- Input validation with Pydantic
- Password hashing with bcrypt

## 📖 Documentation

See `docs/` directory for detailed documentation:
- Setup guides
- SSL configuration options
- API documentation
- Troubleshooting guides

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License.

## 🔧 Maintenance

### Regular Tasks
- Monitor SSL certificate expiration
- Update dependencies regularly
- Review logs for security issues
- Backup database regularly

### Troubleshooting
- Check `docker-compose logs` for issues
- Verify domain DNS settings
- Test SSL certificates
- Monitor resource usage

---

Built with ❤️ for the Zero World community