# Quick Reference Guide

## Essential Files Checklist

Before pushing to GitHub, ensure these files exist:

### ✅ Gradle Wrapper (Required for CI/CD)
- [ ] `gradlew` (executable Unix script)
- [ ] `gradlew.bat` (Windows batch file)
- [ ] `gradle/wrapper/gradle-wrapper.jar` (Gradle wrapper JAR)
- [ ] `gradle/wrapper/gradle-wrapper.properties` (wrapper config)

### ✅ Build Configuration
- [ ] `build.gradle` (project-level)
- [ ] `app/build.gradle` (module-level)
- [ ] `settings.gradle`
- [ ] `gradle.properties`

### ✅ Source Code
- [ ] `app/src/main/AndroidManifest.xml`
- [ ] `app/src/main/java/com/example/helloworld/MainActivity.java`
- [ ] `app/src/main/res/layout/activity_main.xml`
- [ ] `app/src/main/res/values/strings.xml`
- [ ] `app/src/main/res/values/themes.xml`
- [ ] `app/src/main/res/values/colors.xml`

### ✅ CI/CD
- [ ] `.github/workflows/deploy.yml`

### ✅ GitHub Secrets (in repository settings)
- [ ] `TS_OAUTH_CLIENT_ID`
- [ ] `TS_OAUTH_SECRET`
- [ ] `ANDROID_TAILSCALE_HOST`

---

## Common Commands

### Local Development
```bash
# Make gradlew executable (Unix/Mac)
chmod +x ./gradlew

# Build debug APK
./gradlew assembleDebug

# Build release APK
./gradlew assembleRelease

# Clean build
./gradlew clean

# Run tests
./gradlew test

# Install on connected device
./gradlew installDebug
```

### ADB Commands
```bash
# Enable ADB over TCP (requires USB connection once)
adb tcpip 5555

# Connect via Tailscale
adb connect <hostname>.tailnet.ts.net:5555

# List connected devices
adb devices

# Install APK
adb install -r app/build/outputs/apk/debug/app-debug.apk

# Launch the app
adb shell am start -n com.example.helloworld/.MainActivity

# View logs
adb logcat | grep HelloWorld

# Uninstall app
adb uninstall com.example.helloworld

# Disconnect
adb disconnect
```

### Git Commands
```bash
# Initialize repository (if not done)
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit: Hello World Android app"

# Add remote
git remote add origin <your-repo-url>

# Push to main
git push -u origin main

# Check status
git status
```

---

## Troubleshooting Quick Fixes

### Error: "chmod: cannot access './gradlew': No such file or directory"
**Fix:** Ensure `gradlew`, `gradlew.bat`, and `gradle/wrapper/` files exist in the repository root.

### Error: "Could not find or load main class org.gradle.wrapper.GradleWrapperMain"
**Fix:** Ensure `gradle/wrapper/gradle-wrapper.jar` exists and is committed to the repository.

### Error: "SDK location not found"
**Fix (Local):** Create `local.properties` with:
```properties
sdk.dir=/path/to/Android/sdk
```
**Fix (CI):** The workflow automatically sets `ANDROID_HOME` and `ANDROID_SDK_ROOT`.

### Error: "adb: device unauthorized"
**Fix:** Accept the "Allow USB debugging" prompt on your device, then reconnect.

### Error: "adb: failed to connect"
**Fix:** Verify:
- Tailscale is running on the device
- ADB over TCP is enabled: `adb tcpip 5555`
- Hostname/IP is correct in `ANDROID_TAILSCALE_HOST` secret
- Tailscale ACLs allow `tag:ci` → device port 5555

### Error: "Execution failed for task ':app:processDebugResources'"
**Fix:** Ensure all resource files exist:
- `res/values/strings.xml`
- `res/values/themes.xml`
- `res/values/colors.xml`
- `res/layout/activity_main.xml`

---

## File Locations

### Built APK Location
```
app/build/outputs/apk/debug/app-debug.apk
```

### Logs Location (CI)
GitHub Actions → Actions tab → Select workflow run → Expand steps

### Android Device Logs
```bash
adb logcat
# or filtered:
adb logcat | grep -i "com.example.helloworld"
```

---

## Quick Test Flow

### 1. Local Build Test
```bash
chmod +x ./gradlew
./gradlew clean assembleDebug
```

### 2. Local Device Test
```bash
# Connect device via USB
adb devices
./gradlew installDebug
adb shell am start -n com.example.helloworld/.MainActivity
```

### 3. Tailscale Device Test
```bash
# Enable ADB over TCP (USB connected)
adb tcpip 5555

# Disconnect USB, connect via Tailscale
adb connect <device-hostname>.tailnet.ts.net:5555
adb devices
adb install -r app/build/outputs/apk/debug/app-debug.apk
```

### 4. CI/CD Test
```bash
git add .
git commit -m "Test CI/CD"
git push origin main
# Watch GitHub Actions tab
```

---

## Version Information

- **Gradle:** 8.2
- **Android Gradle Plugin:** 8.2.0
- **Compile SDK:** 34 (Android 14)
- **Target SDK:** 34
- **Min SDK:** 21 (Android 5.0 Lollipop)
- **Java Version:** 1.8 (source/target)
- **Build JDK:** 17 (CI/CD)

---

## Useful Links

- [Android Studio Download](https://developer.android.com/studio)
- [Tailscale Console](https://login.tailscale.com/admin)
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [ADB Documentation](https://developer.android.com/tools/adb)
- [Gradle Wrapper Guide](https://docs.gradle.org/current/userguide/gradle_wrapper.html)

---

## Next Steps After Setup

1. ✅ Verify all files are present (see checklist above)
2. ✅ Test local build: `./gradlew assembleDebug`
3. ✅ Set up Tailscale (see SETUP.md)
4. ✅ Configure GitHub secrets
5. ✅ Push to GitHub: `git push origin main`
6. ✅ Monitor first deployment in Actions tab
7. ✅ Verify app installs on device

---

**Need detailed setup instructions?** See [SETUP.md](SETUP.md)

**Need project overview?** See [README.md](README.md)

