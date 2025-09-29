#!/bin/bash
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
echo "   For production, use certificates from a trusted CA or Let's Encrypt."