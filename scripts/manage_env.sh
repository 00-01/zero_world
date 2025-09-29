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

main "$@"