# Service Template Generator

This directory contains templates for creating new microservices across different programming languages.

## Quick Start

```bash
# Generate a new Go service
./generate-service.sh --name user-profile-service --language go --port 8080

# Generate a new Rust service
./generate-service.sh --name real-time-messaging --language rust --port 8081

# Generate a new Java service
./generate-service.sh --name payment-processing --language java --port 8082
```

## Service Structure

Each generated service includes:

```
service-name/
├── README.md                    # Service documentation
├── Dockerfile                   # Container image
├── docker-compose.yml           # Local development
├── .gitignore
├── .dockerignore
├── Makefile                     # Build commands
├── k8s/                         # Kubernetes manifests
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   ├── hpa.yaml
│   └── ingress.yaml
├── proto/                       # gRPC definitions
│   └── service.proto
├── src/                         # Source code
│   ├── main.{go|rs|java|py|ts}
│   ├── handlers/                # HTTP/gRPC handlers
│   ├── services/                # Business logic
│   ├── models/                  # Data models
│   ├── repositories/            # Database access
│   ├── middleware/              # Middleware (auth, logging, etc.)
│   └── config/                  # Configuration
├── tests/                       # Unit & integration tests
│   ├── unit/
│   └── integration/
├── scripts/                     # Build/deploy scripts
│   ├── build.sh
│   ├── test.sh
│   └── deploy.sh
└── docs/                        # Additional documentation
    ├── API.md
    ├── ARCHITECTURE.md
    └── DEPLOYMENT.md
```

## Language-Specific Templates

### Go (recommended for high-performance services)
- **Framework:** Gin / Echo / Fiber
- **Database:** GORM / sqlx
- **gRPC:** google.golang.org/grpc
- **Testing:** testify
- **Build time:** ~5 seconds
- **Binary size:** ~20 MB

### Rust (recommended for critical path services)
- **Framework:** Actix Web / Axum / Rocket
- **Database:** sqlx / Diesel
- **gRPC:** tonic
- **Testing:** cargo test
- **Build time:** ~2 minutes (first build)
- **Binary size:** ~15 MB

### Java (recommended for enterprise services)
- **Framework:** Spring Boot / Micronaut / Quarkus
- **Database:** Spring Data JPA / Hibernate
- **gRPC:** grpc-java
- **Testing:** JUnit 5 / Mockito
- **Build time:** ~30 seconds
- **JAR size:** ~50 MB

### Python (recommended for AI/ML services)
- **Framework:** FastAPI / Flask / Django
- **Database:** SQLAlchemy / Django ORM
- **gRPC:** grpcio
- **Testing:** pytest
- **Startup time:** ~1 second
- **Image size:** ~500 MB (with ML libraries)

### Node.js/TypeScript (recommended for I/O-bound services)
- **Framework:** Express / NestJS / Fastify
- **Database:** Prisma / TypeORM / Sequelize
- **gRPC:** @grpc/grpc-js
- **Testing:** Jest / Mocha
- **Startup time:** ~500 ms
- **Image size:** ~200 MB

## Standard Features (included in all templates)

### Observability
```
- Prometheus metrics endpoint (/metrics)
- Structured JSON logging
- Distributed tracing (OpenTelemetry)
- Health check endpoints (/health/live, /health/ready)
```

### Security
```
- JWT authentication
- Rate limiting
- CORS configuration
- Input validation
- SQL injection prevention
- XSS protection
```

### Configuration
```
- Environment variables
- Config files (YAML/JSON)
- Secrets management (Vault/AWS Secrets Manager)
- Feature flags
```

### Database
```
- Connection pooling
- Automatic retries
- Migration system
- Query optimization
- Read replicas support
```

### Messaging
```
- Kafka producer/consumer
- RabbitMQ support
- Message validation
- Dead letter queues
- Retry policies
```

### API
```
- RESTful HTTP endpoints
- gRPC endpoints
- GraphQL support (optional)
- API versioning
- Request/response validation
- Auto-generated OpenAPI docs
```

## Service Categories

### 1. User Management Services (50+ services)
```
- user-authentication
- user-profile
- user-preferences
- user-verification
- user-reputation
- user-badges
- user-activity
- user-recommendations
```

### 2. Chat & Messaging Services (100+ services)
```
- real-time-messaging
- message-persistence
- message-search
- message-moderation
- typing-indicators
- read-receipts
- presence-service
- notification-delivery
```

### 3. Data Processing Services (200+ services)
```
- stream-processor
- batch-processor
- data-aggregator
- analytics-engine
- ml-inference
- image-processor
- video-transcoder
- search-indexer
```

### 4. Infrastructure Services (50+ services)
```
- api-gateway
- service-discovery
- config-server
- secret-manager
- load-balancer
- rate-limiter
- circuit-breaker
- cache-manager
```

## Development Guidelines

### Code Structure
```go
// Example: Go service handler
package handlers

import (
    "context"
    "github.com/gin-gonic/gin"
    "zero-world/services/user-profile/models"
    "zero-world/services/user-profile/services"
)

type UserHandler struct {
    service services.UserService
}

func NewUserHandler(service services.UserService) *UserHandler {
    return &UserHandler{service: service}
}

func (h *UserHandler) GetUser(c *gin.Context) {
    ctx := c.Request.Context()
    userID := c.Param("id")
    
    user, err := h.service.GetUser(ctx, userID)
    if err != nil {
        c.JSON(500, gin.H{"error": err.Error()})
        return
    }
    
    c.JSON(200, user)
}
```

### Testing
```go
// Example: Unit test
func TestGetUser(t *testing.T) {
    mockService := &MockUserService{}
    handler := NewUserHandler(mockService)
    
    // Setup
    w := httptest.NewRecorder()
    c, _ := gin.CreateTestContext(w)
    c.Params = []gin.Param{{Key: "id", Value: "123"}}
    
    mockService.On("GetUser", mock.Anything, "123").
        Return(&models.User{ID: "123", Name: "Test"}, nil)
    
    // Execute
    handler.GetUser(c)
    
    // Assert
    assert.Equal(t, 200, w.Code)
    mockService.AssertExpectations(t)
}
```

### Docker Build
```dockerfile
# Multi-stage build example (Go)
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY go.* ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/main .
EXPOSE 8080
CMD ["./main"]
```

## Scaling Strategy

### Horizontal Scaling
```yaml
# Auto-scaling based on metrics
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
spec:
  minReplicas: 10
  maxReplicas: 10000
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Pods
    pods:
      metric:
        name: http_requests_per_second
      target:
        type: AverageValue
        averageValue: "1000"
```

### Vertical Scaling
```
Small:    1 CPU, 2 GB RAM    (10-100 req/s)
Medium:   4 CPU, 8 GB RAM    (100-1K req/s)
Large:    16 CPU, 32 GB RAM  (1K-10K req/s)
XLarge:   64 CPU, 128 GB RAM (10K-100K req/s)
```

## Performance Targets

```
Latency:
- P50: < 10ms
- P95: < 50ms
- P99: < 100ms

Throughput:
- 10,000+ requests/second per instance
- 1,000,000+ requests/second per service (100 instances)

Availability:
- 99.99% uptime (52 minutes downtime/year)
- Zero-downtime deployments
- Automatic failover < 30 seconds
```

## Deployment Process

### Blue-Green Deployment
```bash
# Deploy new version (green)
kubectl apply -f k8s/deployment-green.yaml

# Wait for health checks
kubectl wait --for=condition=ready pod -l version=green

# Switch traffic
kubectl patch service user-profile -p '{"spec":{"selector":{"version":"green"}}}'

# Remove old version (blue)
kubectl delete deployment user-profile-blue
```

### Canary Deployment
```yaml
# 10% of traffic to canary
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: user-profile
spec:
  hosts:
  - user-profile
  http:
  - match:
    - headers:
        canary:
          exact: "true"
    route:
    - destination:
        host: user-profile
        subset: canary
  - route:
    - destination:
        host: user-profile
        subset: stable
      weight: 90
    - destination:
        host: user-profile
        subset: canary
      weight: 10
```

## Monitoring

### Metrics to Track
```
Application Metrics:
- Request rate
- Error rate
- Latency (P50, P95, P99)
- Active connections
- Queue depth

System Metrics:
- CPU usage
- Memory usage
- Disk I/O
- Network I/O

Business Metrics:
- Active users
- Transactions/second
- Revenue/second
```

### Alerting Rules
```yaml
groups:
- name: service_alerts
  rules:
  - alert: HighErrorRate
    expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
    for: 5m
    annotations:
      summary: "High error rate detected"
  
  - alert: HighLatency
    expr: histogram_quantile(0.95, http_request_duration_seconds) > 0.1
    for: 5m
    annotations:
      summary: "95th percentile latency > 100ms"
```

---

**Use these templates to rapidly create 10,000+ microservices for trillion-scale deployment.**
