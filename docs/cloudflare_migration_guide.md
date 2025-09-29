# Cloudflare DNS Migration Guide for zn-01.com

## Current Status
Your domain `zn-01.com` is currently using Google Domains nameservers:
- ns-cloud-d1.googledomains.com
- ns-cloud-d2.googledomains.com  
- ns-cloud-d3.googledomains.com
- ns-cloud-d4.googledomains.com

## Step-by-Step Migration to Cloudflare

### 1. Create Cloudflare Account
1. Go to https://dash.cloudflare.com/sign-up
2. Create a free account
3. Verify your email

### 2. Add Your Domain to Cloudflare
1. Click "Add a Site" 
2. Enter: zn-01.com
3. Select "Free Plan"
4. Cloudflare will scan your existing DNS records

### 3. Review DNS Records
Cloudflare will show your current DNS records. Make sure these are correct:
- A record: zn-01.com → 122.44.174.254
- A record: www.zn-01.com → 122.44.174.254

### 4. Get Cloudflare Nameservers
Cloudflare will provide you with two nameservers, something like:
- xxx.ns.cloudflare.com
- yyy.ns.cloudflare.com

### 5. Update Nameservers at Google Domains
1. Go to https://domains.google.com
2. Find zn-01.com domain
3. Click on the domain name
4. Go to "DNS" tab
5. Click "Use custom name servers"
6. Replace Google nameservers with Cloudflare nameservers
7. Save changes

### 6. Wait for Propagation
- DNS propagation takes 24-48 hours
- You can check status at Cloudflare dashboard
- Use online DNS checkers to monitor progress

### 7. Configure SSL in Cloudflare
Once nameservers are active:
1. Go to SSL/TLS tab in Cloudflare
2. Set SSL mode to "Full (strict)"
3. Enable "Always Use HTTPS"
4. Enable "Automatic HTTPS Rewrites"

### 8. Update Your Server Configuration
Once Cloudflare is active, update your nginx config to work with Cloudflare SSL.

## Benefits After Migration
✅ Free SSL certificates (auto-renewed)
✅ Global CDN for faster loading
✅ DDoS protection
✅ Analytics and monitoring
✅ Caching for better performance

## Backup Plan
If something goes wrong, you can always revert to Google nameservers:
- ns-cloud-d1.googledomains.com
- ns-cloud-d2.googledomains.com
- ns-cloud-d3.googledomains.com
- ns-cloud-d4.googledomains.com