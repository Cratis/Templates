rootProject.name = "ExtensionName"

// The backend SDK, io.cratis.stage:stage-extensions, is resolved from Maven Central. Until it is published, set
// CRATIS_STAGE_SDK to a clone of https://github.com/Cratis/Stage and the build uses the SDK from there instead.
System.getenv("CRATIS_STAGE_SDK")?.takeIf { it.isNotBlank() }?.let { includeBuild("$it/Source/Extensions/Kotlin") }
