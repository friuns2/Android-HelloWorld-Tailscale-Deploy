#!/bin/bash
# Setup script for configuring Tailscale GitHub Secrets
# This script guides you through the setup process

echo "=============================================="
echo "🚀 Tailscale GitHub Secrets Setup Guide"
echo "=============================================="
echo ""

# Check if we're in the right directory
if [ ! -f "settings.gradle" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

# Get repository info
REPO_URL=$(git config --get remote.origin.url)
REPO_NAME=$(basename -s .git "$REPO_URL")
REPO_OWNER=$(dirname "$REPO_URL" | xargs basename)

if [[ "$REPO_URL" == *"github.com"* ]]; then
    # Extract owner and repo from URL
    if [[ "$REPO_URL" == *"github.com:"* ]]; then
        # SSH format: git@github.com:user/repo.git
        REPO_PATH=$(echo "$REPO_URL" | sed 's/.*github.com://g' | sed 's/.git$//g')
    else
        # HTTPS format: https://github.com/user/repo.git
        REPO_PATH=$(echo "$REPO_URL" | sed 's/.*github.com\///g' | sed 's/.git$//g')
    fi
    
    REPO_OWNER=$(echo "$REPO_PATH" | cut -d'/' -f1)
    REPO_NAME=$(echo "$REPO_PATH" | cut -d'/' -f2)
fi

echo "📂 Repository: $REPO_OWNER/$REPO_NAME"
echo ""

echo "=============================================="
echo "📋 Required GitHub Secrets"
echo "=============================================="
echo ""
echo "You need to add 3 secrets to your GitHub repository:"
echo ""
echo "1. TS_OAUTH_CLIENT_ID"
echo "2. TS_OAUTH_SECRET"
echo "3. ANDROID_TAILSCALE_HOST"
echo ""

echo "=============================================="
echo "🔑 Step 1: Create Tailscale OAuth Client"
echo "=============================================="
echo ""
echo "1. Go to: https://login.tailscale.com/admin/settings/oauth"
echo "2. Click 'Generate OAuth Client'"
echo "3. Name: 'GitHub Actions CI' (or similar)"
echo "4. Tags: Add 'tag:ci'"
echo "5. Click 'Generate client'"
echo "6. Copy the Client ID and Client Secret"
echo ""
read -p "Press Enter when you have your OAuth credentials ready..."
echo ""

echo "🔐 Enter your Tailscale OAuth Client ID:"
read -r TS_OAUTH_CLIENT_ID
echo ""

echo "🔐 Enter your Tailscale OAuth Client Secret:"
read -rs TS_OAUTH_SECRET
echo ""
echo ""

echo "=============================================="
echo "📱 Step 2: Get Android Device Tailscale Host"
echo "=============================================="
echo ""
echo "On your Android device:"
echo "1. Open the Tailscale app"
echo "2. Note your device's Tailscale hostname or IP"
echo "   Examples:"
echo "   - Hostname: my-phone.tailnet.ts.net"
echo "   - IP: 100.x.y.z"
echo ""
echo "🔐 Enter your Android device Tailscale hostname or IP:"
read -r ANDROID_TAILSCALE_HOST
echo ""

echo "=============================================="
echo "📝 Summary"
echo "=============================================="
echo ""
echo "Repository: $REPO_OWNER/$REPO_NAME"
echo "TS_OAUTH_CLIENT_ID: ${TS_OAUTH_CLIENT_ID:0:20}..."
echo "TS_OAUTH_SECRET: [hidden]"
echo "ANDROID_TAILSCALE_HOST: $ANDROID_TAILSCALE_HOST"
echo ""

echo "=============================================="
echo "🌐 Add Secrets to GitHub"
echo "=============================================="
echo ""
echo "Now add these secrets to your GitHub repository:"
echo ""
echo "1. Go to: https://github.com/$REPO_OWNER/$REPO_NAME/settings/secrets/actions"
echo "2. Click 'New repository secret'"
echo "3. Add each secret one by one:"
echo ""
echo "   Name: TS_OAUTH_CLIENT_ID"
echo "   Value: $TS_OAUTH_CLIENT_ID"
echo ""
echo "   Name: TS_OAUTH_SECRET"
echo "   Value: [your secret - not shown here for security]"
echo ""
echo "   Name: ANDROID_TAILSCALE_HOST"
echo "   Value: $ANDROID_TAILSCALE_HOST"
echo ""

echo "=============================================="
echo "⚙️ Configure Tailscale ACLs"
echo "=============================================="
echo ""
echo "Add this to your Tailscale ACL policy:"
echo "https://login.tailscale.com/admin/acls"
echo ""
cat << 'EOF'
{
  "tagOwners": {
    "tag:ci": ["autogroup:admin"]
  },
  "acls": [
    {
      "action": "accept",
      "src": ["tag:ci"],
      "dst": ["*:5555"]
    }
  ]
}
EOF
echo ""

echo "=============================================="
echo "📱 Configure Android Device"
echo "=============================================="
echo ""
echo "On your Android device (ONE-TIME SETUP):"
echo ""
echo "1. Enable Developer Options:"
echo "   Settings → About Phone → Tap 'Build Number' 7 times"
echo ""
echo "2. Enable USB Debugging:"
echo "   Settings → System → Developer Options → USB Debugging"
echo ""
echo "3. Connect device via USB to your computer, then run:"
echo "   adb tcpip 5555"
echo ""
echo "4. Verify ADB over TCP is enabled:"
echo "   adb shell netstat -an | grep 5555"
echo ""

echo "=============================================="
echo "✅ Next Steps"
echo "=============================================="
echo ""
echo "1. ✅ Add the 3 secrets to GitHub (link above)"
echo "2. ✅ Update Tailscale ACLs"
echo "3. ✅ Enable ADB over TCP on your device"
echo "4. ✅ Push a commit or manually trigger the workflow"
echo ""
echo "To trigger the workflow manually:"
echo "https://github.com/$REPO_OWNER/$REPO_NAME/actions/workflows/deploy.yml"
echo ""
echo "✨ Setup complete! Good luck! 🚀"
echo ""

