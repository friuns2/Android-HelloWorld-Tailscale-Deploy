# Setup Guide for Android Deployment via Tailscale

This guide will help you set up the complete CI/CD pipeline to automatically deploy your Android app to a device over Tailscale.

## Table of Contents
1. [Tailscale Setup](#tailscale-setup)
2. [Android Device Setup](#android-device-setup)
3. [GitHub Repository Configuration](#github-repository-configuration)
4. [Testing the Setup](#testing-the-setup)
5. [Troubleshooting](#troubleshooting)

---

## Tailscale Setup

### Step 1: Create a Tailscale Account
1. Go to [https://tailscale.com](https://tailscale.com) and sign up for a free account
2. Download and install Tailscale on your Android device from the Play Store
3. Sign in to Tailscale on your Android device

### Step 2: Create an OAuth Client
1. Go to [https://login.tailscale.com/admin/settings/oauth](https://login.tailscale.com/admin/settings/oauth)
2. Click **Generate OAuth Client**
3. Give it a descriptive name like "GitHub Actions CI"
4. Under **Tags**, add `tag:ci`
5. Click **Generate client**
6. **Save the Client ID and Client Secret** - you'll need these for GitHub secrets

### Step 3: Configure ACLs
1. Go to [https://login.tailscale.com/admin/acls](https://login.tailscale.com/admin/acls)
2. Add the following to your ACL policy to allow CI access to your device:

```json
{
  "tagOwners": {
    "tag:ci": ["autogroup:admin"]
  },
  "acls": [
    // Allow CI tag to connect to all devices on port 5555 (ADB)
    {
      "action": "accept",
      "src": ["tag:ci"],
      "dst": ["*:5555"]
    },
    // Your other ACL rules here...
  ]
}
```

3. Click **Save**

### Step 4: Get Your Device's Tailscale Hostname/IP
1. On your Android device, open the Tailscale app
2. Note your device's:
   - **MagicDNS hostname** (e.g., `my-phone.tailnet.ts.net`) - recommended
   - Or **Tailscale IP** (e.g., `100.x.y.z`)
3. You'll need this for GitHub secrets

---

## Android Device Setup

### Step 1: Enable Developer Options
1. Go to **Settings** → **About phone**
2. Tap **Build number** 7 times until you see "You are now a developer!"

### Step 2: Enable USB Debugging
1. Go to **Settings** → **System** → **Developer options**
2. Enable **USB debugging**
3. Enable **Stay awake** (optional, but recommended to keep device active during deployments)

### Step 3: Connect Device via USB (One-Time Setup)
1. Connect your Android device to your computer via USB
2. Accept the "Allow USB debugging" prompt on your device
3. Run the following command to enable ADB over TCP:
   ```bash
   adb tcpip 5555
   ```
4. Verify the device is listening:
   ```bash
   adb shell netstat -an | grep 5555
   ```
5. You can now disconnect the USB cable - ADB over TCP will persist across reboots on most devices

### Step 4: Test ADB Connection Over Tailscale (Optional)
1. Make sure both your computer and Android device are connected to Tailscale
2. Try connecting via ADB:
   ```bash
   adb connect <your-device-hostname>.tailnet.ts.net:5555
   # or
   adb connect 100.x.y.z:5555
   ```
3. List connected devices:
   ```bash
   adb devices
   ```
4. You should see your device listed

---

## GitHub Repository Configuration

### Step 1: Add Repository Secrets
1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret** and add the following secrets:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `TS_OAUTH_CLIENT_ID` | Your Tailscale OAuth Client ID | From Tailscale OAuth setup |
| `TS_OAUTH_SECRET` | Your Tailscale OAuth Client Secret | From Tailscale OAuth setup |
| `ANDROID_TAILSCALE_HOST` | `my-phone.tailnet.ts.net` or `100.x.y.z` | Your device's Tailscale hostname or IP |

### Step 2: Verify Workflow File
Ensure `.github/workflows/deploy.yml` exists in your repository with the correct configuration.

---

## Testing the Setup

### Method 1: Manual Workflow Trigger
1. Go to your GitHub repository
2. Navigate to **Actions** tab
3. Select **Build and Deploy Android App to Device via Tailscale**
4. Click **Run workflow** → **Run workflow**
5. Monitor the workflow execution

### Method 2: Push to Main Branch
1. Make a small change to your code
2. Commit and push to the `main` branch:
   ```bash
   git add .
   git commit -m "Test deployment"
   git push origin main
   ```
3. Go to the **Actions** tab to watch the deployment

### Expected Workflow Steps
1. ✅ Checkout code
2. ✅ Set up JDK 17
3. ✅ Set up Android SDK
4. ✅ Build debug APK
5. ✅ Connect to Tailscale
6. ✅ Verify connection (may fail if ping is disabled - that's OK)
7. ✅ Install ADB tools
8. ✅ Connect to Android device via ADB
9. ✅ Install APK on device
10. ✅ Verify installation

---

## Troubleshooting

### Issue: "adb: failed to connect to <host>:5555"
**Solutions:**
- Verify Tailscale is running on your Android device
- Check that ADB over TCP is enabled: `adb tcpip 5555` (needs USB connection once)
- Verify the hostname/IP in your `ANDROID_TAILSCALE_HOST` secret is correct
- Check Tailscale ACLs allow `tag:ci` to access port 5555

### Issue: "unauthorized" when connecting via ADB
**Solutions:**
- On your device, accept the "Allow USB debugging" prompt
- If you don't see the prompt, try: `adb kill-server && adb start-server`
- Then reconnect: `adb connect <host>:5555`

### Issue: Workflow fails at "Connect to Tailscale"
**Solutions:**
- Verify `TS_OAUTH_CLIENT_ID` and `TS_OAUTH_SECRET` are correct
- Check that the OAuth client has the `tag:ci` tag
- Ensure the OAuth client hasn't been revoked or expired

### Issue: "adb: error: connect failed: closed"
**Solutions:**
- Device may have gone to sleep - enable "Stay awake" in Developer options
- ADB over TCP may have reset - reconnect USB and run `adb tcpip 5555` again
- Restart the ADB server on the device: `adb shell setprop service.adb.tcp.port 5555; adb shell stop adbd; adb shell start adbd`

### Issue: APK installs but app crashes
**Solutions:**
- Check logcat: `adb logcat | grep com.example.helloworld`
- Verify minimum SDK version matches your device's Android version
- Build a release version with proper signing if needed

### Issue: Ping fails in workflow (with continue-on-error)
**Note:** This is expected on some networks where ICMP is disabled. The workflow continues anyway since it's marked with `continue-on-error: true`. The ADB connection doesn't require ping to work.

---

## Advanced Configuration

### Launch the App Automatically
Uncomment lines 98-102 in `.github/workflows/deploy.yml` to automatically launch the app after installation:

```yaml
- name: Launch the app
  run: |
    echo "Launching HelloWorld app..."
    adb shell am start -n com.example.helloworld/.MainActivity
```

### Deploy to Multiple Devices
You can extend the workflow to deploy to multiple devices by using a matrix strategy:

```yaml
strategy:
  matrix:
    device: [device1, device2]
steps:
  - name: Connect to Android device via ADB
    run: adb connect ${{ secrets[format('ANDROID_TAILSCALE_HOST_{0}', matrix.device)] }}:5555
```

Then add secrets like `ANDROID_TAILSCALE_HOST_DEVICE1`, `ANDROID_TAILSCALE_HOST_DEVICE2`, etc.

### Run UI Tests
Add Espresso UI tests and run them remotely:

```yaml
- name: Run UI Tests
  run: ./gradlew connectedAndroidTest
```

---

## Security Notes

- 🔒 OAuth credentials are stored as GitHub repository secrets (encrypted)
- 🔒 Only workflows from your repository can access these secrets
- 🔒 The `tag:ci` tag limits what the CI can access on your tailnet
- 🔒 Consider using a dedicated device for CI/CD testing
- 🔒 Regularly rotate OAuth credentials and review ACL policies

---

## Need Help?

- **Tailscale Documentation**: [https://tailscale.com/kb](https://tailscale.com/kb)
- **ADB Documentation**: [https://developer.android.com/tools/adb](https://developer.android.com/tools/adb)
- **GitHub Actions Documentation**: [https://docs.github.com/en/actions](https://docs.github.com/en/actions)

---

**Happy Deploying! 🚀**

