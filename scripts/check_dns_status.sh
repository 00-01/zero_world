#!/bin/bash

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
echo "• http://www.zn-01.com/health"