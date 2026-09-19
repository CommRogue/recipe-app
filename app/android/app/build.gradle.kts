plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "app.panwise"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Bundle id from ADR 0003. The dev flavor appends ".dev".
        applicationId = "app.panwise"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Flavors mirror the two GCP projects. Firebase is configured from Dart
    // (lib/firebase_options_<flavor>.dart), so no google-services Gradle plugin
    // is applied; android/app/src/dev/google-services.json is kept as the
    // record of the dev project's client config.
    buildFeatures {
        resValues = true // AGP 9 turns resValue off by default
    }

    flavorDimensions += "environment"
    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "Panwise Dev")
        }
        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "Panwise")
        }
    }

    buildTypes {
        release {
            // TODO(#23): release signing is configured by the store pipeline.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
