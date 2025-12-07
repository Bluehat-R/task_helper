// 🔹 共通リポジトリ設定
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 🔹 ビルドディレクトリ設定（Flutter標準）
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// 🔹 ここから追加！！（Firebase連携に必要）
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Google Services Plugin
        classpath("com.google.gms:google-services:4.3.15")
    }
}

// 🔹 Clean タスク
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
