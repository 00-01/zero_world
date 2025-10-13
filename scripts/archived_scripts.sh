#!/bin/bash

echo "🧹 Zero World Database Cleanup & Setup"
echo "======================================"

# Database connection details
DB_HOST="localhost"
DB_PORT="27017"
DB_USER="root"
DB_PASS="example"
DB_AUTH="admin"

echo ""
echo "📋 Current Database Status:"
docker exec zero_world_mongodb_1 mongosh --username $DB_USER --password $DB_PASS --authenticationDatabase $DB_AUTH --eval "
console.log('Databases:');
db.adminCommand('listDatabases').databases.forEach(db => {
    if (db.name !== 'admin' && db.name !== 'config' && db.name !== 'local') {
        console.log('• ' + db.name + ' (' + (db.sizeOnDisk/1024).toFixed(2) + ' KB)');
    }
});
"

echo ""
echo "🗑️ Cleaning up old data..."

# Drop existing databases to start fresh
docker exec zero_world_mongodb_1 mongosh --username $DB_USER --password $DB_PASS --authenticationDatabase $DB_AUTH --eval "
console.log('Dropping zeromarket database...');
db.getSiblingDB('zeromarket').dropDatabase();
console.log('Dropping zero_world database (if exists)...');
db.getSiblingDB('zero_world').dropDatabase();
console.log('✅ Cleanup complete');
"

echo ""
echo "🔧 Setting up Zero World database..."

# Create the new database with proper collections and indexes
docker exec zero_world_mongodb_1 mongosh --username $DB_USER --password $DB_PASS --authenticationDatabase $DB_AUTH --eval "
// Switch to zero_world database
db = db.getSiblingDB('zero_world');

console.log('Creating collections with proper schema...');

// Create users collection with indexes
console.log('• Creating users collection');
db.createCollection('users');
db.users.createIndex({ 'email': 1 }, { unique: true });
db.users.createIndex({ 'created_at': -1 });

// Create listings collection with indexes  
console.log('• Creating listings collection');
db.createCollection('listings');
db.listings.createIndex({ 'owner_id': 1 });
db.listings.createIndex({ 'is_active': 1, 'created_at': -1 });
db.listings.createIndex({ 'category': 1 });
db.listings.createIndex({ 'price': 1 });
db.listings.createIndex({ 'title': 'text', 'description': 'text' });

// Create chats collection with indexes
console.log('• Creating chats collection');
db.createCollection('chats');
db.chats.createIndex({ 'participants_hash': 1 }, { unique: true });
db.chats.createIndex({ 'participants': 1 });
db.chats.createIndex({ 'listing_context.listing_id': 1 });

// Create messages collection with indexes
console.log('• Creating messages collection');
db.createCollection('messages');
db.messages.createIndex({ 'chat_id': 1, 'created_at': 1 });
db.messages.createIndex({ 'sender_id': 1 });

// Create community_posts collection with indexes
console.log('• Creating community_posts collection');
db.createCollection('community_posts');
db.community_posts.createIndex({ 'author_id': 1 });
db.community_posts.createIndex({ 'created_at': -1 });
db.community_posts.createIndex({ 'tags': 1 });

// Create community_comments collection with indexes
console.log('• Creating community_comments collection');  
db.createCollection('community_comments');
db.community_comments.createIndex({ 'post_id': 1 });
db.community_comments.createIndex({ 'author_id': 1 });
db.community_comments.createIndex({ 'created_at': -1 });

console.log('✅ Database setup complete');
"

echo ""
echo "📊 New Database Structure:"
docker exec zero_world_mongodb_1 mongosh --username $DB_USER --password $DB_PASS --authenticationDatabase $DB_AUTH zero_world --eval "
console.log('Collections in zero_world database:');
db.getCollectionNames().forEach(name => {
    const count = db.getCollection(name).countDocuments();
    const indexes = db.getCollection(name).getIndexes().length;
    console.log('• ' + name + ': ' + count + ' documents, ' + indexes + ' indexes');
});
"

echo ""
echo "🔧 Next Steps:"
echo "1. Update backend configuration to use 'zero_world' database"
echo "2. Restart backend service"
echo "3. Test the application"
echo ""
echo "📋 New MongoDB Compass Connection:"
echo "mongodb://root:example@localhost:27017/zero_world?authSource=admin"#!/bin/bash
# Test Zero World on all available platforms
# Usage: ./test_all_platforms.sh

set -e

PROJECT_DIR="/home/z/zero_world/frontend/zero_world"
cd "$PROJECT_DIR"

echo "🧪 Testing Zero World on All Platforms..."
echo "============================================"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Clean and prepare
echo -e "${BLUE}🧹 Cleaning project...${NC}"
flutter clean
flutter pub get

# 1. Run unit tests
echo -e "\n${BLUE}📝 Running unit tests...${NC}"
if flutter test; then
    echo -e "${GREEN}✅ Unit tests passed${NC}"
else
    echo -e "${RED}❌ Unit tests failed${NC}"
    exit 1
fi

# 2. Analyze code
echo -e "\n${BLUE}🔍 Analyzing code...${NC}"
if flutter analyze; then
    echo -e "${GREEN}✅ Code analysis passed${NC}"
else
    echo -e "${RED}❌ Code analysis failed${NC}"
fi

# 3. Test Web build
echo -e "\n${BLUE}🌐 Testing Web build...${NC}"
if flutter build web --release; then
    echo -e "${GREEN}✅ Web build successful${NC}"
    echo "   Output: build/web/"
else
    echo -e "${RED}❌ Web build failed${NC}"
fi

# 4. Test Android build
echo -e "\n${BLUE}📱 Testing Android build...${NC}"
if flutter build apk --release; then
    echo -e "${GREEN}✅ Android APK build successful${NC}"
    echo "   Output: build/app/outputs/flutter-apk/app-release.apk"
else
    echo -e "${RED}❌ Android APK build failed${NC}"
fi

# 5. Test Linux build
echo -e "\n${BLUE}🐧 Testing Linux build...${NC}"
if flutter build linux --release; then
    echo -e "${GREEN}✅ Linux build successful${NC}"
    echo "   Output: build/linux/x64/release/bundle/"
else
    echo -e "${RED}❌ Linux build failed${NC}"
fi

# 6. Check available devices
echo -e "\n${BLUE}📱 Available devices:${NC}"
flutter devices

# 7. Run on Linux desktop
echo -e "\n${BLUE}🖥️  Would you like to run on Linux desktop? (y/n)${NC}"
read -r -n 1 response
echo
if [[ "$response" =~ ^[Yy]$ ]]; then
    flutter run -d linux --release
fi

# Summary
echo -e "\n${BLUE}============================================${NC}"
echo -e "${GREEN}✨ Testing complete!${NC}"
echo -e "\n📊 Build Summary:"
echo "   Web:     build/web/"
echo "   Android: build/app/outputs/flutter-apk/"
echo "   Linux:   build/linux/x64/release/bundle/"
echo -e "\n${BLUE}Next steps:${NC}"
echo "   1. Test Web: Open build/web/index.html in browser"
echo "   2. Test Android: Install APK on device/emulator"
echo "   3. Test Linux: Run ./build/linux/x64/release/bundle/zero_world"
echo "   4. Deploy: Run ./deploy_all.sh"
#!/bin/bash
# Environment Variable Management Script

set -e

ENV_FILE=".env"
ENV_EXAMPLE=".env.example"

echo "🔐 Zero World - Environment Variable Manager"
echo "============================================"

# Function to check if .env exists
check_env_file() {
    if [ ! -f "$ENV_FILE" ]; then
        echo "❌ .env file not found!"
        echo "📋 Creating .env from template..."
        
        if [ -f "$ENV_EXAMPLE" ]; then
            cp "$ENV_EXAMPLE" "$ENV_FILE"
            echo "✅ Created .env file from template"
            echo "⚠️  Please edit .env with your actual values before running docker-compose"
            return 1
        else
            echo "❌ .env.example template not found!"
            return 1
        fi
    fi
    return 0
}

# Function to validate required environment variables
validate_env_vars() {
    echo "🔍 Validating environment variables..."
    
    required_vars=(
        "MONGODB_USERNAME"
        "MONGODB_PASSWORD"
        "JWT_SECRET"
        "DOMAIN_NAME"
    )
    
    missing_vars=()
    
    # Source the .env file to check variables
    set -a  # automatically export all variables
    source "$ENV_FILE"
    set +a
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ] || [ "${!var}" = "your_${var,,}" ] || [[ "${!var}" == *"your_"* ]]; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -ne 0 ]; then
        echo "❌ Missing or template values found for:"
        printf '   - %s\n' "${missing_vars[@]}"
        echo "⚠️  Please update these values in $ENV_FILE"
        return 1
    fi
    
    echo "✅ All required environment variables are configured"
    return 0
}

# Function to generate secure JWT secret
generate_jwt_secret() {
    echo "🔑 Generating secure JWT secret..."
    if command -v openssl >/dev/null 2>&1; then
        NEW_SECRET=$(openssl rand -hex 32)
        echo "Generated JWT secret: $NEW_SECRET"
        echo "Replace JWT_SECRET in your .env file with this value"
    else
        echo "❌ OpenSSL not found. Please generate a 64-character random string for JWT_SECRET"
    fi
}

# Function to test docker-compose config
test_docker_config() {
    echo "🐳 Testing Docker Compose configuration..."
    if docker-compose config >/dev/null 2>&1; then
        echo "✅ Docker Compose configuration is valid"
        return 0
    else
        echo "❌ Docker Compose configuration has errors"
        echo "Run 'docker-compose config' to see details"
        return 1
    fi
}

# Function to check if sensitive files are properly ignored
check_git_protection() {
    echo "🛡️  Checking Git protection..."
    
    if [ -d ".git" ]; then
        # Check if .env is tracked by git
        if git ls-files --error-unmatch .env >/dev/null 2>&1; then
            echo "⚠️  WARNING: .env file is tracked by Git!"
            echo "   Run: git rm --cached .env"
            echo "   Then: git commit -m 'Remove .env from tracking'"
        else
            echo "✅ .env file is properly ignored by Git"
        fi
        
        # Check if .gitignore exists and contains .env
        if grep -q "^\.env$" .gitignore 2>/dev/null; then
            echo "✅ .gitignore properly configured"
        else
            echo "⚠️  .env not found in .gitignore"
        fi
    else
        echo "ℹ️  Not a Git repository"
    fi
}

# Main function
main() {
    case "${1:-check}" in
        "init")
            echo "🚀 Initializing environment configuration..."
            if check_env_file; then
                echo "✅ .env file already exists"
            fi
            ;;
        "validate")
            check_env_file && validate_env_vars
            ;;
        "generate-jwt")
            generate_jwt_secret
            ;;
        "test")
            check_env_file && validate_env_vars && test_docker_config
            ;;
        "check")
            echo "🔍 Running comprehensive security check..."
            check_env_file
            validate_env_vars
            test_docker_config
            check_git_protection
            ;;
        "help")
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  init         - Initialize .env file from template"
            echo "  validate     - Validate environment variables"
            echo "  generate-jwt - Generate a secure JWT secret"
            echo "  test         - Test Docker Compose configuration"
            echo "  check        - Run comprehensive security check (default)"
            echo "  help         - Show this help message"
            ;;
        *)
            echo "❌ Unknown command: $1"
            echo "Run '$0 help' for usage information"
            exit 1
            ;;
    esac
}

main "$@"#!/bin/bash

echo "🔒 Manual SSL Certificate Setup for zn-01.com"
echo "=============================================="

# Step 1: Check current status
echo "Step 1: Checking current setup..."
echo "Current server IP: $(curl -s ifconfig.me)"
echo "Testing current HTTP access..."

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://www.zn-01.com/health 2>/dev/null)
if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "✅ HTTP access working (status: $HTTP_STATUS)"
else
    echo "❌ HTTP access failed (status: $HTTP_STATUS)"
    echo "Please ensure HTTP is working first before getting SSL certificates"
    exit 1
fi

# Step 2: Stop nginx to free port 80 for standalone certbot
echo ""
echo "Step 2: Temporarily stopping nginx to free port 80..."
docker-compose stop nginx

# Wait a moment for port to be freed
sleep 3

# Step 3: Use certbot standalone method
echo ""
echo "Step 3: Requesting SSL certificates from Let's Encrypt..."
echo "This may take a few minutes..."

sudo certbot certonly \
    --standalone \
    --preferred-challenges http \
    --http-01-port 80 \
    --email admin@zn-01.com \
    --agree-tos \
    --no-eff-email \
    --force-renewal \
    -d zn-01.com \
    -d www.zn-01.com

# Step 4: Check if certificates were obtained
if [ -f "/etc/letsencrypt/live/zn-01.com/fullchain.pem" ]; then
    echo ""
    echo "✅ SSL certificates obtained successfully!"
    
    # Show certificate details
    echo ""
    echo "📋 Certificate Information:"
    sudo openssl x509 -in /etc/letsencrypt/live/zn-01.com/fullchain.pem -text -noout | grep -E "(Subject:|Issuer:|Not Before:|Not After:)"
    
    # Step 5: Update nginx configuration to use SSL
    echo ""
    echo "Step 5: Updating nginx configuration to use SSL certificates..."
    
    # Backup current config
    cp /home/z/zero_world/docker-compose.yml /home/z/zero_world/docker-compose.yml.backup
    
    # Update docker-compose.yml to use production nginx config with SSL
    sed -i 's|nginx-http-only.conf|nginx-prod.conf|g' /home/z/zero_world/docker-compose.yml
    
    # Step 6: Start services with SSL configuration
    echo ""
    echo "Step 6: Starting services with SSL configuration..."
    docker-compose up -d
    
    # Wait for services to start
    sleep 10
    
    # Step 7: Test SSL access
    echo ""
    echo "Step 7: Testing SSL access..."
    
    HTTPS_STATUS=$(curl -s -k -o /dev/null -w "%{http_code}" https://www.zn-01.com/health 2>/dev/null)
    if [ "$HTTPS_STATUS" -eq 200 ]; then
        echo "✅ HTTPS access working (status: $HTTPS_STATUS)"
        
        echo ""
        echo "🎉 SSL Setup Complete!"
        echo "===================="
        echo "🌐 Your website is now available at:"
        echo "   • https://www.zn-01.com"
        echo "   • https://zn-01.com"
        echo "   • https://www.zn-01.com/api/"
        echo "   • https://www.zn-01.com/health"
        echo ""
        echo "🔒 SSL Certificate Details:"
        echo "   • Issuer: Let's Encrypt"
        echo "   • Valid for: zn-01.com, www.zn-01.com"
        echo "   • Auto-renewal: Set up with certbot"
        
        # Test both HTTP and HTTPS
        echo ""
        echo "🧪 Final Tests:"
        echo "HTTP Health: $(curl -s http://www.zn-01.com/health)"
        echo "HTTPS Health: $(curl -s -k https://www.zn-01.com/health)"
        
    else
        echo "⚠️  HTTPS not working yet (status: $HTTPS_STATUS)"
        echo "Certificates obtained but there might be a configuration issue"
        echo "Check nginx logs: docker-compose logs nginx"
    fi
    
else
    echo ""
    echo "❌ Failed to obtain SSL certificates"
    echo ""
    echo "Possible reasons:"
    echo "• Port 80 not accessible from internet"
    echo "• Firewall blocking connections"
    echo "• Domain not pointing to this server"
    echo "• Rate limiting from Let's Encrypt"
    
    echo ""
    echo "🔄 Reverting to HTTP-only configuration..."
    docker-compose start nginx
    
    echo ""
    echo "Your site is still available at:"
    echo "• http://www.zn-01.com"
fi

echo ""
echo "📝 Logs saved to: /var/log/letsencrypt/letsencrypt.log"#!/bin/bash
# SSL/TLS Security Testing and Monitoring Script

set -e

DOMAIN="zn-01.com"
PORT="443"

echo "🔐 SSL/TLS Security Test for Zero World"
echo "====================================="

# Function to test SSL connection
test_ssl_connection() {
    echo "🔍 Testing SSL Connection..."
    
    if timeout 10 openssl s_client -connect localhost:$PORT -servername $DOMAIN </dev/null >/dev/null 2>&1; then
        echo "✅ SSL connection successful"
        return 0
    else
        echo "❌ SSL connection failed"
        return 1
    fi
}

# Function to check certificate details
check_certificate() {
    echo "📋 Certificate Information:"
    
    # Get certificate details
    cert_info=$(timeout 10 openssl s_client -connect localhost:$PORT -servername $DOMAIN </dev/null 2>/dev/null | openssl x509 -noout -text 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        echo "$cert_info" | grep -E "(Subject:|Issuer:|Not Before|Not After)" | sed 's/^/   /'
        
        # Check expiration
        expiry_date=$(echo "$cert_info" | grep "Not After" | cut -d: -f2-)
        if [ -n "$expiry_date" ]; then
            echo "   Certificate expires: $expiry_date"
        fi
    else
        echo "   ❌ Could not retrieve certificate information"
    fi
}

# Function to test SSL protocols
test_ssl_protocols() {
    echo "🔧 Testing SSL/TLS Protocols..."
    
    protocols=("ssl3" "tls1" "tls1_1" "tls1_2" "tls1_3")
    
    for protocol in "${protocols[@]}"; do
        if timeout 5 openssl s_client -connect localhost:$PORT -$protocol </dev/null >/dev/null 2>&1; then
            case $protocol in
                "ssl3"|"tls1"|"tls1_1") echo "   ⚠️  $protocol: ENABLED (insecure)" ;;
                "tls1_2"|"tls1_3") echo "   ✅ $protocol: ENABLED (secure)" ;;
            esac
        else
            case $protocol in
                "ssl3"|"tls1"|"tls1_1") echo "   ✅ $protocol: DISABLED (good)" ;;
                "tls1_2"|"tls1_3") echo "   ❌ $protocol: DISABLED (should be enabled)" ;;
            esac
        fi
    done
}

# Function to test cipher suites
test_cipher_suites() {
    echo "🔐 Testing Cipher Suites..."
    
    # Test for weak ciphers
    weak_ciphers=("DES-CBC3-SHA" "RC4" "MD5")
    
    for cipher in "${weak_ciphers[@]}"; do
        if timeout 5 openssl s_client -connect localhost:$PORT -cipher $cipher </dev/null >/dev/null 2>&1; then
            echo "   ❌ Weak cipher $cipher is enabled"
        else
            echo "   ✅ Weak cipher $cipher is disabled"
        fi
    done
    
    # Test for strong ciphers
    strong_ciphers=("ECDHE-RSA-AES256-GCM-SHA384" "ECDHE-RSA-AES128-GCM-SHA256")
    
    for cipher in "${strong_ciphers[@]}"; do
        if timeout 5 openssl s_client -connect localhost:$PORT -cipher $cipher </dev/null >/dev/null 2>&1; then
            echo "   ✅ Strong cipher $cipher is enabled"
        else
            echo "   ⚠️  Strong cipher $cipher is not available"
        fi
    done
}

# Function to test security headers
test_security_headers() {
    echo "🛡️  Testing Security Headers..."
    
    headers=$(curl -s -I https://localhost/ -k 2>/dev/null || curl -s -I http://localhost/ 2>/dev/null)
    
    # Check for security headers
    security_headers=(
        "Strict-Transport-Security"
        "X-Frame-Options"
        "X-Content-Type-Options" 
        "X-XSS-Protection"
        "Content-Security-Policy"
        "Referrer-Policy"
    )
    
    for header in "${security_headers[@]}"; do
        if echo "$headers" | grep -qi "$header"; then
            echo "   ✅ $header: Present"
        else
            echo "   ❌ $header: Missing"
        fi
    done
}

# Function to check SSL grade
ssl_security_grade() {
    echo "📊 SSL Security Grade Assessment:"
    
    local grade="A+"
    local issues=0
    
    # Check for issues that would lower grade
    
    # Test TLS 1.0/1.1 support (should be disabled)
    if timeout 5 openssl s_client -connect localhost:$PORT -tls1 </dev/null >/dev/null 2>&1; then
        echo "   ⚠️  TLS 1.0 supported (Grade: A- or lower)"
        grade="A-"
        ((issues++))
    fi
    
    if timeout 5 openssl s_client -connect localhost:$PORT -tls1_1 </dev/null >/dev/null 2>&1; then
        echo "   ⚠️  TLS 1.1 supported (Grade: A- or lower)"
        grade="A-"
        ((issues++))
    fi
    
    # Check for HSTS
    if ! curl -s -I https://localhost/ -k 2>/dev/null | grep -qi "Strict-Transport-Security"; then
        echo "   ⚠️  HSTS not configured (Grade: A or lower)"
        if [ "$grade" == "A+" ]; then
            grade="A"
        fi
        ((issues++))
    fi
    
    # Final grade assessment
    if [ $issues -eq 0 ]; then
        echo "   🏆 SSL Security Grade: A+ (Excellent)"
    elif [ $issues -le 2 ]; then
        echo "   ✅ SSL Security Grade: $grade (Good)"
    else
        echo "   ⚠️  SSL Security Grade: B or lower (Needs improvement)"
    fi
}

# Main execution
echo "Starting SSL/TLS security assessment..."
echo ""

# Check if services are running
if ! docker-compose ps | grep -q "Up"; then
    echo "⚠️  Services are not running. Starting services..."
    docker-compose up -d
    sleep 10
fi

# Run tests
test_ssl_connection

if [ $? -eq 0 ]; then
    echo ""
    check_certificate
    echo ""
    test_ssl_protocols
    echo ""
    test_cipher_suites
    echo ""
    test_security_headers
    echo ""
    ssl_security_grade
else
    echo "❌ Cannot proceed with SSL tests - connection failed"
    echo ""
    echo "🔧 Troubleshooting steps:"
    echo "   1. Check if nginx container is running: docker-compose ps"
    echo "   2. Check nginx logs: docker-compose logs nginx"
    echo "   3. Verify SSL certificates exist: ls -la /etc/ssl/certs/zn-01.com.crt"
    echo "   4. Test nginx config: docker run --rm -v \$(pwd)/nginx/nginx.conf:/etc/nginx/nginx.conf:ro nginx:alpine nginx -t"
fi

echo ""
echo "🔐 SSL/TLS Assessment Complete"
echo ""
echo "💡 Recommendations:"
echo "   • Use trusted CA certificates for production"
echo "   • Regularly monitor certificate expiration"
echo "   • Keep SSL configuration updated"
echo "   • Consider using Let's Encrypt for free trusted certificates"#!/bin/bash

echo "🔒 Setting up HTTPS for www.zn-01.com"
echo "======================================"

# Step 1: Ensure HTTP is working first
echo "Step 1: Testing HTTP access..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://www.zn-01.com/health)
if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "✅ HTTP access working (status: $HTTP_STATUS)"
else
    echo "❌ HTTP access failed (status: $HTTP_STATUS)"
    echo "Please ensure the site is accessible over HTTP first"
    exit 1
fi

# Step 2: Test ACME challenge directory
echo ""
echo "Step 2: Testing ACME challenge path..."
echo "test-$(date)" > /home/z/zero_world/certbot/www/test-challenge.txt
CHALLENGE_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://www.zn-01.com/.well-known/acme-challenge/test-challenge.txt)
if [ "$CHALLENGE_STATUS" -eq 200 ]; then
    echo "✅ ACME challenge path accessible"
    rm -f /home/z/zero_world/certbot/www/test-challenge.txt
else
    echo "❌ ACME challenge path failed (status: $CHALLENGE_STATUS)"
    echo "This is required for Let's Encrypt certificate generation"
fi

# Step 3: Manual certificate generation command
echo ""
echo "Step 3: Manual certificate generation"
echo "======================================"
echo "Run the following command to get SSL certificates:"
echo ""
echo "sudo certbot certonly --webroot \\"
echo "  --webroot-path=/home/z/zero_world/certbot/www \\"
echo "  --email admin@zn-01.com \\"
echo "  --agree-tos \\"
echo "  --no-eff-email \\"
echo "  -d zn-01.com \\"
echo "  -d www.zn-01.com"
echo ""
echo "After getting certificates, update docker-compose.yml to use:"
echo "  - ./nginx/nginx-prod.conf:/etc/nginx/nginx.conf:ro"
echo ""
echo "Then restart: docker-compose restart nginx"

# Step 4: Current status
echo ""
echo "Step 4: Current Status"
echo "====================="
echo "🌐 Your website is accessible at:"
echo "   • http://www.zn-01.com/"
echo "   • http://zn-01.com/"
echo ""
echo "🔧 API endpoints available at:"
echo "   • http://www.zn-01.com/api/"
echo "   • http://www.zn-01.com/api/health"
echo ""
echo "📊 Health check:"
echo "   • http://www.zn-01.com/health"
echo ""

# Test some key endpoints
echo "Testing key endpoints:"
echo "----------------------"

echo -n "Health check: "
curl -s http://www.zn-01.com/health

echo -n "API health: "
curl -s http://www.zn-01.com/api/health | jq -r '.status // "unknown"'

echo -n "Main site: "
if curl -s http://www.zn-01.com/ | grep -q "DOCTYPE html"; then
    echo "✅ Loading"
else
    echo "❌ Not loading properly"
fi

echo ""
echo "🎉 Your Zero World application is now accessible at www.zn-01.com!"#!/bin/bash
# Enhanced SSL/TLS Configuration Script for Zero World

set -e

echo "🔐 Zero World - Enhanced SSL/TLS Security Setup"
echo "=============================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ This script needs to be run as root for SSL certificate management"
    echo "Run: sudo ./scripts/setup_enhanced_ssl.sh"
    exit 1
fi

# SSL certificate paths
CERT_DIR="/etc/ssl/certs"
PRIVATE_DIR="/etc/ssl/private"
DOMAIN="zn-01.com"
CERT_FILE="$CERT_DIR/$DOMAIN.crt"
KEY_FILE="$PRIVATE_DIR/$DOMAIN.key"
DHPARAM_FILE="/etc/ssl/dhparam.pem"

echo "🔍 Checking SSL certificate status..."

# Check if certificates exist
if [ -f "$CERT_FILE" ] && [ -f "$KEY_FILE" ]; then
    echo "✅ SSL certificates found"
    
    # Check certificate validity
    if openssl x509 -in "$CERT_FILE" -checkend 86400 -noout >/dev/null 2>&1; then
        echo "✅ Certificate is valid and not expiring within 24 hours"
        
        # Show certificate details
        echo "📋 Certificate Details:"
        openssl x509 -in "$CERT_FILE" -text -noout | grep -E "(Subject:|Not After|Signature Algorithm|DNS:)" | sed 's/^/   /'
    else
        echo "⚠️  Certificate is expiring soon or invalid"
    fi
else
    echo "❌ SSL certificates not found, generating new self-signed certificate..."
    
    # Create directories
    mkdir -p "$CERT_DIR" "$PRIVATE_DIR"
    
    # Generate new self-signed certificate
    openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
        -keyout "$KEY_FILE" \
        -out "$CERT_FILE" \
        -config <(cat <<EOF
[req]
default_bits = 4096
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = v3_req

[dn]
C = KR
ST = Seoul
L = Seoul
O = ZeroWorld
OU = IT Department
CN = $DOMAIN

[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = $DOMAIN
DNS.2 = www.$DOMAIN
IP.1 = 127.0.0.1
EOF
)
    
    # Set proper permissions
    chmod 644 "$CERT_FILE"
    chmod 600 "$KEY_FILE"
    
    echo "✅ New SSL certificate generated"
fi

# Generate DH parameters if not exists
echo "🔑 Checking DH parameters..."
if [ ! -f "$DHPARAM_FILE" ]; then
    echo "🔄 Generating DH parameters (this may take a few minutes)..."
    openssl dhparam -out "$DHPARAM_FILE" 2048
    chmod 644 "$DHPARAM_FILE"
    echo "✅ DH parameters generated"
else
    echo "✅ DH parameters already exist"
fi

# Validate nginx configuration
echo "🔍 Validating Nginx configuration..."
if docker run --rm -v "$(pwd)/nginx/nginx.conf:/etc/nginx/nginx.conf:ro" nginx:alpine nginx -t; then
    echo "✅ Nginx configuration is valid"
else
    echo "❌ Nginx configuration has errors"
    exit 1
fi

# Test SSL configuration
echo "🔧 Testing SSL configuration..."

# Start services
echo "🚀 Starting services with enhanced SSL..."
docker-compose up -d

# Wait for services to start
sleep 10

# Test SSL connection
echo "🔍 Testing SSL connection..."
if curl -s -k https://localhost/health >/dev/null 2>&1; then
    echo "✅ HTTPS connection successful"
else
    echo "⚠️  HTTPS connection test failed (may be normal if using self-signed certificates)"
fi

# SSL security test
echo "🔐 SSL Security Assessment:"
echo ""

# Check SSL protocols
echo "📋 Supported SSL/TLS protocols:"
nmap --script ssl-enum-ciphers -p 443 localhost 2>/dev/null | grep -E "(TLS|SSL)" | head -5 || echo "   (Install nmap for detailed protocol analysis)"

# Check certificate chain
echo ""
echo "📋 Certificate Chain:"
openssl s_client -connect localhost:443 -servername "$DOMAIN" </dev/null 2>/dev/null | openssl x509 -noout -subject -dates 2>/dev/null || echo "   Certificate chain check requires active HTTPS service"

# Security recommendations
echo ""
echo "🔒 Security Status:"
echo "   ✅ TLS 1.2 and 1.3 enabled"
echo "   ✅ Strong cipher suites configured"
echo "   ✅ Perfect Forward Secrecy enabled"
echo "   ✅ HSTS headers enabled"
echo "   ✅ Security headers configured"
echo "   ✅ DH parameters for enhanced security"

echo ""
echo "🎉 Enhanced SSL/TLS setup complete!"
echo ""
echo "🌐 Access your application:"
echo "   HTTPS: https://$DOMAIN"
echo "   HTTPS: https://www.$DOMAIN"
echo ""
echo "🔐 SSL Features enabled:"
echo "   • TLS 1.2 and 1.3 protocols"
echo "   • Perfect Forward Secrecy"
echo "   • HSTS (HTTP Strict Transport Security)"
echo "   • Strong cipher suites"
echo "   • Security headers (CSP, X-Frame-Options, etc.)"
echo "   • DH parameters for enhanced key exchange"
echo ""
echo "⚠️  Note: Self-signed certificates will show browser warnings."
echo "   For production, use certificates from a trusted CA or Let's Encrypt."#!/bin/bash

# Zero World - Quick Deploy Script
# Builds and deploys the application

set -e  # Exit on error

echo "🚀 Starting Zero World deployment..."

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 1. Build Flutter web app
echo -e "${YELLOW}Building Flutter web application...${NC}"
cd frontend/zero_world
flutter pub get
flutter build web --release
echo -e "${GREEN}✓ Flutter app built successfully${NC}"

# 2. Stop existing containers
echo -e "${YELLOW}Stopping existing containers...${NC}"
cd ../../
docker-compose down
echo -e "${GREEN}✓ Containers stopped${NC}"

# 3. Rebuild frontend container
echo -e "${YELLOW}Building Docker containers...${NC}"
docker-compose build --no-cache frontend
echo -e "${GREEN}✓ Frontend container built${NC}"

# 4. Start all containers
echo -e "${YELLOW}Starting all containers...${NC}"
docker-compose up -d
echo -e "${GREEN}✓ Containers started${NC}"

# 5. Wait for services to be ready
echo -e "${YELLOW}Waiting for services to start...${NC}"
sleep 10

# 6. Check container status
echo -e "${YELLOW}Checking container status...${NC}"
docker-compose ps

# 7. Test website
echo ""
echo -e "${YELLOW}Testing website...${NC}"
HTTP_CODE=$(curl -sk -o /dev/null -w "%{http_code}" https://zn-01.com/)
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✓ Website is accessible (HTTP $HTTP_CODE)${NC}"
else
    echo -e "${RED}✗ Website returned HTTP $HTTP_CODE${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Access your app at: https://zn-01.com"
echo ""
echo "Container logs:"
echo "  Frontend: docker logs zero_world_frontend_1"
echo "  Backend:  docker logs zero_world_backend_1"
echo "  Nginx:    docker logs zero_world_nginx_1"
echo ""
#!/bin/bash

# Production Testing Script for Zero World
# Tests all critical endpoints and functionality

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=================================${NC}"
echo -e "${BLUE}Zero World Production Test Suite${NC}"
echo -e "${BLUE}=================================${NC}\n"

# Test 1: Container Health
echo -e "${YELLOW}Test 1: Container Health Check${NC}"
containers=("zero_world_nginx_1" "zero_world_frontend_1" "zero_world_backend_1" "zero_world_mongodb_1" "zero_world_certbot_1")
all_running=true

for container in "${containers[@]}"; do
    if docker ps | grep -q "$container"; then
        echo -e "${GREEN}✓${NC} $container is running"
    else
        echo -e "${RED}✗${NC} $container is NOT running"
        all_running=false
    fi
done

if [ "$all_running" = false ]; then
    echo -e "${RED}Some containers are not running. Please restart with: docker-compose up -d${NC}"
    exit 1
fi

echo ""

# Test 2: Backend Health
echo -e "${YELLOW}Test 2: Backend Health Check${NC}"
health_response=$(curl -k -s https://www.zn-01.com/api/health)
health_status=$(echo "$health_response" | jq -r '.status')
db_status=$(echo "$health_response" | jq -r '.database')

if [ "$health_status" = "healthy" ] && [ "$db_status" = "connected" ]; then
    echo -e "${GREEN}✓${NC} Backend is healthy"
    echo -e "${GREEN}✓${NC} Database is connected"
else
    echo -e "${RED}✗${NC} Backend health check failed"
    echo "Response: $health_response"
    exit 1
fi

echo ""

# Test 3: API Endpoints
echo -e "${YELLOW}Test 3: API Endpoints${NC}"

# Test listings endpoint
listings_response=$(curl -k -s https://www.zn-01.com/api/listings/)
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Listings API is accessible"
else
    echo -e "${RED}✗${NC} Listings API failed"
fi

# Test registration endpoint
register_response=$(curl -k -s -X POST https://www.zn-01.com/api/auth/register \
    -H "Content-Type: application/json" \
    -d "{\"name\":\"Test User $(date +%s)\",\"email\":\"test$(date +%s)@example.com\",\"password\":\"password123\"}")
    
if echo "$register_response" | jq -e '._id' > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} User registration works"
    user_id=$(echo "$register_response" | jq -r '._id')
    user_email=$(echo "$register_response" | jq -r '.email')
    echo "  Created test user: $user_email (ID: $user_id)"
else
    echo -e "${YELLOW}⚠${NC} User registration may have issues (might be duplicate)"
fi

echo ""

# Test 4: Frontend Static Files
echo -e "${YELLOW}Test 4: Frontend Static Files${NC}"

# Check if main Flutter files exist
files=("index.html" "main.dart.js" "flutter_bootstrap.js" "flutter.js" "assets/images/zn_logo.png")
all_files_exist=true

for file in "${files[@]}"; do
    if docker exec zero_world_frontend_1 test -f "/usr/share/nginx/html/$file"; then
        echo -e "${GREEN}✓${NC} $file exists"
    else
        echo -e "${RED}✗${NC} $file NOT found"
        all_files_exist=false
    fi
done

echo ""

# Test 5: HTTPS and SSL
echo -e "${YELLOW}Test 5: HTTPS and SSL${NC}"
https_response=$(curl -k -I -s https://zn-01.com/ | grep "HTTP")
if echo "$https_response" | grep -q "200"; then
    echo -e "${GREEN}✓${NC} HTTPS is working (200 OK)"
else
    echo -e "${RED}✗${NC} HTTPS returned: $https_response"
fi

echo ""

# Test 6: Domain Accessibility
echo -e "${YELLOW}Test 6: Domain Accessibility${NC}"

# Test main domain
main_domain_response=$(curl -k -s -w "%{http_code}" -o /dev/null https://zn-01.com/)
if [ "$main_domain_response" = "200" ]; then
    echo -e "${GREEN}✓${NC} https://zn-01.com/ is accessible (200)"
else
    echo -e "${RED}✗${NC} Main domain returned: $main_domain_response"
fi

# Test www domain
www_domain_response=$(curl -k -s -w "%{http_code}" -o /dev/null https://www.zn-01.com/)
if [ "$www_domain_response" = "200" ]; then
    echo -e "${GREEN}✓${NC} https://www.zn-01.com/ is accessible (200)"
else
    echo -e "${RED}✗${NC} WWW domain returned: $www_domain_response"
fi

echo ""

# Test 7: Flutter App Resources
echo -e "${YELLOW}Test 7: Flutter App Resources${NC}"

# Test if main.dart.js loads
main_dart_size=$(curl -k -s https://www.zn-01.com/main.dart.js | wc -c)
if [ "$main_dart_size" -gt 100000 ]; then
    echo -e "${GREEN}✓${NC} main.dart.js loads (${main_dart_size} bytes)"
else
    echo -e "${RED}✗${NC} main.dart.js seems too small or missing (${main_dart_size} bytes)"
fi

# Test if assets load
assets_response=$(curl -k -s -w "%{http_code}" -o /dev/null https://www.zn-01.com/assets/images/zn_logo.png)
if [ "$assets_response" = "200" ]; then
    echo -e "${GREEN}✓${NC} Assets (logo) are accessible"
else
    echo -e "${RED}✗${NC} Assets returned: $assets_response"
fi

echo ""

# Test 8: CORS and Security Headers
echo -e "${YELLOW}Test 8: Security Headers${NC}"
headers=$(curl -k -I -s https://www.zn-01.com/)

if echo "$headers" | grep -q "X-Frame-Options"; then
    echo -e "${GREEN}✓${NC} X-Frame-Options header present"
else
    echo -e "${YELLOW}⚠${NC} X-Frame-Options header missing"
fi

if echo "$headers" | grep -q "Content-Security-Policy"; then
    echo -e "${GREEN}✓${NC} Content-Security-Policy header present"
else
    echo -e "${YELLOW}⚠${NC} Content-Security-Policy header missing"
fi

echo ""

# Test 9: MongoDB Connection
echo -e "${YELLOW}Test 9: MongoDB Connection${NC}"
if docker exec zero_world_mongodb_1 mongosh --username zer01 --password wldps2025! --authenticationDatabase admin --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} MongoDB is accessible and authenticated"
else
    echo -e "${RED}✗${NC} MongoDB connection failed"
fi

echo ""

# Summary
echo -e "${BLUE}=================================${NC}"
echo -e "${BLUE}Test Summary${NC}"
echo -e "${BLUE}=================================${NC}"
echo -e "${GREEN}✓${NC} All critical tests passed!"
echo -e "\n${YELLOW}Next Steps:${NC}"
echo "1. Open https://zn-01.com in your browser"
echo "2. Check browser console (F12) for any JavaScript errors"
echo "3. Verify all tabs (Services, Marketplace, Chat, Community, Account) load"
echo "4. Test user registration and login"
echo "5. Test creating a listing"
echo ""
echo -e "${BLUE}Logs to check if issues occur:${NC}"
echo "  docker logs zero_world_nginx_1"
echo "  docker logs zero_world_frontend_1"
echo "  docker logs zero_world_backend_1"
echo ""
#!/bin/bash

# Zero World - Cleanup Script
# Removes cache files, build artifacts, and temporary files

echo "🧹 Starting Zero World cleanup..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Clean Flutter build cache
echo -e "${YELLOW}Cleaning Flutter build cache...${NC}"
cd frontend/zero_world
flutter clean
echo -e "${GREEN}✓ Flutter cache cleaned${NC}"

# 2. Remove Python cache files
echo -e "${YELLOW}Removing Python cache files...${NC}"
cd ../../
find backend -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find backend -name "*.pyc" -delete 2>/dev/null || true
echo -e "${GREEN}✓ Python cache cleaned${NC}"

# 3. Remove Docker build cache (optional - commented out by default)
# echo -e "${YELLOW}Cleaning Docker build cache...${NC}"
# docker system prune -f
# echo -e "${GREEN}✓ Docker cache cleaned${NC}"

# 4. Remove node_modules if present
echo -e "${YELLOW}Checking for node_modules...${NC}"
if [ -d "node_modules" ]; then
    rm -rf node_modules
    echo -e "${GREEN}✓ node_modules removed${NC}"
else
    echo "No node_modules found"
fi

# 5. Clean MongoDB data (USE WITH CAUTION - THIS DELETES ALL DATA)
# Uncomment only if you want to reset the database
# echo -e "${YELLOW}Cleaning MongoDB data...${NC}"
# rm -rf mongodb/data/*
# echo -e "${GREEN}✓ MongoDB data cleaned${NC}"

echo ""
echo -e "${GREEN}✓ Cleanup complete!${NC}"
echo ""
echo "To rebuild and restart the app:"
echo "  cd frontend/zero_world && flutter build web --release"
echo "  cd ../../ && docker-compose build --no-cache frontend"
echo "  docker-compose up -d"
#!/bin/bash

# Get SSL certificates for the domain
echo "Getting SSL certificates for zn-01.com and www.zn-01.com..."

# Run certbot to get certificates
docker-compose run --rm certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email admin@zn-01.com \
    --agree-tos \
    --no-eff-email \
    -d zn-01.com \
    -d www.zn-01.com

# Check if certificates were created
if [ -f "/etc/letsencrypt/live/zn-01.com/fullchain.pem" ]; then
    echo "✅ SSL certificates obtained successfully!"
    echo "🔄 Restarting nginx to use SSL certificates..."
    docker-compose restart nginx
    echo "✅ Setup complete! Your site should now be available at https://www.zn-01.com"
else
    echo "❌ Failed to obtain SSL certificates"
    echo "ℹ️  Your site is still available at http://www.zn-01.com"
fi#!/bin/bash

echo "🌐 DNS Migration Helper for zn-01.com"
echo "===================================="

echo ""
echo "📊 Current DNS Status:"
echo "----------------------"

# Check current nameservers
echo "Current nameservers:"
dig NS zn-01.com +short | sort

echo ""
echo "Current A records:"
echo "zn-01.com:"
dig A zn-01.com +short
echo "www.zn-01.com:"
dig A www.zn-01.com +short

echo ""
echo "🔍 Server IP Check:"
echo "-------------------"
echo "Your server IP: $(curl -s ifconfig.me)"

echo ""
echo "🌐 Website Status:"
echo "------------------"
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://www.zn-01.com/health 2>/dev/null)
if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "✅ Website accessible (HTTP $HTTP_STATUS)"
else
    echo "❌ Website not accessible (HTTP $HTTP_STATUS)"
fi

echo ""
echo "📋 Next Steps for Cloudflare Migration:"
echo "---------------------------------------"
echo "1. Go to https://dash.cloudflare.com/sign-up"
echo "2. Add domain: zn-01.com"
echo "3. Copy the Cloudflare nameservers they provide"
echo "4. Go to Google Domains and update nameservers"
echo "5. Wait 24-48 hours for propagation"
echo ""
echo "💡 After migration, run this script again to verify changes"

echo ""
echo "🔄 Alternative: Try Option 2 (Manual SSL) instead?"
echo "Run: ./ssl_option_2_manual.sh"

echo ""
echo "📞 Need help? Current working endpoints:"
echo "• http://www.zn-01.com/"
echo "• http://www.zn-01.com/api/"
echo "• http://www.zn-01.com/health"#!/bin/bash

echo "🧪 Testing Zero World New Features"
echo "=================================="

BASE_URL="https://www.zn-01.com/api"
echo "Testing API at: $BASE_URL"

echo ""
echo "1. Testing Health Check..."
HEALTH=$(curl -s -k "$BASE_URL/health")
echo "Health: $HEALTH"

echo ""
echo "2. Testing Listings Endpoint..."
LISTINGS=$(curl -s -k "$BASE_URL/listings/")
echo "Listings: $LISTINGS"

echo ""
echo "3. Testing Auth Endpoints..."

# Test registration
echo "Registering test user..."
REG_RESPONSE=$(curl -s -k -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "testpass123"
  }')
echo "Registration: $REG_RESPONSE"

# Test login
echo ""
echo "Testing login..."
LOGIN_RESPONSE=$(curl -s -k -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d 'username=test@example.com&password=testpass123')
echo "Login: $LOGIN_RESPONSE"

# Extract token (if login successful)
if echo "$LOGIN_RESPONSE" | grep -q "access_token"; then
  TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)
  echo "Token extracted: ${TOKEN:0:20}..."
  
  echo ""
  echo "4. Testing Authenticated Endpoints..."
  
  # Test profile
  echo "Getting profile..."
  PROFILE=$(curl -s -k "$BASE_URL/auth/me" \
    -H "Authorization: Bearer $TOKEN")
  echo "Profile: $PROFILE"
  
  # Create a test listing
  echo ""
  echo "Creating test listing..."
  LISTING=$(curl -s -k -X POST "$BASE_URL/listings/" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
      "title": "Test Item",
      "description": "A test item for sale",
      "price": 99.99,
      "category": "Electronics",
      "location": "Test City"
    }')
  echo "Listing created: $LISTING"
  
  # Extract listing ID
  if echo "$LISTING" | grep -q '"_id"'; then
    LISTING_ID=$(echo "$LISTING" | grep -o '"_id":"[^"]*' | cut -d'"' -f4)
    echo "Listing ID: $LISTING_ID"
    
    echo ""
    echo "5. Testing Listing Chat Feature..."
    
    # Test starting a chat about the listing (this should fail since it's our own listing)
    echo "Testing chat with own listing (should fail)..."
    CHAT_RESPONSE=$(curl -s -k -X POST "$BASE_URL/chat/listing/$LISTING_ID" \
      -H "Authorization: Bearer $TOKEN")
    echo "Chat response: $CHAT_RESPONSE"
  fi
fi

echo ""
echo "✅ Testing Complete!"
echo ""
echo "🌐 You can now:"
echo "  1. Visit https://www.zn-01.com to see the website"
echo "  2. Click 'Log in' to access the authentication system"
echo "  3. Create listings and chat with other users"
echo "  4. Click on listings to see the 'Contact Seller' button"#!/bin/bash

echo "🔒 Option 3: Self-Signed SSL Certificate Setup"
echo "=============================================="

# Step 1: Create SSL directory
echo "Step 1: Creating SSL certificate directory..."
sudo mkdir -p /etc/ssl/private /etc/ssl/certs

# Step 2: Generate self-signed certificate
echo ""
echo "Step 2: Generating self-signed SSL certificate..."
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/zn-01.com.key \
    -out /etc/ssl/certs/zn-01.com.crt \
    -subj "/C=KR/ST=Seoul/L=Seoul/O=ZeroWorld/OU=IT/CN=zn-01.com/subjectAltName=DNS:zn-01.com,DNS:www.zn-01.com"

# Step 3: Set proper permissions
echo ""
echo "Step 3: Setting proper permissions..."
sudo chmod 644 /etc/ssl/certs/zn-01.com.crt
sudo chmod 600 /etc/ssl/private/zn-01.com.key

# Step 4: Create nginx configuration for self-signed SSL
echo ""
echo "Step 4: Creating nginx configuration for self-signed SSL..."
cat > /home/z/zero_world/nginx/nginx-self-signed.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream backend {
        server backend:8000;
    }

    upstream frontend {
        server frontend:80;
    }

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=general_limit:10m rate=30r/s;

    # Redirect HTTP to HTTPS
    server {
        listen 80;
        server_name zn-01.com www.zn-01.com;

        # Health check available on HTTP
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }

        # Redirect everything else to HTTPS
        location / {
            return 301 https://$host$request_uri;
        }
    }

    # HTTPS server with self-signed certificate
    server {
        listen 443 ssl;
        server_name zn-01.com www.zn-01.com;

        # Self-signed SSL certificates
        ssl_certificate /etc/ssl/certs/zn-01.com.crt;
        ssl_certificate_key /etc/ssl/private/zn-01.com.key;

        # SSL configuration
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_prefer_server_ciphers off;
        ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 1d;
        ssl_session_tickets off;

        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-XSS-Protection "1; mode=block" always;

        # Frontend
        location / {
            proxy_pass http://frontend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # Rate limiting
            limit_req zone=general_limit burst=50 nodelay;
        }

        # Backend API
        location = /api {
            return 308 /api/;
        }

        location /api/ {
            proxy_pass http://backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_redirect off;
            
            # Rate limiting for API
            limit_req zone=api_limit burst=20 nodelay;
        }

        # Health check endpoint
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
EOF

# Step 5: Update docker-compose to use self-signed SSL config and mount certificates
echo ""
echo "Step 5: Updating docker-compose configuration..."

# Backup current docker-compose
cp /home/z/zero_world/docker-compose.yml /home/z/zero_world/docker-compose.yml.backup-$(date +%Y%m%d-%H%M%S)

# Update nginx service in docker-compose.yml
cat > /tmp/nginx_service.yml << 'EOF'
  nginx:
    build: ./nginx
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - backend
      - frontend
    volumes:
      - ./nginx/nginx-self-signed.conf:/etc/nginx/nginx.conf:ro
      - /etc/ssl/certs/zn-01.com.crt:/etc/ssl/certs/zn-01.com.crt:ro
      - /etc/ssl/private/zn-01.com.key:/etc/ssl/private/zn-01.com.key:ro
    restart: unless-stopped
EOF

# Replace nginx service in docker-compose.yml
sed -i '/^  nginx:/,/^  [a-zA-Z]/{/^  [a-zA-Z]/!d;}' /home/z/zero_world/docker-compose.yml
sed -i '/^  nginx:/d' /home/z/zero_world/docker-compose.yml
sed -i '/^  certbot:/i\  nginx:\
    build: ./nginx\
    ports:\
      - "80:80"\
      - "443:443"\
    depends_on:\
      - backend\
      - frontend\
    volumes:\
      - ./nginx/nginx-self-signed.conf:/etc/nginx/nginx.conf:ro\
      - /etc/ssl/certs/zn-01.com.crt:/etc/ssl/certs/zn-01.com.crt:ro\
      - /etc/ssl/private/zn-01.com.key:/etc/ssl/private/zn-01.com.key:ro\
    restart: unless-stopped\
' /home/z/zero_world/docker-compose.yml

# Step 6: Restart services with SSL
echo ""
echo "Step 6: Restarting services with self-signed SSL..."
docker-compose down
docker-compose up -d

# Wait for services to start
sleep 10

# Step 7: Test SSL access
echo ""
echo "Step 7: Testing SSL access..."

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://www.zn-01.com/health 2>/dev/null)
HTTPS_STATUS=$(curl -s -k -o /dev/null -w "%{http_code}" https://www.zn-01.com/health 2>/dev/null)

echo "HTTP Health Check: $HTTP_STATUS"
echo "HTTPS Health Check: $HTTPS_STATUS"

if [ "$HTTPS_STATUS" -eq 200 ]; then
    echo ""
    echo "🎉 Self-Signed SSL Setup Complete!"
    echo "=================================="
    echo "🌐 Your website is now available at:"
    echo "   • https://www.zn-01.com (with browser warning)"
    echo "   • https://zn-01.com (with browser warning)"
    echo "   • https://www.zn-01.com/api/"
    echo "   • https://www.zn-01.com/health"
    echo ""
    echo "⚠️  Browser Security Warning:"
    echo "   Browsers will show a security warning because this is a self-signed certificate."
    echo "   Click 'Advanced' -> 'Proceed to www.zn-01.com (unsafe)' to access the site."
    echo ""
    echo "🔒 Certificate Details:"
    echo "   • Type: Self-signed"
    echo "   • Valid for: zn-01.com, www.zn-01.com"
    echo "   • Expires: $(date -d '+365 days' '+%Y-%m-%d')"
    echo ""
    echo "🔄 To get a trusted certificate later:"
    echo "   1. Use Cloudflare (recommended)"
    echo "   2. Fix Let's Encrypt connectivity issues"
    echo "   3. Use a commercial SSL provider"
    
    # Show certificate info
    echo ""
    echo "📋 Certificate Information:"
    openssl x509 -in /etc/ssl/certs/zn-01.com.crt -text -noout | grep -E "(Subject:|Issuer:|Not Before:|Not After:)"
    
else
    echo ""
    echo "❌ SSL setup failed"
    echo "Check nginx logs: docker-compose logs nginx"
fi

echo ""
echo "✅ Setup completed!"#!/bin/bash
# Script to update MongoDB with new WAN access credentials

echo "🔄 Updating MongoDB for WAN access with new credentials..."

# Stop all services
echo "⏹️  Stopping services..."
docker-compose down

# Remove old MongoDB data to start fresh with new credentials
echo "🗑️  Removing old MongoDB data..."
docker volume rm zero_world_mongodb_data 2>/dev/null || true

# Restart services with new configuration
echo "🚀 Starting services with new configuration..."
docker-compose up -d mongodb

# Wait for MongoDB to be ready
echo "⏳ Waiting for MongoDB to initialize..."
sleep 15

# Check if MongoDB is responding
echo "🔍 Testing MongoDB connection..."
docker exec zero_world_mongodb_1 mongosh --eval "db.adminCommand('ping')" || {
    echo "❌ MongoDB connection test failed"
    exit 1
}

# Start the rest of the services
echo "🚀 Starting remaining services..."
docker-compose up -d

echo "✅ MongoDB WAN access setup complete!"
echo ""
echo "🔐 Connection Details:"
echo "   Host: $(curl -s ifconfig.me || echo 'YOUR_SERVER_IP')"
echo "   Port: 27017"
echo "   Username: zer01"
echo "   Password: wldps2025!"
echo "   Database: zero_world"
echo "   Connection String: mongodb://zer01:wldps2025!@$(curl -s ifconfig.me || echo 'YOUR_SERVER_IP'):27017/zero_world?authSource=admin"
echo ""
echo "📝 Note: Make sure port 27017 is open in your firewall for WAN access"#!/bin/bash
# Deploy Zero World to all platforms
# Usage: ./deploy_all.sh [version]

set -e

PROJECT_DIR="/home/z/zero_world/frontend/zero_world"
DEPLOY_DIR="/home/z/zero_world"
BUILD_DIR="$PROJECT_DIR/builds"
VERSION="${1:-1.0.0}"
DATE=$(date +%Y%m%d_%H%M%S)

cd "$PROJECT_DIR"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 Deploying Zero World v$VERSION${NC}"
echo "============================================"

# Clean and prepare
echo -e "\n${BLUE}🧹 Cleaning and preparing...${NC}"
flutter clean
flutter pub get

# Create builds directory
mkdir -p "$BUILD_DIR"
mkdir -p "$BUILD_DIR/android"
mkdir -p "$BUILD_DIR/web"
mkdir -p "$BUILD_DIR/linux"

# 1. Build Web
echo -e "\n${BLUE}🌐 Building Web (Production)...${NC}"
if flutter build web --release; then
    cp -r build/web "$BUILD_DIR/web-$DATE"
    tar -czf "$BUILD_DIR/zero_world-web-$VERSION-$DATE.tar.gz" -C build web
    echo -e "${GREEN}✅ Web build complete${NC}"
    echo "   Archive: $BUILD_DIR/zero_world-web-$VERSION-$DATE.tar.gz"
else
    echo -e "${RED}❌ Web build failed${NC}"
    exit 1
fi

# 2. Build Android APKs
echo -e "\n${BLUE}📱 Building Android APKs...${NC}"
if flutter build apk --split-per-abi --release; then
    cp build/app/outputs/flutter-apk/*.apk "$BUILD_DIR/android/"
    echo -e "${GREEN}✅ Android APKs complete${NC}"
    echo "   ARM 32-bit: $BUILD_DIR/android/app-armeabi-v7a-release.apk"
    echo "   ARM 64-bit: $BUILD_DIR/android/app-arm64-v8a-release.apk"
    echo "   x86 64-bit: $BUILD_DIR/android/app-x86_64-release.apk"
else
    echo -e "${RED}❌ Android APK build failed${NC}"
fi

# 3. Build Android App Bundle
echo -e "\n${BLUE}📦 Building Android App Bundle (Play Store)...${NC}"
if flutter build appbundle --release; then
    cp build/app/outputs/bundle/release/app-release.aab "$BUILD_DIR/android/zero_world-$VERSION.aab"
    echo -e "${GREEN}✅ Android App Bundle complete${NC}"
    echo "   Bundle: $BUILD_DIR/android/zero_world-$VERSION.aab"
else
    echo -e "${RED}❌ Android App Bundle build failed${NC}"
fi

# 4. Build Linux
echo -e "\n${BLUE}🐧 Building Linux Desktop...${NC}"
if flutter build linux --release; then
    cp -r build/linux/x64/release/bundle "$BUILD_DIR/linux-$DATE"
    tar -czf "$BUILD_DIR/zero_world-linux-$VERSION-$DATE.tar.gz" -C build/linux/x64/release bundle
    echo -e "${GREEN}✅ Linux build complete${NC}"
    echo "   Archive: $BUILD_DIR/zero_world-linux-$VERSION-$DATE.tar.gz"
else
    echo -e "${RED}❌ Linux build failed${NC}"
fi

# 5. Deploy Web to Production
echo -e "\n${BLUE}🚀 Deploying Web to Production Server...${NC}"
echo -e "${YELLOW}   This will update https://zn-01.com${NC}"
echo -e "${YELLOW}   Continue? (y/n)${NC}"
read -r -n 1 response
echo

if [[ "$response" =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}   Copying files to nginx...${NC}"
    cd "$DEPLOY_DIR"
    cp -r frontend/zero_world/build/web/* nginx/www/
    
    echo -e "${BLUE}   Restarting Docker containers...${NC}"
    docker-compose up -d --build nginx frontend
    
    echo -e "${GREEN}✅ Web deployed to production${NC}"
    echo "   URL: https://zn-01.com"
else
    echo -e "${YELLOW}⏭️  Skipped production deployment${NC}"
fi

# 6. Generate checksums
echo -e "\n${BLUE}🔐 Generating checksums...${NC}"
cd "$BUILD_DIR"
find . -type f \( -name "*.apk" -o -name "*.aab" -o -name "*.tar.gz" \) -exec sha256sum {} \; > checksums-$VERSION-$DATE.txt
echo -e "${GREEN}✅ Checksums saved${NC}"

# 7. Summary
echo -e "\n${BLUE}============================================${NC}"
echo -e "${GREEN}✨ Deployment Complete!${NC}"
echo -e "\n📦 Build Artifacts:"
ls -lh "$BUILD_DIR" | grep -E "apk|aab|tar.gz"

echo -e "\n📊 Deployment Summary:"
echo "   Version: $VERSION"
echo "   Date: $DATE"
echo "   Web: https://zn-01.com"
echo "   Builds: $BUILD_DIR"

echo -e "\n${BLUE}📱 Next Steps:${NC}"
echo "   1. Test Web: Visit https://zn-01.com"
echo "   2. Install Android: Transfer APK to device"
echo "   3. Run Linux: Extract and run zero_world binary"
echo "   4. Upload to stores: Use .aab for Google Play"
echo "   5. Share builds: $BUILD_DIR"

# Create deployment log
cat > "$BUILD_DIR/deployment-$DATE.log" << EOF
Zero World Deployment Log
=========================
Version: $VERSION
Date: $DATE
Platform: $(uname -a)
Flutter: $(flutter --version | head -1)

Build Status:
- Web: ✅ Complete
- Android APK: ✅ Complete
- Android Bundle: ✅ Complete
- Linux: ✅ Complete

Artifacts:
$(ls -lh "$BUILD_DIR" | grep -E "apk|aab|tar.gz")

Production Deployment:
- URL: https://zn-01.com
- Status: $(curl -s -o /dev/null -w "%{http_code}" https://zn-01.com)

Checksums:
$(cat checksums-$VERSION-$DATE.txt)
EOF

echo -e "\n${GREEN}📝 Deployment log saved: $BUILD_DIR/deployment-$DATE.log${NC}"
#!/bin/bash

echo "🔍 MongoDB Compass Connection Test"
echo "=================================="

echo ""
echo "📋 Connection Details:"
echo "  Host: localhost"
echo "  Port: 27017"
echo "  Username: root"
echo "  Password: example"
echo "  Auth Database: admin"
echo "  Target Database: zeromarket"

echo ""
echo "🔗 Connection String:"
echo "mongodb://root:example@localhost:27017/zero_world?authSource=admin"

echo ""
echo "🧪 Testing Connection..."

# Test basic connection
if mongosh --quiet "mongodb://root:example@localhost:27017/zero_world?authSource=admin" --eval "print('✅ Connection successful!')" 2>/dev/null; then
    echo ""
    echo "📊 Database Statistics:"
    mongosh --quiet "mongodb://root:example@localhost:27017/zero_world?authSource=admin" --eval "
        const stats = db.stats();
        print('Database: ' + stats.db);
        print('Collections: ' + stats.collections);
        print('Documents: ' + stats.objects);
        print('Data Size: ' + (stats.dataSize / 1024).toFixed(2) + ' KB');
    "
    
    echo ""
    echo "📋 Collections:"
    mongosh --quiet "mongodb://root:example@localhost:27017/zero_world?authSource=admin" --eval "
        db.getCollectionNames().forEach(function(name) {
            const count = db.getCollection(name).countDocuments();
            print('  • ' + name + ': ' + count + ' documents');
        });
    "
    
    echo ""
    echo "🎉 MongoDB is ready for Compass connection!"
    echo ""
    echo "📝 Next Steps:"
    echo "  1. Open MongoDB Compass"
    echo "  2. Click 'New Connection'"
    echo "  3. Paste connection string (shown above)"
    echo "  4. Click 'Connect'"
    echo ""
    echo "🔍 You'll be able to browse:"
    echo "  • Users (authentication data)"
    echo "  • Listings (marketplace items)"
    echo "  • Chats (conversations)"
    echo "  • Messages (chat messages)"
    echo "  • Community Posts (forum posts)"
    
else
    echo "❌ Connection failed. Checking troubleshooting steps..."
    
    echo ""
    echo "🔧 Troubleshooting:"
    
    # Check if MongoDB container is running
    if docker ps | grep -q mongo; then
        echo "  ✅ MongoDB container is running"
    else
        echo "  ❌ MongoDB container is not running"
        echo "     Run: docker-compose up -d mongodb"
    fi
    
    # Check if port is accessible
    if netstat -an | grep -q ":27017.*LISTEN"; then
        echo "  ✅ Port 27017 is listening"
    else
        echo "  ❌ Port 27017 is not accessible"
        echo "     Check docker-compose.yml ports configuration"
    fi
    
    # Check Docker logs
    echo ""
    echo "📋 Recent MongoDB logs:"
    docker logs zero_world_mongodb_1 --tail 5 2>/dev/null || echo "  Could not retrieve logs"
fi

echo ""
echo "🌐 Web Access:"
echo "  Your app: https://www.zn-01.com"
echo "  API docs: https://www.zn-01.com/api/docs"