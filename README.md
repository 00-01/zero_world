# Zero World - Super App Platform

> **Vision**: Building the next-generation super app to rival global tech giants. Designed for massive scale from day one.

## 🚀 Quick Start

### 📱 For Users - Download the App

**Coming Soon to:**
- 🤖 **Google Play Store** - Android devices
- 🍎 **Apple App Store** - iPhone & iPad
- 🌐 **Web App** - https://www.zn-01.com

**Current Access:**
- Web: https://www.zn-01.com
- API: https://www.zn-01.com/api

### 👨‍💻 For Developers - Setup

```bash
# 1. Clone the repository
git clone https://github.com/00-01/zero_world.git
cd zero_world

# 2. Set up environment
cp .env.example .env
# Edit .env with your configuration

# 3. Start services
docker-compose up -d

# 4. Build frontend
cd frontend/zero_world
flutter pub get
flutter build web
cd ../..

# 5. Build mobile apps (see MOBILE_APP_DEPLOYMENT.md)
./scripts/build_mobile_release.sh
```

## 📊 System Architecture

### Current (MVP Phase)
```
Internet → Nginx → Frontend (Flutter Web)
                 ↓ API Gateway
                 → Backend (FastAPI) → MongoDB
```

### Target (Google-Scale)
```
Internet → CDN → Load Balancer
                 ↓
         [API Gateway Cluster]
                 ↓
    ┌────────────┼────────────┐
    ↓            ↓            ↓
[Auth Service] [Listings] [Chat Service]
    ↓            ↓            ↓
[PostgreSQL]  [MongoDB]  [Redis + RabbitMQ]
```

## ✨ Core Features

### 🔴 Essential Services (Life-sustaining)
- **Food & Groceries** - Restaurant delivery, grocery shopping, meal planning
- **Healthcare** - Doctor consultations, telemedicine, pharmacy, emergency services
- **Financial Services** - Digital wallet, bill payments, loans, insurance, investments
- **Housing** - Buy/rent properties, roommate finder, home services
- **Transportation** - Ride booking, package delivery, public transit, car rental
- **Communication** - Messaging, voice/video calls, group chats, channels

### 🟡 Daily Life Services
- **Employment** - Job search, freelancing, professional networking
- **Education** - Online courses, tutoring, certifications
- **Government Services** - IDs, passports, taxes, permits, legal services
- **Shopping & Marketplace** - Buy/sell anything, auctions, barter/trade
- **Utilities** - All bill payments and service management

### 🟢 Social & Community
- **Social Networking** - Posts, stories, groups, pages, events
- **Dating & Relationships** - Matching, events, relationship advice
- **Entertainment** - Movies, concerts, sports, streaming, gaming, news
- **Travel & Tourism** - Flights, hotels, visas, travel guides
- **Pet Care** - Veterinary, grooming, adoption, supplies
- **Charity & Volunteering** - Donations, fundraising, community service

### 🔵 Advanced Features
- **Universal Search** - Google-level search across all content
- **AI Recommendations** - Personalized content and suggestions
- **Business Tools** - Analytics, advertising, customer management
- **Premium Features** - Subscriptions, memberships, loyalty programs

## 🏗️ Architecture

### Technology Stack
- **Frontend**: Flutter 3.35.2 (Web, iOS, Android, Desktop)
- **Backend**: FastAPI (Python 3.9+) with async support
- **Database**: MongoDB with authentication
- **Reverse Proxy**: Nginx with SSL/TLS
- **Deployment**: Docker Compose multi-container setup
- **State Management**: Provider pattern
- **Security**: JWT authentication, end-to-end encryption

### Services Overview
- **17+ Major Categories** covering all aspects of human life
- **70+ Individual Services** from food delivery to government documents
- **100+ Features** including marketplace, social networking, payments
- **Complete Data Models** for essential services, marketplace, social features

## 📁 Project Structure

```
zero_world/
├── backend/                      # FastAPI backend
│   ├── app/
│   │   ├── crud/                # Database CRUD operations
│   │   ├── routers/             # API endpoints (auth, chat, community, listings)
│   │   ├── schemas/             # Pydantic models
│   │   └── core/                # Security, config, dependencies
│   ├── Dockerfile
│   └── requirements.txt
├── frontend/                     # Flutter application
│   └── zero_world/
│       ├── lib/
│       │   ├── models/          # Data models (70+ models)
│       │   │   ├── essential_services.dart    # 20 life-critical services
│       │   │   ├── marketplace.dart           # Complete marketplace
│       │   │   ├── social_extended.dart       # Full social platform
│       │   │   └── platform_features.dart     # AI, search, ads, etc.
│       │   ├── screens/         # UI screens (17+ categories)
│       │   │   ├── services/    # Services hub and individual services
│       │   │   ├── social/      # Social networking features
│       │   │   └── home_screen.dart
│       │   ├── services/        # API communication
│       │   └── state/           # State management
│       ├── web/                 # Web-specific files
│       ├── pubspec.yaml
│       └── Dockerfile
├── nginx/                        # Nginx reverse proxy
│   ├── nginx.conf               # Server configuration
│   └── Dockerfile
├── mongodb/                      # MongoDB data persistence
├── scripts/                      # Automation scripts
│   ├── build/                   # Build scripts
│   ├── test/                    # Testing scripts
│   ├── deploy/                  # Deployment scripts
│   └── maintenance/             # Cleanup & maintenance
├── docs/                         # Documentation
│   ├── guides/                  # Setup & configuration guides
│   ├── testing/                 # Testing documentation
│   ├── deployment/              # Deployment guides
│   ├── mobile/                  # Mobile app deployment
│   ├── legal/                   # Privacy & Terms
│   └── archive/                 # Historical docs
└── docker-compose.yml            # Multi-container orchestration
```

## � Quick Start

### Prerequisites
- Docker and Docker Compose
- Flutter 3.35.2 (for local development)
- Domain name pointing to your server

### Using Quick Deploy Script (Recommended)
```bash
# Clean, build, and deploy everything
./scripts/deploy.sh
```

### Manual Deployment
1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd zero_world
   ```

2. **Build Flutter app**
   ```bash
   cd frontend/zero_world
   flutter pub get
   flutter build web --release
   cd ../../
   ```

3. **Start Docker containers**
   ```bash
   docker-compose up -d
   ```

4. **Verify deployment**
   ```bash
   docker-compose ps
   curl -skI https://zn-01.com/
   ```

### Access the Application
- **Website**: https://zn-01.com
- **Backend API**: https://zn-01.com/api/
- **API Docs**: https://zn-01.com/api/docs
- **Health Check**: https://zn-01.com/api/health

## 📱 Mobile App Publishing

### Build Mobile Releases
```bash
# Build both Android and iOS release versions
./scripts/build/build_mobile_release.sh
```

**For detailed instructions, see:** [docs/mobile/MOBILE_APP_DEPLOYMENT.md](docs/mobile/MOBILE_APP_DEPLOYMENT.md)

### App Store Requirements
- **Google Play Store**: $25 one-time fee, app signing key, privacy policy
- **Apple App Store**: $99/year, Mac computer, Apple Developer account
- **Both**: App icons, screenshots, store descriptions, content ratings

### Quick Build Commands
```bash
cd frontend/zero_world

# Android for Google Play Store
flutter build appbundle --release

# Android APK for testing
flutter build apk --release

# iOS for Apple App Store (macOS only)
flutter build ipa --release
```

## 🧹 Maintenance

### Clean cache and rebuild
```bash
./scripts/maintenance/final_cleanup.sh  # Deep cleanup
```

### View logs
```bash
docker logs zero_world_frontend_1 -f
docker logs zero_world_backend_1 -f
docker logs zero_world_nginx_1 -f
```

### Restart services
```bash
docker-compose restart
```

## 🔐 SSL Certificate

The application uses self-signed SSL certificates by default. For production:

1. **Self-signed** (current): Works immediately with browser warning
2. **Cloudflare**: Recommended for production
3. **Let's Encrypt**: Free trusted certificates (see [docs/deployment/](docs/deployment/))

For detailed HTTPS setup, see:
- [docs/deployment/HTTPS_QUICKSTART.md](docs/deployment/HTTPS_QUICKSTART.md)
- [docs/deployment/GET_CERTIFIED.md](docs/deployment/GET_CERTIFIED.md)

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

**Testing:**
- `scripts/test/test_android.sh` - Test Android app
- `scripts/test/test_android_emulator.sh` - Test with emulator
- `scripts/test/test_all_platforms.sh` - Cross-platform testing

**Deployment:**
- `scripts/deploy/setup_letsencrypt.sh` - Setup Let's Encrypt SSL
- `scripts/deploy/certify_app.sh` - Certificate management

**Maintenance:**
- `scripts/maintenance/final_cleanup.sh` - Deep cleanup
- `scripts/maintenance/cleanup_all.sh` - Full cleanup

See [scripts/README.md](scripts/README.md) for complete list.

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

See [docs/README.md](docs/README.md) for complete documentation index.

**Quick Links:**
- **Getting Started:** [QUICKSTART.md](QUICKSTART.md)
- **Testing Guide:** [docs/testing/TESTING_GUIDE.md](docs/testing/TESTING_GUIDE.md)
- **Cross-Platform Setup:** [docs/guides/CROSS_PLATFORM_SETUP.md](docs/guides/CROSS_PLATFORM_SETUP.md)
- **Mobile Deployment:** [docs/mobile/MOBILE_APP_DEPLOYMENT.md](docs/mobile/MOBILE_APP_DEPLOYMENT.md)
- **Architecture:** [docs/deployment/ARCHITECTURE.md](docs/deployment/ARCHITECTURE.md)

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