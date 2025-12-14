# 🔐 GitHub Secrets Configuration - Quick Guide

## ✅ Current Status: APK Build Success!

Your workflow successfully built the APK! Now it needs Tailscale OAuth credentials to deploy.

**APK Location:** `app/build/outputs/apk/debug/app-debug.apk` ✅

---

## 🚨 What You Need to Do Now

### Step 1: Add GitHub Repository Secrets

Go to your repository settings and add these 3 secrets:

**🔗 Direct Link:** https://github.com/friuns2/Android-HelloWorld-Tailscale-Deploy/settings/secrets/actions

Click "**New repository secret**" for each:

#### Secret 1: `TS_OAUTH_CLIENT_ID`
- Get this from: https://login.tailscale.com/admin/settings/oauth
- Click "Generate OAuth Client"
- Name: "GitHub Actions CI"
- Tags: `tag:ci`
- Copy the **Client ID**

#### Secret 2: `TS_OAUTH_SECRET`
- This is the **Client Secret** from the same OAuth client above
- Copy it immediately (you can't view it again later)

#### Secret 3: `ANDROID_TAILSCALE_HOST`
- Open Tailscale app on your Android device
- Copy your device's hostname (e.g., `my-phone.tailnet.ts.net`)
- OR copy your device's IP (e.g., `100.x.y.z`)

---

## 🔧 Step 2: Configure Tailscale ACLs

Go to: https://login.tailscale.com/admin/acls

Add this to your ACL policy (or merge with existing):

```json
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
```

This allows the GitHub Actions runner (tagged with `tag:ci`) to connect to port 5555 on your Android device.

---

## 📱 Step 3: Enable ADB over TCP on Android (One-Time)

### Enable Developer Mode:
1. Go to **Settings** → **About Phone**
2. Tap **Build Number** 7 times
3. You'll see "You are now a developer!"

### Enable USB Debugging:
1. Go to **Settings** → **System** → **Developer Options**
2. Enable **USB Debugging**
3. Enable **Stay Awake** (optional but recommended)

### Enable ADB over TCP:
1. Connect your Android device to your computer via USB
2. Accept the "Allow USB debugging?" prompt on your device
3. Run this command:
   ```bash
   adb tcpip 5555
   ```
4. Verify it's enabled:
   ```bash
   adb shell netstat -an | grep 5555
   ```
5. You can now disconnect the USB cable!

### Test Connection (Optional):
```bash
adb connect <your-device-hostname>.tailnet.ts.net:5555
adb devices
```

---

## 🚀 Step 4: Trigger the Workflow

### Option A: Push a Commit
```bash
git commit --allow-empty -m "Trigger workflow with secrets configured"
git push origin main
```

### Option B: Manual Trigger
Go to: https://github.com/friuns2/Android-HelloWorld-Tailscale-Deploy/actions/workflows/deploy.yml

Click "**Run workflow**" → "**Run workflow**"

---

## 📊 What Will Happen Next

Once secrets are configured, the workflow will:

1. ✅ Build the APK (already working!)
2. ✅ Connect to your Tailscale network using OAuth
3. ✅ Connect to your Android device via ADB over Tailscale
4. ✅ Install the APK on your device
5. ✅ Verify the installation

---

## 🆘 Quick Troubleshooting

### "OAuth identity empty" error
➡️ You haven't added the GitHub secrets yet. Add them in repository settings.

### "adb: failed to connect"
➡️ Check:
- Tailscale is running on your Android device
- ADB over TCP is enabled (`adb tcpip 5555`)
- The hostname/IP in `ANDROID_TAILSCALE_HOST` is correct
- Tailscale ACLs allow `tag:ci` → your device port 5555

### "device unauthorized"
➡️ Accept the "Allow USB debugging" prompt on your device

---

## 🎯 Summary Checklist

Before triggering the workflow, ensure:

- [ ] Created Tailscale OAuth client with `tag:ci`
- [ ] Added `TS_OAUTH_CLIENT_ID` secret to GitHub
- [ ] Added `TS_OAUTH_SECRET` secret to GitHub
- [ ] Added `ANDROID_TAILSCALE_HOST` secret to GitHub
- [ ] Updated Tailscale ACLs to allow `tag:ci` → port 5555
- [ ] Enabled Developer Mode on Android
- [ ] Enabled USB Debugging on Android
- [ ] Enabled ADB over TCP (`adb tcpip 5555`)
- [ ] Tailscale is running on Android device
- [ ] Android device is connected to the same tailnet

---

## 🔗 Helpful Links

- **GitHub Secrets:** https://github.com/friuns2/Android-HelloWorld-Tailscale-Deploy/settings/secrets/actions
- **Tailscale OAuth:** https://login.tailscale.com/admin/settings/oauth
- **Tailscale ACLs:** https://login.tailscale.com/admin/acls
- **GitHub Actions:** https://github.com/friuns2/Android-HelloWorld-Tailscale-Deploy/actions

---

**Need detailed instructions?** See [SETUP.md](SETUP.md)

**Ready to go?** Run `./setup-secrets.sh` for an interactive setup guide!

