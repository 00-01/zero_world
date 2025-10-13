# 🔒 HTTPS Certificate - Quick Start

## ⚡ Super Quick Setup (3 Commands)

```bash
# 1. Edit email in script
nano scripts/setup_letsencrypt.sh
# Change: EMAIL="your-email@example.com"

# 2. Run the script
./scripts/setup_letsencrypt.sh

# 3. Test it
curl -I https://zn-01.com
```

## ✅ Prerequisites Checklist

```bash
# Check DNS (MUST point to your server)
dig +short zn-01.com
dig +short www.zn-01.com

# Check your server IP
curl -4 ifconfig.me

# They should match!
```

## 🚀 Two Methods Available

### Method 1: Automatic (Recommended)
```bash
cd /home/z/zero_world
./scripts/setup_letsencrypt.sh
```
**Time**: 5 minutes | **Difficulty**: Easy

### Method 2: Manual
See detailed guide: `docs/HTTPS_SETUP_GUIDE.md`
**Time**: 15 minutes | **Difficulty**: Medium

## 🎯 What You Get

- ✅ FREE SSL certificate (Let's Encrypt)
- ✅ Trusted by all browsers (green padlock 🔒)
- ✅ Auto-renewal every 90 days
- ✅ A+ rating on SSL Labs
- ✅ HTTPS redirect from HTTP
- ✅ Enterprise-grade security

## 🐛 Common Issues

**Issue**: "Domain verification failed"
```bash
# Fix: Check DNS points to your server
dig +short zn-01.com
# Should match: curl -4 ifconfig.me
```

**Issue**: "Port 80 in use"
```bash
# Fix: Stop other web servers
sudo systemctl stop apache2
```

**Issue**: "Certificate not found"
```bash
# Fix: Ensure volumes mounted
docker-compose down
docker-compose up -d
```

## 📞 Need Help?

- **Full Guide**: `docs/HTTPS_SETUP_GUIDE.md`
- **Test SSL**: https://www.ssllabs.com/ssltest/analyze.html?d=zn-01.com
- **Let's Encrypt Docs**: https://letsencrypt.org/docs/

---

**Ready?** Run: `./scripts/setup_letsencrypt.sh` 🚀
