# Code Standards & Best Practices
## Zero World Enterprise Development Guidelines

---

## 📋 Table of Contents
1. [Code Quality Standards](#code-quality-standards)
2. [Git Workflow](#git-workflow)
3. [Code Review Process](#code-review-process)
4. [Naming Conventions](#naming-conventions)
5. [Error Handling](#error-handling)
6. [Performance Guidelines](#performance-guidelines)
7. [Security Guidelines](#security-guidelines)
8. [Testing Requirements](#testing-requirements)

---

## 🎯 Code Quality Standards

### General Principles
1. **SOLID Principles**
   - Single Responsibility Principle
   - Open/Closed Principle
   - Liskov Substitution Principle
   - Interface Segregation Principle
   - Dependency Inversion Principle

2. **DRY (Don't Repeat Yourself)**
   - Extract common code into shared modules
   - Use inheritance and composition appropriately
   - Create reusable components

3. **KISS (Keep It Simple, Stupid)**
   - Avoid over-engineering
   - Write readable code
   - Prefer simple solutions

4. **YAGNI (You Aren't Gonna Need It)**
   - Don't add functionality until needed
   - Avoid premature optimization
   - Focus on current requirements

### Code Metrics
- **Maximum Function Length:** 50 lines
- **Maximum File Length:** 500 lines
- **Maximum Function Parameters:** 5
- **Cyclomatic Complexity:** <10
- **Test Coverage:** >80%

---

## 🌳 Git Workflow

### Branch Strategy (GitFlow)
```
master (production)
  └── develop (staging)
        ├── feature/auth-login
        ├── feature/social-feed
        ├── bugfix/payment-error
        ├── hotfix/security-patch
        └── release/v2.0.0
```

### Branch Naming Convention
- **Feature:** `feature/TICKET-123-short-description`
- **Bugfix:** `bugfix/TICKET-456-fix-description`
- **Hotfix:** `hotfix/TICKET-789-critical-fix`
- **Release:** `release/v2.0.0`

### Commit Message Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding tests
- `chore`: Build process or auxiliary tool changes

**Example:**
```
feat(auth): add OAuth 2.0 Google login

- Implemented Google OAuth integration
- Added token refresh mechanism
- Updated user schema with OAuth fields

Closes #123
```

### Commit Rules
- **One commit per logical change**
- **Descriptive commit messages**
- **Reference issue/ticket numbers**
- **Sign commits with GPG**

---

## 👥 Code Review Process

### Before Submitting PR
- [ ] All tests pass locally
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] No linting errors
- [ ] Performance tested
- [ ] Security considerations addressed

### PR Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] No new warnings generated
- [ ] Tests pass locally

## Screenshots (if applicable)
[Add screenshots]

## Related Issues
Closes #123
```

### Review Guidelines
- **Response Time:** Within 24 hours
- **Review Depth:** Line-by-line review
- **Feedback:** Constructive and specific
- **Approval:** Minimum 2 approvals required
- **Merge:** Squash and merge (clean history)

---

## 📝 Naming Conventions

### Flutter/Dart
```dart
// Classes: PascalCase
class UserRepository {}

// Functions: camelCase
void fetchUserData() {}

// Variables: camelCase
final String userName = 'John';

// Constants: SCREAMING_SNAKE_CASE
const int MAX_RETRY_ATTEMPTS = 3;

// Private members: _prefixWithUnderscore
String _privateField;

// Files: snake_case
user_repository.dart
authentication_bloc.dart
```

### Python/FastAPI
```python
# Classes: PascalCase
class UserService:
    pass

# Functions: snake_case
def get_user_by_id():
    pass

# Variables: snake_case
user_name = "John"

# Constants: SCREAMING_SNAKE_CASE
MAX_CONNECTIONS = 100

# Private: _prefix_with_underscore
_internal_cache = {}

# Files: snake_case
user_service.py
authentication_router.py
```

### Database
```
# Collections/Tables: snake_case_plural
users
order_items
product_reviews

# Fields: snake_case
user_id
created_at
is_active
```

---

## 🚨 Error Handling

### Flutter
```dart
// Use try-catch for async operations
Future<User> fetchUser(String id) async {
  try {
    final response = await apiClient.get('/users/$id');
    return User.fromJson(response.data);
  } on DioError catch (e) {
    if (e.response?.statusCode == 404) {
      throw UserNotFoundException(id);
    }
    throw ApiException(e.message);
  } catch (e) {
    logger.error('Unexpected error in fetchUser', error: e);
    throw UnexpectedErrorException();
  }
}

// Custom exceptions
class UserNotFoundException implements Exception {
  final String userId;
  UserNotFoundException(this.userId);
  
  @override
  String toString() => 'User not found: $userId';
}
```

### Python
```python
# Custom exceptions
class UserNotFoundException(Exception):
    """Raised when user is not found"""
    def __init__(self, user_id: str):
        self.user_id = user_id
        super().__init__(f"User not found: {user_id}")

# Error handling in routes
@router.get("/users/{user_id}")
async def get_user(user_id: str):
    try:
        user = await user_service.get_by_id(user_id)
        return user
    except UserNotFoundException as e:
        logger.warning(f"User not found: {user_id}")
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        logger.error(f"Unexpected error: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="Internal server error")
```

### Error Response Format
```json
{
  "error": {
    "code": "USER_NOT_FOUND",
    "message": "User with ID 123 not found",
    "details": {},
    "timestamp": "2025-10-14T12:34:56Z",
    "request_id": "abc-123-def-456"
  }
}
```

---

## ⚡ Performance Guidelines

### Frontend (Flutter)
1. **Use const constructors** where possible
2. **Lazy load images** with CachedNetworkImage
3. **Implement pagination** for lists
4. **Cache API responses** with Hive/SharedPreferences
5. **Use ListView.builder** for long lists
6. **Avoid rebuilding entire trees** (use keys, const)
7. **Profile with DevTools** before optimizing

```dart
// Good: Const constructor
const Text('Hello World')

// Good: ListView.builder for performance
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemCard(items[index]),
)

// Good: Cached images
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

### Backend (Python)
1. **Use async/await** for I/O operations
2. **Database connection pooling**
3. **Index frequently queried fields**
4. **Cache expensive queries** with Redis
5. **Use background tasks** for heavy operations
6. **Optimize database queries** (N+1 problem)
7. **Profile with cProfile** before optimizing

```python
# Good: Async operations
@router.get("/users")
async def get_users(db: Database = Depends(get_db)):
    users = await db.users.find().to_list(length=100)
    return users

# Good: Redis caching
@cache(expire=3600)  # Cache for 1 hour
async def get_popular_products():
    return await db.products.find({"is_popular": True}).to_list()

# Good: Database indexing
await db.users.create_index("email", unique=True)
await db.orders.create_index([("user_id", 1), ("created_at", -1)])
```

### Database Optimization
1. **Index all foreign keys**
2. **Compound indexes for multi-field queries**
3. **Limit result sets** (pagination)
4. **Use projection** to fetch only needed fields
5. **Avoid expensive operations** in queries

```python
# Good: Projection (only fetch needed fields)
users = await db.users.find(
    {"is_active": True},
    {"name": 1, "email": 1, "_id": 0}
).to_list()

# Good: Pagination
users = await db.users.find().skip(offset).limit(page_size).to_list()
```

---

## 🔒 Security Guidelines

### Authentication & Authorization
1. **Use OAuth 2.0** for third-party auth
2. **Implement JWT** with short expiration
3. **Refresh tokens** with rotation
4. **MFA** for sensitive operations
5. **Rate limiting** on auth endpoints

```python
# JWT configuration
JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY")  # 256-bit secret
JWT_ALGORITHM = "HS256"
JWT_ACCESS_TOKEN_EXPIRE_MINUTES = 15
JWT_REFRESH_TOKEN_EXPIRE_DAYS = 30
```

### Data Protection
1. **Encrypt sensitive data** at rest (AES-256)
2. **Use HTTPS** for all connections (TLS 1.3)
3. **Hash passwords** with bcrypt/Argon2
4. **Sanitize user inputs**
5. **Parameterized queries** (prevent SQL injection)

```python
# Good: Password hashing
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)
```

### API Security
1. **Rate limiting** (1000 req/min per user)
2. **CORS** configuration (whitelist domains)
3. **Input validation** (Pydantic models)
4. **Output sanitization**
5. **Security headers** (CSP, HSTS, etc.)

```python
# Rate limiting
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)

@app.get("/api/users")
@limiter.limit("100/minute")
async def get_users():
    pass
```

### OWASP Top 10 Protection
1. **Injection:** Use parameterized queries
2. **Broken Auth:** Implement MFA, secure sessions
3. **Sensitive Data:** Encrypt at rest/transit
4. **XXE:** Disable XML external entities
5. **Broken Access Control:** Implement RBAC
6. **Security Misconfiguration:** Secure defaults
7. **XSS:** Sanitize inputs/outputs
8. **Insecure Deserialization:** Validate data
9. **Known Vulnerabilities:** Regular updates
10. **Insufficient Logging:** Comprehensive logging

---

## 🧪 Testing Requirements

### Test Pyramid
- **70% Unit Tests:** Individual functions/methods
- **20% Integration Tests:** Multiple components
- **10% E2E Tests:** Full user journeys

### Flutter Testing
```dart
// Unit test example
void main() {
  group('UserRepository', () {
    late UserRepository repository;
    late MockApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockApiClient();
      repository = UserRepository(mockApiClient);
    });

    test('fetchUser returns user when API call succeeds', () async {
      // Arrange
      when(mockApiClient.get('/users/123'))
          .thenAnswer((_) async => Response(data: {'id': '123', 'name': 'John'}));

      // Act
      final user = await repository.fetchUser('123');

      // Assert
      expect(user.id, '123');
      expect(user.name, 'John');
    });

    test('fetchUser throws exception when user not found', () async {
      // Arrange
      when(mockApiClient.get('/users/123'))
          .thenThrow(DioError(response: Response(statusCode: 404)));

      // Act & Assert
      expect(
        () => repository.fetchUser('123'),
        throwsA(isA<UserNotFoundException>()),
      );
    });
  });
}
```

### Python Testing
```python
# Unit test example
import pytest
from app.services.user_service import UserService

@pytest.fixture
def user_service():
    return UserService(db=MockDatabase())

@pytest.mark.asyncio
async def test_get_user_success(user_service):
    # Arrange
    user_id = "123"
    
    # Act
    user = await user_service.get_by_id(user_id)
    
    # Assert
    assert user.id == user_id
    assert user.name == "John Doe"

@pytest.mark.asyncio
async def test_get_user_not_found(user_service):
    # Arrange
    user_id = "nonexistent"
    
    # Act & Assert
    with pytest.raises(UserNotFoundException):
        await user_service.get_by_id(user_id)
```

### Test Coverage
```bash
# Flutter
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Python
pytest --cov=app --cov-report=html
```

### Required Tests
- [ ] All public methods have unit tests
- [ ] Critical paths have integration tests
- [ ] Main user journeys have E2E tests
- [ ] Edge cases tested
- [ ] Error scenarios tested
- [ ] Performance tests for critical features

---

## 📊 Code Quality Tools

### Flutter/Dart
```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
    - avoid_print
    - always_declare_return_types
    - always_put_required_named_parameters_first
    - avoid_unnecessary_containers
    - use_key_in_widget_constructors
```

### Python
```toml
# pyproject.toml
[tool.black]
line-length = 100
target-version = ['py311']

[tool.isort]
profile = "black"
line_length = 100

[tool.pylint]
max-line-length = 100
disable = ["C0111"]  # Missing docstring

[tool.mypy]
python_version = "3.11"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
```

### Pre-commit Hooks
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files

  - repo: https://github.com/psf/black
    rev: 23.3.0
    hooks:
      - id: black

  - repo: https://github.com/pycqa/isort
    rev: 5.12.0
    hooks:
      - id: isort

  - repo: https://github.com/pycqa/flake8
    rev: 6.0.0
    hooks:
      - id: flake8
```

---

## 📚 Documentation Requirements

### Code Comments
```dart
/// Fetches a user by their unique identifier.
///
/// Returns a [User] object if found, throws [UserNotFoundException] if not found.
/// Throws [ApiException] for network errors.
///
/// Example:
/// ```dart
/// final user = await repository.fetchUser('123');
/// print(user.name);
/// ```
Future<User> fetchUser(String userId) async {
  // Implementation
}
```

### README Template
```markdown
# Service Name

Brief description of the service

## Features
- Feature 1
- Feature 2

## Prerequisites
- Python 3.11+
- MongoDB 6.0+

## Installation
```bash
pip install -r requirements.txt
```

## Usage
```python
from service import ServiceClass
```

## API Endpoints
- `GET /api/v1/users` - Get all users
- `POST /api/v1/users` - Create user

## Environment Variables
- `DATABASE_URL` - MongoDB connection string
- `JWT_SECRET` - JWT secret key

## Testing
```bash
pytest
```

## License
MIT
```

---

## 🎓 Resources

### Learning Materials
- [Clean Code by Robert C. Martin](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882)
- [Design Patterns: Elements of Reusable Object-Oriented Software](https://www.amazon.com/Design-Patterns-Elements-Reusable-Object-Oriented/dp/0201633612)
- [Flutter Documentation](https://flutter.dev/docs)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)

### Style Guides
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Python PEP 8](https://pep8.org/)
- [Google Style Guides](https://google.github.io/styleguide/)

---

*Last Updated: October 14, 2025*
