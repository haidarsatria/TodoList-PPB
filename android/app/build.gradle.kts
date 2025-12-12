plugins {
    id("com.android.application")
    id("kotlin-android")
    ^\s*//.*$ The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.rest_api_demo"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        ^\s*//.*$ TODO: Specify your own unique Application ID (https:^\s*//.*$developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.rest_api_demo"
        ^\s*//.*$ You can update the following values to match your application needs.
        ^\s*//.*$ For more information, see: https:^\s*//.*$flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            ^\s*//.*$ TODO: Add your own signing config for the release build.
            ^\s*//.*$ Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
