plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.finanzas_moviles"
    
    // Cambia estas líneas dinámicas por valores fijos modernos
    compileSdk = 34 
    // ndkVersion = flutter.ndkVersion // Comenta esta línea si sigue fallando

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17" // Simplificado
    }

    defaultConfig {
        applicationId = "com.example.finanzas_moviles"
        
        minSdk = 21 // Valor estándar para Flutter
        targetSdk = 34 // Coincide con compileSdk
        
        // Estos sí déjalos dinámicos si quieres
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
