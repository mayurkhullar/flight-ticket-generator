plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // must be after android/kotlin
    id("com.google.gms.google-services") // Firebase services
}

android {
    namespace = "com.kholidaymaps.flight_tickets"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.kholidaymaps.flight_tickets"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // Temporary
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase BOM (manages compatible versions)
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))

    // Firebase SDKs
    implementation("com.google.firebase:firebase-analytics-ktx")
    implementation("com.google.firebase:firebase-firestore-ktx")
    implementation("com.google.firebase:firebase-storage-ktx")
}

