# Option 1: Cloudflare SSL Setup

## Steps to set up Cloudflare SSL:

### 1. Sign up for Cloudflare (if not already done)
- Go to https://cloudflare.com
- Create a free account
- Add your domain: zn-01.com

### 2. Change nameservers at Google Domains
- Login to your Google Domains account
- Find zn-01.com domain
- Go to DNS settings
- Change nameservers from Google to Cloudflare nameservers (Cloudflare will provide these)

### 3. Configure Cloudflare settings
- SSL/TLS Mode: Set to "Full (strict)" or "Full"
- Always Use HTTPS: Enable
- Automatic HTTPS Rewrites: Enable
- Minimum TLS Version: 1.2

### 4. Update your nginx configuration
- Use the production nginx config with SSL
- Cloudflare will handle SSL termination

### 5. Benefits of Cloudflare:
- Free SSL certificates (automatically renewed)
- CDN and caching
- DDoS protection
- Better performance worldwide
- Easy management

### Current Status: NOT CONFIGURED
Your domain is currently using Google Domains nameservers.
To use this option, you need to migrate DNS to Cloudflare.

### Next Steps:
1. Go to cloudflare.com and add your domain
2. Follow their nameserver change instructions
3. Wait for propagation (24-48 hours)
4. Update nginx configuration