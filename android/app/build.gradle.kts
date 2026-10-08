import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
    }
}

android {

    namespace = "br.mol.net.br"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    // Removed deprecated kotlinOptions block


    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "br.mol.net.br"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    val keystorePropertiesFile = rootProject.file("key.properties")
    val keystoreProperties = Properties()
    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    }

    signingConfigs {
        if (keystorePropertiesFile.exists() && keystoreProperties["storeFile"] != null) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            val releaseSigning = signingConfigs.findByName("release")
            if (releaseSigning != null) {
                signingConfig = releaseSigning
            } else {
                val ksf = keystorePropertiesFile
                tasks.matching { it.name.startsWith("assemble") && it.name.endsWith("Release") }.configureEach {
                    doFirst {
                        throw GradleException(
                            "Release signing not configured: missing $ksf.\n" +
                                "Create a keystore (keytool -genkeypair ...) and write android/key.properties, " +
                                "or provide KEYSTORE_* secrets in CI."
                        )
                    }
                }
            }
        }
    }
    applicationVariants.configureEach {
        val appName = "NotifMirror"

        // Use mergedFlavor for compatibility across AGP versions
        val vName = mergedFlavor.versionName ?: defaultConfig.versionName
        val vCode = mergedFlavor.versionCode ?: defaultConfig.versionCode

        outputs.configureEach {
            val output = this as com.android.build.gradle.internal.api.BaseVariantOutputImpl
            // ABI filter: arm64-v8a, armeabi-v7a, etc.
            val abiFilter = output.getFilter(com.android.build.OutputFile.ABI) ?: "universal"

            // In Kotlin DSL, assign directly via the internal API
            output.outputFileName = "${appName}-v${vName}(${vCode})-${abiFilter}.apk"
        }
    }

    testOptions {
        unitTests.apply {
            isIncludeAndroidResources = true
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    testImplementation("junit:junit:4.13.2")
    testImplementation("org.robolectric:robolectric:4.13")
    testImplementation("androidx.test:core:1.5.0")
}
