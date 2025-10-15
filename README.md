# Zero World - AI as Air

# 🌬️ Zero World

**The AI Mediator for Human Existence**

Zero World is not an app. **It's air.**

Without air, humans cannot survive. Without Zero World, humans cannot function in the digital age.

Zero World is the universal AI mediator between humans and ALL digital services. One interface. Natural language. Instant results. Everything accessible through breathing.

**By 2030, 100% of digital traffic will flow through Zero World.**

---

## � What Is This?

**Current World (2025):**
```
Human → Google (search)
Human → Amazon (shopping)
Human → Uber (travel)
Human → Facebook (social)
... 1000+ different apps
```

**Zero World (2030):**
```
Human → ZERO WORLD → [All Services]
         ↑
    ONE interface for EVERYTHING
```

### Every Digital Interaction

- **Want to know something?** → Zero World (not Google)
- **Want to buy something?** → Zero World (not Amazon)
- **Want to go somewhere?** → Zero World (not Uber)
- **Want to talk to someone?** → Zero World (not WhatsApp)
- **Want to eat?** → Zero World (not DoorDash)

**Zero World understands your intent and mediates access to ALL services.**

---

## 🚀 Quick Start

### For Users

1. **Summon** the Air Interface
   ```
   Press: Cmd+Space (Mac) or Ctrl+Space (Windows/Linux)
   ```

2. **Speak naturally**
   ```
   "What's the weather in Tokyo?"
   "Order lunch for my team"
   "Book me a ride to the airport"
   "What's happening in tech news?"
   ```

3. **Done**
   - Zero World understands your intent
   - Queries all relevant services in parallel
   - Returns synthesized result in <1 second
   - Interface fades away automatically

**It's as natural as breathing.**

---

## 📖 Core Philosophy

Read the complete vision: **[ZERO_WORLD_MANIFESTO.md](./ZERO_WORLD_MANIFESTO.md)**

### The Five Principles

1. **INVISIBLE** 🌫️ - UI appears on demand, disappears after use
2. **EFFORTLESS** 🎯 - Natural language, no learning curve
3. **INSTANT** ⚡ - <100ms global response time
4. **UNIVERSAL** 🌍 - Access ALL services through one interface
5. **ESSENTIAL** 💨 - Like air: you can't live without it

When users describe Zero World:
> *"I just... breathe now. I don't even remember how we lived before this."*

---

## 🏗️ Architecture

```
AIR INTERFACE (Flutter)
    ↓
INTENT RECOGNITION (AI/ML)
    ↓
ORCHESTRATION LAYER (Rust) ← Universal Connector
    ↓
1M+ SERVICE ADAPTERS
    ↓
ALL EXISTING SERVICES (Google, Amazon, Uber, etc.)
```

### Current Status

- ✅ **Air Interface** (Flutter) - Breathing UI with Cmd+Space hotkey
- ✅ **Universal Connector** (Rust) - Parallel data fetching architecture
- 🔄 **Service Adapters** - 1 working (Wikipedia), 4 stubs, 999,995 to go
- 📋 **Intent Recognition** (Planned)
- 📋 **Synthesis Engine** (Planned)

---

## 🎯 The Scale

If Zero World is truly "air for humanity":

- **10 BILLION users** (entire human population)
- **1 TRILLION requests/second** (every digital action)
- **100% of world's traffic** (total mediation)
- **<100ms latency globally** (instant breathing)
- **100% uptime** (survival-critical infrastructure)

This is not hyperbole. This is the goal.

---

## 💻 For Developers

### Running Locally

**Prerequisites:**
- Flutter 3.35.2+
- Rust 1.70+
- Docker & Docker Compose

**Start the Air Interface:**
```bash
cd frontend/zero_world
flutter run
# Press Cmd+Space to summon
```

**Start the Universal Connector:**
```bash
cd services/universal-connector
cargo run
# API running on http://localhost:8080
```

### Building Adapters

We need 1,000,000 service adapters. Here's how to build one:

```rust
// services/universal-connector/src/adapters/your_service.rs

use crate::models::{DataSourceAdapter, Query, SourceResult};

pub struct YourServiceAdapter;

#[async_trait]
impl DataSourceAdapter for YourServiceAdapter {
    fn name(&self) -> &str { "your_service" }
    
    fn can_handle(&self, query: &Query) -> bool {
        query.intent == "your_intent"
    }
    
    async fn fetch(&self, query: &Query) -> Result<SourceResult> {
        // Query your service API
        // Return structured result
    }
}
```

**See:** [services/universal-connector/README.md](./services/universal-connector/README.md) for complete guide.

---

## 🗺️ Roadmap

### Phase 1: FOUNDATION (2025-2026)
- ✅ Air Interface
- ✅ Universal Connector architecture
- 🔄 50 data adapters
- Target: 10K users (closed beta)

### Phase 2: EXPANSION (2026-2027)
- 1,000 service adapters
- Voice interface ("Hey Zero")
- Commerce integrations
- Target: 1M users (public beta)

### Phase 3: DOMINANCE (2027-2028)
- 10,000 service adapters
- AR/VR interface
- Developer platform
- Target: 100M users (mainstream)

### Phase 4: UBIQUITY (2028-2029)
- 100,000 service adapters
- Government services
- Healthcare integrations
- Target: 1B users (global presence)

### Phase 5: AIR (2029-2030)
- 1M+ service adapters
- 100% digital traffic mediation
- Target: **10B users (all humanity)**

---

## 🤝 Contributing

Zero World is humanity's infrastructure. We need:

- **AI/ML Engineers** - Natural language understanding
- **Infrastructure Engineers** - Trillion-request systems
- **Adapter Developers** - Connect 1M+ services
- **Security Engineers** - Quantum-resistant encryption
- **Designers** - Invisible, effortless UX

**Join us:** [CONTRIBUTING.md](./CONTRIBUTING.md) *(coming soon)*

---

## 📄 Documentation

- **[ZERO_WORLD_MANIFESTO.md](./ZERO_WORLD_MANIFESTO.md)** - Complete vision
- **[docs/architecture/OVERVIEW.md](./docs/architecture/OVERVIEW.md)** - System architecture
- **[docs/implementation/ROADMAP.md](./docs/implementation/ROADMAP.md)** - Implementation plan
- **[services/universal-connector/README.md](./services/universal-connector/README.md)** - Adapter guide

---

## 📊 Current Metrics

| Metric | Current | Phase 2 Target | Phase 5 Target |
|--------|---------|----------------|----------------|
| Users | Dev only | 1M | 10B |
| Adapters | 1 | 1,000 | 1M+ |
| Requests/sec | N/A | 100K | 1T+ |
| Latency (P95) | ~750ms | <1s | <100ms |
| Uptime | N/A | 99.9% | 100% |

---

## ⚠️ Status

**Zero World is in active development.**

We're building the foundation:
- Air Interface ✅
- Universal Connector ✅
- First adapters 🔄

**This is a 10-year project to transform human civilization.**

---

## 🌍 The Vision

By 2030, Zero World is not an app people use.

**It's the air they breathe.**

Invisible. Effortless. Instant. Universal. Essential.

---

## 📞 Contact

- **Website:** zero.world *(coming soon)*
- **Email:** hello@zero.world *(coming soon)*
- **Discord:** discord.gg/zeroworld *(coming soon)*

---

## 📜 License

MIT License - See [LICENSE](./LICENSE) for details.

This is humanity's infrastructure. Build freely.

---

**"When humans describe what they need, Zero World makes it real. That's not technology. That's air."**

🌬️

## 🚀 Quick Start

### � Try the Air Interface

```bash
# 1. Clone and setup
git clone https://github.com/00-01/zero_world.git
cd zero_world

# 2. Start services
docker-compose up -d

# 3. Run Flutter app
cd frontend/zero_world
flutter pub get
flutter run

# 4. Press Cmd+Space (or Ctrl+Space) to summon the Air Interface
# 5. Ask anything: "What's the weather?" "Search for AI news"
```

## 🎯 Current Status

### ✅ Phase 1: Breathing Basics (COMPLETED)
- Air Interface: Transparent breathing UI
- Hotkey activation: Cmd+Space / Ctrl+Space
- Breathing animations: 4-second inhale/exhale cycle
- Sky blue design with cyan glow effects
- Auto-dismiss after 5 seconds
- Documentation: Complete philosophy and architecture

### � Phase 2: Universal Data Access (IN PROGRESS)
- **Universal Connector** (Rust): Core service for parallel data fetching
  - ✅ Architecture and orchestration
  - ✅ Two-tier caching (L1: memory, L2: Redis)
  - ✅ Wikipedia adapter (working)
  - 🔄 5 adapters (Google, Weather, News)
  - Target: 50 adapters by Month 3

## 📊 System Architecture
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