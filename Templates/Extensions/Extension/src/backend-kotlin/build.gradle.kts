import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    kotlin("jvm") version "2.4.20"
    id("com.gradleup.shadow") version "9.3.1"
    application
}

group = "PUBLISHER"
version = "1.0.0"

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

dependencies {
    // The backend SDK: the extension protocol, the handshake against contract.play and the host services.
    implementation("io.cratis.stage:stage-extensions:1.0.0")
    implementation("com.google.code.gson:gson:2.13.2")

    testImplementation(kotlin("test"))
}

application {
    mainClass.set("extension.MainKt")
}

tasks.test {
    useJUnitPlatform()
}

// The backend as the package ships it: one jar with everything it needs, in the folder contract.play names.
tasks.shadowJar {
    archiveBaseName.set("ExtensionName")
    archiveClassifier.set("")
    archiveVersion.set("")
    destinationDirectory.set(layout.projectDirectory.dir("../../backend"))
    mergeServiceFiles()
}

tasks.build {
    dependsOn(tasks.shadowJar)
}
