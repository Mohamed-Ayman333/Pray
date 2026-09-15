allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// Ensure all subprojects (including isar_flutter_libs) use compileSdk 35 and have valid namespaces
subprojects {
    afterEvaluate {
        val project = this
        if (project.plugins.hasPlugin("com.android.application") || project.plugins.hasPlugin("com.android.library")) {
            val android = project.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
            android?.apply {
                if (namespace == null) {
                    namespace = project.group.toString().ifEmpty { "com.example.${project.name}" }
                }
                compileSdkVersion(35)
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}