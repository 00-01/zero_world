# API Gateway Architecture

## Overview
Central API gateway handling 100+ billion requests per day across 1 trillion users.

## Architecture

```
api-gateway/
├── gateway-service/              # Core gateway service
│   ├── routing/                 # Request routing logic
│   ├── authentication/          # JWT/OAuth validation
│   ├── rate-limiting/           # Rate limiter implementation
│   ├── circuit-breaker/         # Circuit breaker pattern
│   └── load-balancing/          # Load balancing algorithms
├── configurations/               # Gateway configurations
│   ├── routes/                  # Route definitions
│   ├── policies/                # Security policies
│   └── transformations/         # Request/response transformations
└── plugins/                      # Custom plugins
    ├── analytics/               # Request analytics
    ├── caching/                 # Response caching
    └── logging/                 # Structured logging
```

## Request Flow

```
User Request → Load Balancer → API Gateway → Services
                                    ↓
                              [Middleware Pipeline]
                              1. Rate Limiting
                              2. Authentication
                              3. Authorization
                              4. Request Validation
                              5. Circuit Breaker
                              6. Service Routing
                              7. Response Caching
                              8. Logging/Metrics
```

## Capacity Planning

### Target Load
```
Concurrent Users: 100,000,000,000 (100B)
Requests per Second: 10,000,000 (10M RPS)
Daily Requests: 864,000,000,000 (864B)
Peak Multiplier: 5x (50M RPS)

Gateway Instances: 100,000
RPS per Instance: 100-500
Regions: 60
Instances per Region: 1,667
```

### Instance Configuration
```yaml
instance_type: c7g.16xlarge  # 64 vCPU, 128 GB RAM
instances_per_az: 556
availability_zones: 3
total_instances: 1,668 per region
auto_scaling:
  min: 1000
  max: 10000
  target_cpu: 60%
```

## Technology Stack

### Primary Gateway: Kong
```yaml
kong:
  version: "3.4"
  deployment_mode: db-less  # Configuration as code
  
  plugins:
    - rate-limiting
    - jwt
    - cors
    - request-transformer
    - response-transformer
    - prometheus
    - zipkin
    
  performance:
    worker_processes: auto
    worker_connections: 10000
    keepalive_requests: 10000
```

### Alternative: Envoy Proxy
```yaml
envoy:
  version: "1.28"
  
  features:
    - gRPC support
    - HTTP/2 & HTTP/3
    - Service mesh integration
    - Advanced load balancing
    - Dynamic configuration
    
  filters:
    - envoy.filters.http.jwt_authn
    - envoy.filters.http.ratelimit
    - envoy.filters.http.router
```

## Rate Limiting

### Multi-Tier Rate Limits
```yaml
rate_limits:
  # Global limit (per IP)
  global:
    requests_per_second: 100
    burst: 200
    
  # Authenticated users
  authenticated:
    free_tier:
      requests_per_minute: 60
      requests_per_hour: 1000
      requests_per_day: 10000
      
    premium_tier:
      requests_per_minute: 1000
      requests_per_hour: 50000
      requests_per_day: 1000000
      
    enterprise_tier:
      requests_per_minute: 10000
      requests_per_hour: unlimited
      requests_per_day: unlimited
  
  # Per endpoint limits
  endpoints:
    /api/v1/chat/send:
      rate: 10/second
      
    /api/v1/users/profile:
      rate: 100/second
      
    /api/v1/search:
      rate: 50/second
```

### Rate Limiter Implementation
```go
package ratelimiter

import (
    "context"
    "time"
    
    "github.com/go-redis/redis/v8"
)

type RateLimiter struct {
    redis  *redis.Client
    window time.Duration
}

// Token Bucket Algorithm
func (rl *RateLimiter) AllowRequest(ctx context.Context, key string, limit int) (bool, error) {
    now := time.Now().Unix()
    windowKey := fmt.Sprintf("ratelimit:%s:%d", key, now/int64(rl.window.Seconds()))
    
    pipe := rl.redis.Pipeline()
    incr := pipe.Incr(ctx, windowKey)
    pipe.Expire(ctx, windowKey, rl.window)
    
    _, err := pipe.Exec(ctx)
    if err != nil {
        return false, err
    }
    
    count := incr.Val()
    return count <= int64(limit), nil
}

// Sliding Window Algorithm (more accurate)
func (rl *RateLimiter) AllowRequestSlidingWindow(ctx context.Context, key string, limit int) (bool, error) {
    now := time.Now()
    windowStart := now.Add(-rl.window)
    
    // Remove old entries
    rl.redis.ZRemRangeByScore(ctx, key, "0", fmt.Sprintf("%d", windowStart.UnixNano()))
    
    // Count requests in window
    count, err := rl.redis.ZCard(ctx, key).Result()
    if err != nil {
        return false, err
    }
    
    if count >= int64(limit) {
        return false, nil
    }
    
    // Add current request
    rl.redis.ZAdd(ctx, key, &redis.Z{
        Score:  float64(now.UnixNano()),
        Member: now.String(),
    })
    
    // Set expiration
    rl.redis.Expire(ctx, key, rl.window)
    
    return true, nil
}
```

## Authentication & Authorization

### JWT Validation
```go
package auth

import (
    "github.com/golang-jwt/jwt/v5"
)

type AuthMiddleware struct {
    secretKey []byte
}

type Claims struct {
    UserID    string   `json:"user_id"`
    Email     string   `json:"email"`
    Roles     []string `json:"roles"`
    Tier      string   `json:"tier"`
    jwt.RegisteredClaims
}

func (am *AuthMiddleware) ValidateToken(tokenString string) (*Claims, error) {
    token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
        return am.secretKey, nil
    })
    
    if err != nil {
        return nil, err
    }
    
    if claims, ok := token.Claims.(*Claims); ok && token.Valid {
        return claims, nil
    }
    
    return nil, ErrInvalidToken
}

func (am *AuthMiddleware) CheckPermission(claims *Claims, resource string, action string) bool {
    // RBAC: Role-Based Access Control
    permissions := map[string]map[string][]string{
        "admin": {
            "*": {"read", "write", "delete"},
        },
        "user": {
            "profile": {"read", "write"},
            "messages": {"read", "write"},
            "files": {"read", "write"},
        },
        "guest": {
            "public": {"read"},
        },
    }
    
    for _, role := range claims.Roles {
        if actions, exists := permissions[role][resource]; exists {
            for _, a := range actions {
                if a == action || a == "*" {
                    return true
                }
            }
        }
    }
    
    return false
}
```

## Circuit Breaker

### Implementation
```go
package circuitbreaker

import (
    "context"
    "sync"
    "time"
)

type State int

const (
    StateClosed State = iota  // Normal operation
    StateOpen                  // Failing, reject requests
    StateHalfOpen             // Testing if service recovered
)

type CircuitBreaker struct {
    maxFailures  int
    timeout      time.Duration
    resetTimeout time.Duration
    
    state        State
    failures     int
    lastFailTime time.Time
    mu           sync.RWMutex
}

func NewCircuitBreaker(maxFailures int, timeout, resetTimeout time.Duration) *CircuitBreaker {
    return &CircuitBreaker{
        maxFailures:  maxFailures,
        timeout:      timeout,
        resetTimeout: resetTimeout,
        state:        StateClosed,
    }
}

func (cb *CircuitBreaker) Call(ctx context.Context, fn func() error) error {
    cb.mu.Lock()
    
    // Check if we should transition from Open to HalfOpen
    if cb.state == StateOpen {
        if time.Since(cb.lastFailTime) > cb.resetTimeout {
            cb.state = StateHalfOpen
            cb.failures = 0
        } else {
            cb.mu.Unlock()
            return ErrCircuitOpen
        }
    }
    
    cb.mu.Unlock()
    
    // Execute function with timeout
    done := make(chan error, 1)
    go func() {
        done <- fn()
    }()
    
    select {
    case err := <-done:
        cb.onResult(err)
        return err
        
    case <-time.After(cb.timeout):
        cb.onResult(ErrTimeout)
        return ErrTimeout
        
    case <-ctx.Done():
        return ctx.Err()
    }
}

func (cb *CircuitBreaker) onResult(err error) {
    cb.mu.Lock()
    defer cb.mu.Unlock()
    
    if err != nil {
        cb.failures++
        cb.lastFailTime = time.Now()
        
        if cb.failures >= cb.maxFailures {
            cb.state = StateOpen
        }
    } else {
        // Success
        if cb.state == StateHalfOpen {
            cb.state = StateClosed
        }
        cb.failures = 0
    }
}
```

## Load Balancing

### Algorithms

#### Round Robin
```go
func (lb *LoadBalancer) RoundRobin() string {
    lb.mu.Lock()
    defer lb.mu.Unlock()
    
    server := lb.servers[lb.current]
    lb.current = (lb.current + 1) % len(lb.servers)
    
    return server
}
```

#### Least Connections
```go
func (lb *LoadBalancer) LeastConnections() string {
    lb.mu.RLock()
    defer lb.mu.RUnlock()
    
    minConns := int(^uint(0) >> 1) // Max int
    var selected string
    
    for _, server := range lb.servers {
        conns := lb.connections[server]
        if conns < minConns {
            minConns = conns
            selected = server
        }
    }
    
    return selected
}
```

#### Weighted Round Robin
```go
func (lb *LoadBalancer) WeightedRoundRobin() string {
    lb.mu.Lock()
    defer lb.mu.Unlock()
    
    // Servers with weights: [server1: 5, server2: 3, server3: 2]
    totalWeight := 0
    for _, weight := range lb.weights {
        totalWeight += weight
    }
    
    target := lb.current % totalWeight
    cumulative := 0
    
    for server, weight := range lb.weights {
        cumulative += weight
        if target < cumulative {
            lb.current++
            return server
        }
    }
    
    return lb.servers[0]
}
```

#### Consistent Hashing (for sticky sessions)
```go
func (lb *LoadBalancer) ConsistentHash(key string) string {
    hash := crc32.ChecksumIEEE([]byte(key))
    
    // Find first server with hash >= request hash
    for _, serverHash := range lb.sortedHashes {
        if serverHash >= hash {
            return lb.hashToServer[serverHash]
        }
    }
    
    // Wrap around
    return lb.hashToServer[lb.sortedHashes[0]]
}
```

## Request/Response Transformation

### Request Transformation
```yaml
transformations:
  add_headers:
    - X-Gateway-Version: "1.0"
    - X-Request-ID: "${uuid()}"
    - X-Forwarded-For: "${client_ip}"
    
  remove_headers:
    - X-Internal-Token
    
  rename_headers:
    Authorization: X-Auth-Token
    
  add_query_params:
    version: "v1"
    
  body_transform:
    type: json
    mapping:
      user_id: $.request.userId
      timestamp: "${now()}"
```

### Response Transformation
```yaml
transformations:
  add_headers:
    - X-Response-Time: "${response_time_ms}ms"
    - X-Cache-Status: "${cache_status}"
    
  body_transform:
    type: json
    remove_fields:
      - password
      - internal_id
      - secret_key
    
    add_fields:
      api_version: "v1"
      timestamp: "${now()}"
```

## Caching Strategy

### Cache Configuration
```yaml
cache:
  backend: redis
  
  policies:
    # Cache successful GET requests
    - path: /api/v1/users/:id
      methods: [GET]
      ttl: 300  # 5 minutes
      vary_by:
        - Authorization
        - Accept-Language
        
    # Cache public content longer
    - path: /api/v1/public/*
      methods: [GET]
      ttl: 3600  # 1 hour
      
    # Don't cache POST/PUT/DELETE
    - path: /api/v1/*
      methods: [POST, PUT, DELETE, PATCH]
      cache: false
      
  invalidation:
    - on_mutation: true
    - webhook_enabled: true
```

## Monitoring & Observability

### Metrics
```yaml
metrics:
  # Request metrics
  - http_requests_total
  - http_request_duration_seconds
  - http_requests_in_flight
  
  # Rate limiting
  - rate_limit_hits_total
  - rate_limit_rejections_total
  
  # Circuit breaker
  - circuit_breaker_state
  - circuit_breaker_failures_total
  
  # Upstream services
  - upstream_response_time_seconds
  - upstream_errors_total
  - upstream_timeouts_total
  
  # Cache
  - cache_hits_total
  - cache_misses_total
  - cache_size_bytes
```

### Logging
```json
{
  "timestamp": "2025-10-15T14:30:00Z",
  "level": "info",
  "request_id": "req_abc123",
  "method": "GET",
  "path": "/api/v1/users/123",
  "status": 200,
  "duration_ms": 45,
  "client_ip": "203.0.113.42",
  "user_id": "usr_742a9b3c",
  "user_agent": "ZeroWorld-Mobile/1.0",
  "bytes_sent": 1024,
  "upstream_service": "user-service",
  "upstream_duration_ms": 38,
  "cache_hit": true
}
```

### Distributed Tracing
```yaml
tracing:
  backend: jaeger
  sampling_rate: 0.1  # 10% of requests
  
  spans:
    - gateway_receive
    - auth_validate
    - rate_limit_check
    - upstream_call
    - response_transform
    - gateway_respond
```

## Security

### DDoS Protection
```yaml
ddos_protection:
  # Connection limits
  max_connections_per_ip: 1000
  new_connections_per_second: 100
  
  # Request limits
  requests_per_second_per_ip: 100
  burst_per_ip: 200
  
  # Geo-blocking
  blocked_countries: []
  allowed_countries: ["*"]
  
  # Pattern detection
  anomaly_detection: true
  auto_ban_threshold: 10000
  ban_duration: 3600  # 1 hour
```

### Input Validation
```yaml
validation:
  # Request size limits
  max_request_size: 10MB
  max_header_size: 32KB
  max_url_length: 4096
  
  # Content validation
  allowed_content_types:
    - application/json
    - application/x-www-form-urlencoded
    - multipart/form-data
  
  # SQL injection prevention
  sql_injection_check: true
  
  # XSS prevention
  xss_check: true
  
  # Path traversal prevention
  path_traversal_check: true
```

## High Availability

### Deployment Strategy
```yaml
deployment:
  strategy: rolling_update
  max_surge: 50%
  max_unavailable: 25%
  
  health_checks:
    liveness:
      path: /health/live
      interval: 10s
      timeout: 5s
      failure_threshold: 3
      
    readiness:
      path: /health/ready
      interval: 5s
      timeout: 3s
      failure_threshold: 3
  
  auto_healing: true
  
  disaster_recovery:
    multi_region: true
    failover_time: less_than_30_seconds
```

---

**API Gateway designed to handle 10M+ RPS with sub-10ms latency and 99.99% availability.**
