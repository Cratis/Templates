import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    java
    kotlin("jvm") version "2.4.20"
    kotlin("plugin.spring") version "2.4.20"
    id("com.google.devtools.ksp") version "2.3.12"
    id("io.cratis.arc") version "7.4.1"
    id("org.springframework.boot") version "4.1.1"
    id("io.spring.dependency-management") version "1.1.7"
}

group = "com.example"
version = "0.0.1-SNAPSHOT"

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(17)
    }
}

kotlin {
    compilerOptions {
        jvmTarget = JvmTarget.JVM_17
    }
}

repositories {
    mavenCentral()
}

cratisArc {
    moduleName = "CratisApp"
    dependencyVersion = "7.4.1"
    manageDependencies = true

    endpoints {
        routePrefix = "api"
        segmentsToSkip = 5
    }

    proxies {
        outputDirectory = layout.projectDirectory.dir("build/generated/arc-proxies")
        segmentsToSkip = 5
        removeStaleGeneratedFiles = true
    }
}

dependencies {
    implementation("io.cratis:arc-chronicle-spring-boot-starter:7.4.1")
    implementation("org.springframework.boot:spring-boot-starter-webmvc")
    implementation("org.jetbrains.kotlin:kotlin-reflect")
}

dependencyManagement {
    dependencies {
        // The Spring Boot dependency management pins an older kotlinx-coroutines than
        // the Cratis Kotlin client libraries are compiled against. Keep both the
        // -core artifact and its -jvm variant on the version Arc and Chronicle build with,
        // or the mixed runtime fails at startup with a NoSuchMethodError.
        dependency("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.11.0")
        dependency("org.jetbrains.kotlinx:kotlinx-coroutines-core-jvm:1.11.0")
    }
}
