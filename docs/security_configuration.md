# Security Configuration Guide

## 🔒 Protecting Sensitive Data

This project now uses environment variables to protect sensitive information like database credentials, API keys, and other secrets from being committed to Git.

### 📋 Environment Variables

All sensitive data is stored in environment variables. See `.env.example` for a template of required variables.

#### Required Environment Variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `MONGODB_USERNAME` | MongoDB username | `zer01` |
| `MONGODB_PASSWORD` | MongoDB password | `wldps2025!` |
| `MONGODB_HOST` | MongoDB host | `mongodb` |
| `MONGODB_PORT` | MongoDB port | `27017` |
| `MONGODB_DATABASE` | Database name | `zero_world` |
| `JWT_SECRET` | JWT signing secret | `your_super_secret_key` |
| `DOMAIN_NAME` | Your domain | `zn-01.com` |
| `EXTERNAL_MONGODB_HOST` | External IP for WAN access | `122.44.174.254` |

### 🚀 Setup Instructions

1. **Copy the template:**
   ```bash
   cp .env.example .env
   ```

2. **Edit the .env file with your actual values:**
   ```bash
   nano .env
   ```

3. **Never commit the .env file:**
   The `.env` file is already in `.gitignore` to prevent accidental commits.

### 🔐 Git Protection

The following files and patterns are protected from Git commits:

#### Environment Files:
- `.env` (main environment file)
- `.env.local`, `.env.production`, `.env.staging`
- `*.env` (any file ending with .env)
- `secrets/` directory
- `config/secrets/` directory

#### Certificates and Keys:
- `*.key` (private keys)
- `*.crt` (certificates)
- `*.pem` (PEM files)
- `*.p12`, `*.pfx` (certificate bundles)
- `ssl/`, `certs/`, `private/` directories

#### Database Configuration:
- `database.conf`
- `mongodb.conf`
- `*.db.config`

#### API Keys and Authentication:
- `api_keys.txt`
- `*.api`, `*.secret`
- `auth_config.*`

### ⚠️ Security Best Practices

1. **Never hard-code credentials** in source code
2. **Use strong passwords** for all accounts
3. **Rotate secrets regularly** especially JWT secrets
4. **Limit database access** to necessary IPs only
5. **Use HTTPS** for all external communications
6. **Monitor access logs** regularly

### 🔧 Configuration Management

The application uses a centralized configuration system in `backend/app/config.py`:

- All environment variables are defined in the `Settings` class
- Default fallback values are provided for development
- Configuration is imported throughout the application

### 📝 Before Deployment

1. **Generate a strong JWT secret:**
   ```bash
   openssl rand -hex 32
   ```

2. **Update production credentials** in your `.env` file

3. **Verify no secrets in Git history:**
   ```bash
   git log --all --grep="password\|secret\|key" -i
   ```

4. **Test with environment variables:**
   ```bash
   docker-compose config
   ```

### 🚨 Emergency Procedures

If credentials are accidentally committed:

1. **Immediately change all exposed credentials**
2. **Revoke and regenerate API keys**
3. **Use Git filter-branch to remove from history:**
   ```bash
   git filter-branch --force --index-filter 'git rm --cached --ignore-unmatch .env' --prune-empty --tag-name-filter cat -- --all
   ```
4. **Force push to remote** (⚠️ This rewrites history)
5. **Inform team members** to re-clone the repository

### ✅ Verification Checklist

- [ ] `.env` file is not tracked by Git
- [ ] `.env.example` contains all required variables (without values)
- [ ] All sensitive data uses environment variables
- [ ] Strong JWT secret is configured
- [ ] MongoDB credentials are secure
- [ ] SSL certificates are properly protected
- [ ] External access is properly secured