# Testing Infrastructure

## Overview
Comprehensive testing strategy for trillion-scale system with 10,000+ microservices.

## Testing Pyramid

```
                    /\
                   /  \
                  / E2E\ (5%)
                 /------\
                /        \
               /Integration\ (15%)
              /------------\
             /              \
            /   Unit Tests   \ (80%)
           /------------------\
```

## 1. Unit Testing

### Coverage Requirements
```yaml
coverage_targets:
  minimum: 80%
  target: 90%
  critical_path: 100%
  
excluded_from_coverage:
  - generated_code
  - third_party_libraries
  - test_utilities
```

### Unit Test Standards

**Go Example:**
```go
package user

import (
    "testing"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/mock"
)

// Table-driven tests
func TestUserService_CreateUser(t *testing.T) {
    tests := []struct {
        name    string
        input   CreateUserInput
        want    *User
        wantErr bool
    }{
        {
            name: "valid user",
            input: CreateUserInput{
                Email: "test@example.com",
                Password: "securepassword123",
            },
            want: &User{
                ID: "123",
                Email: "test@example.com",
            },
            wantErr: false,
        },
        {
            name: "invalid email",
            input: CreateUserInput{
                Email: "invalid",
                Password: "securepassword123",
            },
            want: nil,
            wantErr: true,
        },
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // Setup
            mockRepo := &MockUserRepository{}
            service := NewUserService(mockRepo)
            
            if !tt.wantErr {
                mockRepo.On("Create", mock.Anything).Return(tt.want, nil)
            }
            
            // Execute
            got, err := service.CreateUser(context.Background(), tt.input)
            
            // Assert
            if tt.wantErr {
                assert.Error(t, err)
            } else {
                assert.NoError(t, err)
                assert.Equal(t, tt.want, got)
            }
            
            mockRepo.AssertExpectations(t)
        })
    }
}

// Benchmark tests
func BenchmarkUserService_GetUser(b *testing.B) {
    mockRepo := &MockUserRepository{}
    service := NewUserService(mockRepo)
    mockRepo.On("FindByID", "123").Return(&User{ID: "123"}, nil)
    
    b.ResetTimer()
    for i := 0; i < b.N; i++ {
        service.GetUser(context.Background(), "123")
    }
}
```

**Python Example:**
```python
import pytest
from unittest.mock import Mock, patch
from user_service import UserService, CreateUserInput

class TestUserService:
    @pytest.fixture
    def user_service(self):
        mock_repo = Mock()
        return UserService(mock_repo)
    
    @pytest.mark.parametrize("email,password,should_succeed", [
        ("test@example.com", "securepassword123", True),
        ("invalid", "securepassword123", False),
        ("test@example.com", "weak", False),
    ])
    def test_create_user(self, user_service, email, password, should_succeed):
        input_data = CreateUserInput(email=email, password=password)
        
        if should_succeed:
            result = user_service.create_user(input_data)
            assert result.email == email
        else:
            with pytest.raises(ValidationError):
                user_service.create_user(input_data)
    
    def test_get_user_caches_result(self, user_service):
        user_id = "123"
        
        # First call - hits database
        user1 = user_service.get_user(user_id)
        
        # Second call - should hit cache
        user2 = user_service.get_user(user_id)
        
        # Verify database called only once
        user_service.repo.find_by_id.assert_called_once_with(user_id)
        assert user1 == user2
```

### Mocking Strategies

**Database Mocks:**
```go
type MockUserRepository struct {
    mock.Mock
}

func (m *MockUserRepository) FindByID(id string) (*User, error) {
    args := m.Called(id)
    if args.Get(0) == nil {
        return nil, args.Error(1)
    }
    return args.Get(0).(*User), args.Error(1)
}

func (m *MockUserRepository) Create(user *User) error {
    args := m.Called(user)
    return args.Error(0)
}
```

**HTTP Client Mocks:**
```go
type MockHTTPClient struct {
    Response *http.Response
    Error    error
}

func (m *MockHTTPClient) Do(req *http.Request) (*http.Response, error) {
    return m.Response, m.Error
}
```

## 2. Integration Testing

### Test Scenarios
```yaml
integration_tests:
  database:
    - connection_pooling
    - transaction_rollback
    - query_performance
    - migration_scripts
  
  messaging:
    - kafka_producer_consumer
    - message_ordering
    - dead_letter_queue
    - exactly_once_delivery
  
  caching:
    - redis_connection
    - cache_invalidation
    - cache_stampede
    - distributed_locking
  
  api:
    - http_endpoints
    - grpc_services
    - authentication_flow
    - rate_limiting
```

### Docker Compose for Integration Tests

```yaml
# docker-compose.test.yml
version: '3.8'

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: testpassword
      POSTGRES_DB: testdb
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5
  
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5
  
  kafka:
    image: confluentinc/cp-kafka:7.5.0
    depends_on:
      - zookeeper
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9092
    ports:
      - "9092:9092"
  
  zookeeper:
    image: confluentinc/cp-zookeeper:7.5.0
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
    ports:
      - "2181:2181"
  
  test-runner:
    build: .
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
      kafka:
        condition: service_started
    environment:
      DATABASE_URL: postgres://postgres:testpassword@postgres:5432/testdb
      REDIS_URL: redis://redis:6379
      KAFKA_BROKERS: kafka:9092
    command: ["go", "test", "./...", "-tags=integration"]
```

### Integration Test Example

```go
// +build integration

package integration

import (
    "testing"
    "github.com/stretchr/testify/assert"
)

func TestUserAPI_CreateAndRetrieve(t *testing.T) {
    // Setup test database
    db := setupTestDatabase(t)
    defer cleanupTestDatabase(t, db)
    
    // Initialize service with real dependencies
    userRepo := NewUserRepository(db)
    userService := NewUserService(userRepo)
    
    // Create user
    user, err := userService.CreateUser(context.Background(), CreateUserInput{
        Email: "integration@test.com",
        Password: "testpassword123",
    })
    assert.NoError(t, err)
    assert.NotEmpty(t, user.ID)
    
    // Retrieve user
    retrieved, err := userService.GetUser(context.Background(), user.ID)
    assert.NoError(t, err)
    assert.Equal(t, user.Email, retrieved.Email)
    
    // Verify database state
    count := 0
    db.QueryRow("SELECT COUNT(*) FROM users WHERE email = $1", user.Email).Scan(&count)
    assert.Equal(t, 1, count)
}

func TestKafkaIntegration(t *testing.T) {
    // Setup Kafka producer and consumer
    producer := setupKafkaProducer(t)
    consumer := setupKafkaConsumer(t)
    defer producer.Close()
    defer consumer.Close()
    
    // Publish message
    msg := UserEvent{
        Type: "user.created",
        UserID: "123",
        Timestamp: time.Now(),
    }
    err := producer.Publish(context.Background(), msg)
    assert.NoError(t, err)
    
    // Consume message
    ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
    defer cancel()
    
    received := <-consumer.Messages(ctx)
    assert.Equal(t, msg.UserID, received.UserID)
}
```

## 3. End-to-End (E2E) Testing

### E2E Test Scenarios

```yaml
critical_user_flows:
  - user_registration_and_login
  - create_and_send_message
  - search_and_view_profile
  - payment_flow
  - notification_delivery
  
cross_service_flows:
  - user_creates_account → verification_email → login → profile_setup
  - user_posts_message → indexing → search → view
  - user_makes_payment → transaction_processing → receipt → notification
```

### E2E Test Framework (Playwright/Selenium)

```typescript
// E2E test example (TypeScript + Playwright)
import { test, expect } from '@playwright/test';

test.describe('User Registration Flow', () => {
  test('should register new user and send welcome email', async ({ page }) => {
    // Navigate to registration page
    await page.goto('https://staging.zeroworld.com/register');
    
    // Fill registration form
    await page.fill('[name="email"]', 'e2e@test.com');
    await page.fill('[name="password"]', 'SecurePassword123!');
    await page.fill('[name="confirmPassword"]', 'SecurePassword123!');
    
    // Submit form
    await page.click('button[type="submit"]');
    
    // Wait for redirect to verification page
    await page.waitForURL('**/verify-email');
    expect(await page.textContent('h1')).toContain('Check your email');
    
    // Verify user created in database
    const user = await db.users.findOne({ email: 'e2e@test.com' });
    expect(user).toBeTruthy();
    expect(user.verified).toBe(false);
    
    // Verify welcome email sent
    const email = await emailService.getLastEmail('e2e@test.com');
    expect(email.subject).toContain('Welcome to Zero World');
    
    // Extract verification token and verify
    const verificationToken = extractTokenFromEmail(email.body);
    await page.goto(`https://staging.zeroworld.com/verify?token=${verificationToken}`);
    
    // Verify success message
    expect(await page.textContent('.success')).toContain('Email verified');
    
    // Verify user updated in database
    const verifiedUser = await db.users.findOne({ email: 'e2e@test.com' });
    expect(verifiedUser.verified).toBe(true);
  });
});
```

### API E2E Testing

```python
# API E2E test example (Python + requests)
import pytest
import requests

class TestUserAPIFlow:
    base_url = "https://staging-api.zeroworld.com"
    
    def test_complete_user_lifecycle(self):
        # 1. Register user
        register_response = requests.post(
            f"{self.base_url}/auth/register",
            json={
                "email": "api-test@example.com",
                "password": "SecurePassword123!"
            }
        )
        assert register_response.status_code == 201
        user_id = register_response.json()["user_id"]
        
        # 2. Login
        login_response = requests.post(
            f"{self.base_url}/auth/login",
            json={
                "email": "api-test@example.com",
                "password": "SecurePassword123!"
            }
        )
        assert login_response.status_code == 200
        token = login_response.json()["access_token"]
        
        headers = {"Authorization": f"Bearer {token}"}
        
        # 3. Get user profile
        profile_response = requests.get(
            f"{self.base_url}/users/{user_id}",
            headers=headers
        )
        assert profile_response.status_code == 200
        assert profile_response.json()["email"] == "api-test@example.com"
        
        # 4. Update profile
        update_response = requests.patch(
            f"{self.base_url}/users/{user_id}",
            headers=headers,
            json={"name": "Test User", "bio": "E2E test"}
        )
        assert update_response.status_code == 200
        
        # 5. Delete user
        delete_response = requests.delete(
            f"{self.base_url}/users/{user_id}",
            headers=headers
        )
        assert delete_response.status_code == 204
        
        # 6. Verify user deleted
        get_deleted_response = requests.get(
            f"{self.base_url}/users/{user_id}",
            headers=headers
        )
        assert get_deleted_response.status_code == 404
```

## 4. Performance Testing

### Load Testing (K6)

```javascript
// load-test.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '2m', target: 100 },    // Ramp up to 100 users
    { duration: '5m', target: 100 },    // Stay at 100 users
    { duration: '2m', target: 1000 },   // Ramp up to 1000 users
    { duration: '5m', target: 1000 },   // Stay at 1000 users
    { duration: '2m', target: 0 },      // Ramp down to 0 users
  ],
  thresholds: {
    'http_req_duration': ['p(95)<500', 'p(99)<1000'], // 95% < 500ms, 99% < 1s
    'http_req_failed': ['rate<0.01'],                  // Error rate < 1%
  },
};

export default function () {
  // Test user registration
  let registerRes = http.post('https://api.zeroworld.com/auth/register', JSON.stringify({
    email: `user${__VU}-${__ITER}@test.com`,
    password: 'TestPassword123!',
  }), {
    headers: { 'Content-Type': 'application/json' },
  });
  
  check(registerRes, {
    'registration successful': (r) => r.status === 201,
    'response time OK': (r) => r.timings.duration < 500,
  });
  
  sleep(1);
  
  // Test user login
  let loginRes = http.post('https://api.zeroworld.com/auth/login', JSON.stringify({
    email: `user${__VU}-${__ITER}@test.com`,
    password: 'TestPassword123!',
  }), {
    headers: { 'Content-Type': 'application/json' },
  });
  
  check(loginRes, {
    'login successful': (r) => r.status === 200,
    'has access token': (r) => r.json('access_token') !== '',
  });
  
  sleep(1);
}
```

### Stress Testing

```javascript
// stress-test.js
export let options = {
  stages: [
    { duration: '2m', target: 10000 },   // Quickly ramp up to 10K users
    { duration: '10m', target: 10000 },  // Maintain 10K users
    { duration: '2m', target: 20000 },   // Push to 20K users
    { duration: '5m', target: 20000 },   // Maintain 20K users
    { duration: '2m', target: 0 },       // Ramp down
  ],
};
```

### Soak Testing (Endurance)

```javascript
// soak-test.js
export let options = {
  stages: [
    { duration: '5m', target: 1000 },    // Ramp up
    { duration: '24h', target: 1000 },   // Run for 24 hours
    { duration: '5m', target: 0 },       // Ramp down
  ],
};
```

## 5. Chaos Testing

### Chaos Monkey Scenarios

```yaml
chaos_experiments:
  pod_failures:
    - randomly_kill_pods
    - kill_leader_pod
    - kill_all_replicas_sequentially
  
  network_chaos:
    - introduce_latency (100ms, 500ms, 1s)
    - packet_loss (1%, 5%, 10%)
    - network_partition
    - DNS_failures
  
  resource_exhaustion:
    - CPU_stress
    - memory_pressure
    - disk_full
    - file_descriptor_exhaustion
  
  infrastructure_failures:
    - zone_outage
    - region_outage
    - database_failover
    - cache_eviction
```

### Chaos Testing Framework (Chaos Mesh)

```yaml
# chaos-experiment.yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: PodChaos
metadata:
  name: pod-failure-test
  namespace: chaos-testing
spec:
  action: pod-failure
  mode: one
  duration: '30s'
  selector:
    namespaces:
      - user-service
    labelSelectors:
      'app': 'user-service'
  scheduler:
    cron: '*/5 * * * *'  # Run every 5 minutes
---
apiVersion: chaos-mesh.org/v1alpha1
kind: NetworkChaos
metadata:
  name: network-delay-test
  namespace: chaos-testing
spec:
  action: delay
  mode: all
  selector:
    namespaces:
      - user-service
    labelSelectors:
      'app': 'user-service'
  delay:
    latency: '100ms'
    correlation: '100'
    jitter: '50ms'
  duration: '5m'
```

## 6. Security Testing

### Vulnerability Scanning

```yaml
security_tools:
  SAST (Static Analysis):
    - SonarQube
    - Checkmarx
    - Snyk Code
  
  DAST (Dynamic Analysis):
    - OWASP ZAP
    - Burp Suite
    - Acunetix
  
  Dependency Scanning:
    - Snyk
    - Dependabot
    - WhiteSource
  
  Container Scanning:
    - Trivy
    - Clair
    - Anchore
```

### Penetration Testing

```yaml
penetration_tests:
  authentication:
    - brute_force_attack
    - credential_stuffing
    - session_hijacking
    - JWT_token_manipulation
  
  authorization:
    - privilege_escalation
    - IDOR (Insecure Direct Object Reference)
    - missing_authorization
  
  injection:
    - SQL_injection
    - NoSQL_injection
    - command_injection
    - LDAP_injection
  
  web:
    - XSS (Cross-Site Scripting)
    - CSRF (Cross-Site Request Forgery)
    - clickjacking
    - open_redirect
```

## Test Automation

### CI/CD Pipeline Integration

```yaml
# .gitlab-ci.yml
stages:
  - lint
  - unit-test
  - integration-test
  - security-scan
  - build
  - e2e-test
  - performance-test
  - deploy

unit-test:
  stage: unit-test
  script:
    - go test ./... -v -cover -coverprofile=coverage.out
    - go tool cover -func=coverage.out
  coverage: '/total:.*?(\d+\.\d+)%/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage.xml

integration-test:
  stage: integration-test
  services:
    - postgres:15
    - redis:7
  script:
    - docker-compose -f docker-compose.test.yml up -d
    - go test ./... -tags=integration -v
  after_script:
    - docker-compose -f docker-compose.test.yml down

security-scan:
  stage: security-scan
  script:
    - trivy image --severity HIGH,CRITICAL $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    - snyk test --severity-threshold=high

e2e-test:
  stage: e2e-test
  script:
    - npm install
    - npx playwright test
  artifacts:
    when: on_failure
    paths:
      - playwright-report/
      - test-results/

performance-test:
  stage: performance-test
  script:
    - k6 run --vus 1000 --duration 5m load-test.js
  only:
    - master
    - staging
```

## Test Metrics & Reporting

### Key Metrics

```yaml
test_metrics:
  coverage:
    unit_tests: 90%+
    integration_tests: 75%+
    e2e_tests: critical_paths_only
  
  execution_time:
    unit_tests: <5_minutes
    integration_tests: <15_minutes
    e2e_tests: <30_minutes
    full_suite: <1_hour
  
  flakiness:
    target: <1%
    action_threshold: 5%
  
  failure_rate:
    target: <0.1%
    alert_threshold: 1%
```

### Reporting Dashboard

```
Test Execution Dashboard:
========================
- Total tests: 500,000
- Passed: 499,500 (99.9%)
- Failed: 500 (0.1%)
- Skipped: 0
- Duration: 45 minutes
- Coverage: 92%

Trend (Last 7 days):
- Pass rate: ↑ 0.2%
- Coverage: → stable
- Duration: ↓ 5 minutes
```

## Test Data Management

### Test Data Strategy

```yaml
test_data:
  anonymized_production_data:
    - periodic_snapshots
    - PII_removal
    - size_reduction (10% of production)
  
  synthetic_data:
    - faker_library
    - custom_generators
    - realistic_distributions
  
  fixtures:
    - version_controlled
    - shared_across_tests
    - minimal_dependencies
```

---

**Comprehensive testing ensures trillion-scale system reliability. Test early, test often, test everything.**
