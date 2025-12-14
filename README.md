# Android Hello World App

A basic Android application that displays "Hello World!" on the screen.

## Project Details

- **Application Name**: HelloWorld
- **Package Name**: com.example.helloworld
- **Language**: Java
- **Minimum SDK**: API 21 (Android 5.0 Lollipop)
- **Target SDK**: API 34

## Features

- Displays "Hello World!" in a TextView centered on the screen
- Built using Android Studio's Empty Activity template

## Building the Project

### Prerequisites

- Android Studio (latest version recommended)
- JDK 17 or higher
- Android SDK with API 21+

### Build Instructions

1. Clone this repository
2. Open the project in Android Studio
3. Let Gradle sync the project
4. Build and run the app on an emulator or device

Alternatively, build from command line:

```bash
chmod +x ./gradlew
./gradlew assembleDebug
```

The APK will be generated at: `app/build/outputs/apk/debug/app-debug.apk`

## GitHub Actions CI/CD

This project includes a GitHub Actions workflow that automatically builds and deploys the app to an Android device over Tailscale.

### Workflow Features

- Builds the debug APK on push to `main` branch
- Connects to Tailscale tailnet using OAuth credentials
- Deploys the APK to an Android device over the network using ADB

### Prerequisites for CI/CD

1. **Tailscale Setup**:
   - The Android device must have Tailscale running and connected to your tailnet
   - Create a Tailscale OAuth client with appropriate permissions
   - Configure tailnet ACLs to allow traffic from `tag:ci` to the device's port 5555

2. **Android Device Setup**:
   - Enable ADB over TCP on the device by running: `adb tcpip 5555`
   - This setting typically persists across reboots

3. **GitHub Repository Secrets**:
   Add the following secrets to your GitHub repository (Settings → Secrets and variables → Actions):
   - `TS_OAUTH_CLIENT_ID`: Your Tailscale OAuth client ID
   - `TS_OAUTH_SECRET`: Your Tailscale OAuth client secret
   - `ANDROID_TAILSCALE_HOST`: The Tailscale IP or MagicDNS hostname of your Android device (e.g., `my-phone.tailnet.ts.net` or `100.x.y.z`)

### Manual Workflow Trigger

The workflow can also be triggered manually via the Actions tab in GitHub using the "workflow_dispatch" event.

## Project Structure

```
HelloWorld/
├── .github/
│   └── workflows/
│       └── deploy.yml           # GitHub Actions workflow
├── app/
│   ├── build.gradle             # Module-level build configuration
│   ├── proguard-rules.pro       # ProGuard rules
│   └── src/
│       └── main/
│           ├── AndroidManifest.xml
│           ├── java/
│           │   └── com/example/helloworld/
│           │       └── MainActivity.java
│           └── res/
│               ├── layout/
│               │   └── activity_main.xml
│               ├── values/
│               │   ├── colors.xml
│               │   ├── strings.xml
│               │   └── themes.xml
│               └── xml/
│                   ├── backup_rules.xml
│                   └── data_extraction_rules.xml
├── build.gradle                 # Project-level build configuration
├── gradle.properties            # Gradle properties
├── settings.gradle              # Project settings
└── .gitignore
```

## License

This is a basic example project for educational purposes.

