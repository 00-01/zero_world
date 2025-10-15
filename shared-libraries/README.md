# Shared Libraries & Common Components

## Overview
Reusable libraries used across 10,000+ microservices to ensure consistency, reduce duplication, and accelerate development.

## Library Categories

### 1. Core Libraries (used by 95%+ of services)

#### Authentication & Authorization
```
Language: Go, Rust, Java, Python, Node.js
Features:
- JWT token validation
- OAuth2 client
- API key management
- Session management
- Role-based access control (RBAC)
- Permission checking
- Service-to-service authentication (mTLS)

Usage Example (Go):
```go
import "zero-world/libs/auth"

func main() {
    // Initialize auth client
    authClient := auth.NewClient(auth.Config{
        JWTSecret: os.Getenv("JWT_SECRET"),
        Issuer: "zero-world",
        Audience: "user-service",
    })
    
    // Validate token
    claims, err := authClient.ValidateToken(tokenString)
    if err != nil {
        return errors.Wrap(err, "invalid token")
    }
    
    // Check permission
    if !authClient.HasPermission(claims.UserID, "users.read") {
        return errors.New("permission denied")
    }
}
```

#### Database Access
```
Language: All
Features:
- Connection pooling
- Automatic retries with exponential backoff
- Read/write splitting
- Shard routing
- Query builder
- Transaction management
- Migration tools

Usage Example (Go):
```go
import "zero-world/libs/db"

func main() {
    // Initialize database pool
    pool := db.NewPool(db.Config{
        Driver: "postgres",
        Master: "postgres://master:5432/db",
        Replicas: []string{
            "postgres://replica1:5432/db",
            "postgres://replica2:5432/db",
        },
        MaxConnections: 100,
        MaxIdleTime: 5 * time.Minute,
    })
    
    // Read query (uses replica)
    var user User
    err := pool.Read().Where("id = ?", userID).First(&user).Error
    
    // Write query (uses master)
    err = pool.Write().Create(&user).Error
}
```

#### Caching
```
Language: All
Features:
- Multi-level caching (L1: local, L2: Redis, L3: CDN)
- Cache-aside pattern
- Write-through/Write-behind
- Cache invalidation
- TTL management
- Distributed locking

Usage Example (Go):
```go
import "zero-world/libs/cache"

func main() {
    // Initialize cache
    c := cache.NewMultiLevel(
        cache.L1(cache.LocalConfig{Size: 1000}),
        cache.L2(cache.RedisConfig{URL: "redis://localhost:6379"}),
    )
    
    // Get with cache-aside pattern
    var user User
    err := c.GetOrSet("user:123", &user, func() (interface{}, error) {
        return fetchUserFromDB(123)
    }, 5*time.Minute)
}
```

#### Messaging (Kafka, RabbitMQ)
```
Language: All
Features:
- Producer/Consumer abstractions
- Automatic retry and dead letter queues
- Message serialization (JSON, Protobuf, Avro)
- Partition management
- Consumer group coordination
- At-least-once/exactly-once delivery

Usage Example (Go):
```go
import "zero-world/libs/messaging"

func main() {
    // Initialize producer
    producer := messaging.NewKafkaProducer(messaging.Config{
        Brokers: []string{"kafka1:9092", "kafka2:9092"},
        Topic: "user-events",
        Compression: "snappy",
    })
    
    // Publish message
    err := producer.Publish(ctx, messaging.Message{
        Key: userID,
        Value: userEvent,
        Headers: map[string]string{
            "event-type": "user.created",
            "timestamp": time.Now().Format(time.RFC3339),
        },
    })
    
    // Initialize consumer
    consumer := messaging.NewKafkaConsumer(messaging.Config{
        Brokers: []string{"kafka1:9092"},
        Topic: "user-events",
        GroupID: "user-service",
    })
    
    // Consume messages
    consumer.Subscribe(func(msg messaging.Message) error {
        return processUserEvent(msg.Value)
    })
}
```

#### Logging
```
Language: All
Features:
- Structured logging (JSON)
- Log levels (DEBUG, INFO, WARN, ERROR, FATAL)
- Context propagation (request ID, user ID)
- Log aggregation (send to ELK/CloudWatch)
- PII masking
- Performance logging

Usage Example (Go):
```go
import "zero-world/libs/logging"

func main() {
    // Initialize logger
    log := logging.New(logging.Config{
        Level: logging.INFO,
        Output: "stdout",
        Format: "json",
    })
    
    // Structured logging with context
    log.WithContext(ctx).
        WithField("user_id", userID).
        WithField("action", "create_profile").
        WithField("duration_ms", elapsed.Milliseconds()).
        Info("User profile created")
    
    // Error logging with stack trace
    log.WithError(err).
        WithField("user_id", userID).
        Error("Failed to create user profile")
}
```

#### Metrics & Monitoring
```
Language: All
Features:
- Prometheus metrics (counters, gauges, histograms)
- Custom business metrics
- Automatic HTTP/gRPC instrumentation
- SLA tracking
- Alerting integration

Usage Example (Go):
```go
import "zero-world/libs/metrics"

func main() {
    // Initialize metrics
    m := metrics.New(metrics.Config{
        Namespace: "zero_world",
        Subsystem: "user_service",
    })
    
    // Counter
    m.Counter("requests_total").
        WithLabels(map[string]string{
            "method": "GET",
            "endpoint": "/users",
        }).
        Inc()
    
    // Histogram for latency
    timer := m.Histogram("request_duration_seconds").Start()
    defer timer.ObserveDuration()
    
    // Gauge for active connections
    m.Gauge("active_connections").Set(float64(activeConns))
}
```

#### Tracing
```
Language: All
Features:
- OpenTelemetry integration
- Distributed tracing
- Span creation and propagation
- Trace sampling
- Jaeger/Zipkin export

Usage Example (Go):
```go
import "zero-world/libs/tracing"

func main() {
    // Initialize tracer
    tracer := tracing.New(tracing.Config{
        ServiceName: "user-service",
        JaegerEndpoint: "http://jaeger:14268/api/traces",
        SampleRate: 0.1, // 10% sampling
    })
    
    // Create span
    span := tracer.StartSpan(ctx, "create_user")
    defer span.End()
    
    // Add attributes
    span.SetAttribute("user.id", userID)
    span.SetAttribute("user.email", email)
    
    // Propagate context
    ctx = span.Context()
    err := callAnotherService(ctx)
}
```

### 2. Service Communication Libraries

#### HTTP Client
```
Language: All
Features:
- Connection pooling
- Retry with exponential backoff
- Circuit breaker
- Timeout management
- Request/response logging
- Automatic service discovery

Usage Example (Go):
```go
import "zero-world/libs/httpclient"

func main() {
    client := httpclient.New(httpclient.Config{
        BaseURL: "http://user-service",
        Timeout: 10 * time.Second,
        MaxRetries: 3,
        CircuitBreaker: httpclient.CircuitBreakerConfig{
            FailureThreshold: 5,
            SuccessThreshold: 2,
            Timeout: 60 * time.Second,
        },
    })
    
    var user User
    err := client.Get(ctx, "/users/123", &user)
}
```

#### gRPC Client
```
Language: All
Features:
- Connection pooling
- Load balancing
- Retry policies
- Interceptors (auth, logging, metrics)
- Service mesh integration

Usage Example (Go):
```go
import "zero-world/libs/grpcclient"

func main() {
    conn := grpcclient.NewConnection(grpcclient.Config{
        Target: "user-service:9090",
        LoadBalancing: "round_robin",
        Interceptors: []grpc.UnaryClientInterceptor{
            grpcclient.AuthInterceptor(),
            grpcclient.LoggingInterceptor(),
            grpcclient.MetricsInterceptor(),
        },
    })
    defer conn.Close()
    
    client := pb.NewUserServiceClient(conn)
    resp, err := client.GetUser(ctx, &pb.GetUserRequest{UserId: "123"})
}
```

#### GraphQL Client
```
Language: All
Features:
- Query building
- Automatic batching
- Caching
- Error handling
- Schema validation

Usage Example (Go):
```go
import "zero-world/libs/graphql"

func main() {
    client := graphql.NewClient("https://api.zeroworld.com/graphql")
    
    query := `
        query GetUser($id: ID!) {
            user(id: $id) {
                id
                name
                email
            }
        }
    `
    
    var result struct {
        User User `json:"user"`
    }
    
    err := client.Query(ctx, query, map[string]interface{}{
        "id": "123",
    }, &result)
}
```

### 3. Data Processing Libraries

#### Stream Processing
```
Language: Go, Java
Features:
- Event sourcing
- CQRS pattern
- Windowing (tumbling, sliding, session)
- Aggregations
- State management

Usage Example (Go):
```go
import "zero-world/libs/streaming"

func main() {
    stream := streaming.New(streaming.Config{
        Source: kafka.NewSource("user-events"),
        Sink: kafka.NewSink("user-analytics"),
    })
    
    stream.
        Filter(func(e Event) bool { return e.Type == "purchase" }).
        Map(func(e Event) Event { return transformEvent(e) }).
        Window(streaming.TumblingWindow(5 * time.Minute)).
        Aggregate(func(events []Event) Event {
            return calculateMetrics(events)
        }).
        Process()
}
```

#### Batch Processing
```
Language: Python, Java
Features:
- Job scheduling
- Parallel processing
- Checkpoint/resume
- Error handling
- Data validation

Usage Example (Python):
```python
from zero_world.libs import batch

@batch.job(name="user_analytics")
def process_user_data():
    # Read from data lake
    df = batch.read_parquet("s3://data-lake/users/")
    
    # Transform
    df = df.filter(df.active == True)
    df = df.groupby("country").agg({"user_id": "count"})
    
    # Write results
    batch.write_to_database(df, "analytics.user_counts")

# Schedule job
batch.schedule(process_user_data, cron="0 2 * * *")
```

### 4. Security Libraries

#### Encryption
```
Language: All
Features:
- AES-256 encryption/decryption
- RSA key management
- Hashing (SHA-256, bcrypt, argon2)
- Digital signatures
- Key rotation

Usage Example (Go):
```go
import "zero-world/libs/crypto"

func main() {
    // Encrypt sensitive data
    encryptor := crypto.NewAES256(encryptionKey)
    encrypted, err := encryptor.Encrypt([]byte(sensitiveData))
    
    // Decrypt
    decrypted, err := encryptor.Decrypt(encrypted)
    
    // Hash password
    hasher := crypto.NewArgon2()
    hashed, err := hasher.Hash(password)
    
    // Verify password
    valid := hasher.Verify(password, hashed)
}
```

#### Rate Limiting
```
Language: All
Features:
- Token bucket algorithm
- Sliding window
- Distributed rate limiting (Redis)
- Per-user/Per-IP/Per-API key limits
- Custom rate limit strategies

Usage Example (Go):
```go
import "zero-world/libs/ratelimit"

func main() {
    limiter := ratelimit.New(ratelimit.Config{
        Backend: ratelimit.RedisBackend("redis://localhost:6379"),
        Limits: []ratelimit.Rule{
            {Key: "api_key", Rate: 1000, Per: time.Minute},
            {Key: "ip_address", Rate: 100, Per: time.Minute},
            {Key: "user_id", Rate: 10000, Per: time.Hour},
        },
    })
    
    // Check rate limit
    allowed, err := limiter.Allow(ctx, "api_key", apiKey)
    if !allowed {
        return errors.New("rate limit exceeded")
    }
}
```

### 5. Utility Libraries

#### Configuration Management
```
Language: All
Features:
- Environment variables
- Config files (YAML, JSON, TOML)
- Remote config (Consul, etcd)
- Hot reload
- Validation

Usage Example (Go):
```go
import "zero-world/libs/config"

type Config struct {
    Database struct {
        Host string `config:"DB_HOST" default:"localhost"`
        Port int    `config:"DB_PORT" default:"5432"`
    }
    Redis struct {
        URL string `config:"REDIS_URL" required:"true"`
    }
}

func main() {
    var cfg Config
    err := config.Load(&cfg, config.Options{
        Sources: []config.Source{
            config.EnvSource(),
            config.FileSource("config.yaml"),
            config.ConsulSource("http://consul:8500"),
        },
    })
}
```

#### Validation
```
Language: All
Features:
- Struct validation
- Custom validators
- Error messages
- Field-level validation
- Cross-field validation

Usage Example (Go):
```go
import "zero-world/libs/validator"

type CreateUserRequest struct {
    Email    string `validate:"required,email"`
    Password string `validate:"required,min=12,max=128"`
    Age      int    `validate:"required,gte=13,lte=120"`
}

func main() {
    v := validator.New()
    
    req := CreateUserRequest{
        Email: "user@example.com",
        Password: "weakpassword",
        Age: 25,
    }
    
    err := v.Validate(req)
    if err != nil {
        // Handle validation errors
        for _, e := range err.(validator.ValidationErrors) {
            fmt.Printf("Field %s failed validation: %s\n", e.Field, e.Tag)
        }
    }
}
```

## Library Management

### Versioning Strategy
```
Semantic Versioning (MAJOR.MINOR.PATCH):
- MAJOR: Breaking changes
- MINOR: New features (backward compatible)
- PATCH: Bug fixes

Example:
- v1.0.0: Initial release
- v1.1.0: Add new feature
- v1.1.1: Fix bug
- v2.0.0: Breaking change
```

### Release Process
```yaml
release_process:
  1_development:
    - Feature branch: feature/new-auth-method
    - Unit tests: 100% coverage
    - Integration tests: pass
    - Code review: 2 approvals
  
  2_testing:
    - Merge to develop branch
    - Deploy to staging
    - Run integration tests
    - Performance benchmarks
  
  3_release:
    - Create release branch: release/v1.2.0
    - Update CHANGELOG.md
    - Tag version: git tag v1.2.0
    - Build and publish artifacts
  
  4_deployment:
    - Publish to internal package registry
    - Update documentation
    - Notify teams via Slack
    - Gradual rollout (10% → 50% → 100%)
```

### Dependency Management
```
All services must:
- Pin library versions (no floating dependencies)
- Update libraries quarterly
- Security patches: within 24 hours
- Test before upgrading

Example (Go):
go.mod:
  require (
    zero-world/libs/auth v1.5.2
    zero-world/libs/db v2.3.1
    zero-world/libs/cache v1.8.0
  )
```

## Documentation

### Library Documentation Structure
```
/docs/
├── README.md              # Overview
├── getting-started.md     # Quick start guide
├── api-reference.md       # Full API documentation
├── examples/              # Code examples
│   ├── basic.md
│   ├── advanced.md
│   └── production.md
├── best-practices.md      # Usage guidelines
├── migration-guides/      # Upgrade guides
│   ├── v1-to-v2.md
│   └── v2-to-v3.md
└── changelog.md           # Version history
```

## Performance Benchmarks

### Library Performance Targets
```
Authentication Library:
- Token validation: <1ms (P99)
- Permission check: <0.5ms (P99)

Database Library:
- Connection acquisition: <5ms (P99)
- Query execution: <10ms (P99) for indexed queries

Caching Library:
- Local cache hit: <0.1ms (P99)
- Redis cache hit: <2ms (P99)

HTTP Client Library:
- Request overhead: <1ms
- Connection pooling: <5ms for new connection

Logging Library:
- Log write: <0.5ms (async)
- Zero allocation for hot path
```

## Library Statistics

```yaml
current_state:
  total_libraries: 50
  languages: [Go, Rust, Java, Python, TypeScript]
  total_downloads: 1_million_per_day
  services_using: 10_000+
  
target_state:
  total_libraries: 200
  languages: [Go, Rust, Java, Python, TypeScript, C++, Kotlin]
  total_downloads: 100_million_per_day
  services_using: 50_000+
  
quality_metrics:
  test_coverage: 95%+
  documentation_coverage: 100%
  security_scan: pass
  performance_benchmarks: pass
```

---

**Shared libraries are the foundation for building 10,000+ consistent, high-quality microservices.**
