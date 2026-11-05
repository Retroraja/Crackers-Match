plugins { id("com.android.application") }
android {
    namespace = "com.retroraja.crackersmatch"
    compileSdk = 36
    defaultConfig {
        applicationId = "com.retroraja.crackersmatch"
        minSdk = 26
        targetSdk = 36
        versionCode = 100 + (System.getenv("GITHUB_RUN_NUMBER") ?: "1").toInt()
        versionName = "0.1.${System.getenv("GITHUB_RUN_NUMBER") ?: "0"}"
    }
    signingConfigs {
        // Fixed test key, so each new APK installs over the old one and keeps progress. Testing only.
        getByName("debug") {
            storeFile = file("debug.keystore")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
    }
    buildTypes { debug { signingConfig = signingConfigs.getByName("debug") } }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}
