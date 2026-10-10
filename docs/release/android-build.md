# Android debug build

The Android preset exports a debug-signed APK from the official Godot 4.7.2
prebuilt template. It includes ARM64 and x86_64 libraries, requests Internet
permission for ENet LAN play, and uses the project's ETC2/ASTC texture imports.

This environment has a workspace-local OpenJDK 17.0.20, Google Android platform
35, build-tools 35.0.1, command-line tools 23 and platform-tools 37.0.1. JDK
packages were verified against signed Ubuntu repository SHA-256 metadata;
Google archives were verified against the official SDK repository checksums.
The template declares minimum API 24 and target API 36; Godot successfully uses
the installed build-tools 35.0.1 to package and sign it.

```bash
bash tools/build/android.sh
python tools/qa/verify_android.py \
  --apk builds/android/WackyTowers-debug.apk \
  --sdk ../tools/android/sdk \
  --java ../tools/android/jdk17/usr/lib/jvm/java-17-openjdk-amd64 \
  --output production/qa/evidence/build-2026-10-10
```

For another machine, configure the Java and Android SDK paths in Godot's editor
settings and set `WT_ANDROID_HOME`, `JAVA_HOME`, `ANDROID_HOME`, and `GODOT_BIN`
as needed. The debug key is held outside the repository; the script uses the
standard `androiddebugkey` alias and `android` debug password. A release key,
Gradle/AAB export and store publication are separate release tasks.

Retained checks verify the real APK's v2/v3 signature, 16 KiB native-library
alignment, manifest identity, API levels, architectures and Internet permission.
No Android emulator/device execution or phone performance measurement is
claimed. This sandbox has no `/dev/kvm`, and adb's normal daemon launch cannot
resolve its executable path through the restricted `/proc` surface.

References: [Godot 4.7 Android export](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_android.html),
[Android SDK command-line tools](https://developer.android.com/tools),
[Google's SDK repository](https://dl.google.com/android/repository/repository2-3.xml).
