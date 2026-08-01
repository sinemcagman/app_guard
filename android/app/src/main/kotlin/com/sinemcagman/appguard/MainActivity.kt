package com.sinemcagman.appguard

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.text.Collator
import java.util.Locale

class MainActivity : FlutterFragmentActivity() {
    private val channelName = "app_guard/platform"
    private var channel: MethodChannel? = null
    private var pinnedSessionRequested = false
    private var pinnedSessionStarted = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).also {
            it.setMethodCallHandler { call, result ->
                when (call.method) {
                    "getLaunchableApps" -> result.success(getLaunchableApps())
                    "startPinnedMode" -> startPinnedMode(result)
                    "stopPinnedMode" -> stopPinnedMode(result)
                    "launchApp" -> launchApp(call.argument<String>("packageName"), result)
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onResume() {
        super.onResume()
        val lockTaskState = currentLockTaskState()
        if (pinnedSessionRequested && lockTaskState != ActivityManager.LOCK_TASK_MODE_NONE) {
            pinnedSessionRequested = false
            pinnedSessionStarted = true
        } else if (pinnedSessionStarted && lockTaskState == ActivityManager.LOCK_TASK_MODE_NONE) {
            pinnedSessionStarted = false
            channel?.invokeMethod("unauthorizedExitDetected", null)
        }
    }

    private fun getLaunchableApps(): List<Map<String, String>> {
        val launcherIntent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        val activities = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.queryIntentActivities(
                launcherIntent,
                PackageManager.ResolveInfoFlags.of(PackageManager.MATCH_ALL.toLong())
            )
        } else {
            @Suppress("DEPRECATION")
            packageManager.queryIntentActivities(launcherIntent, PackageManager.MATCH_ALL)
        }
        val collator = Collator.getInstance(Locale("tr", "TR"))
        return activities
            .asSequence()
            .filter { it.activityInfo.packageName != packageName }
            .distinctBy { it.activityInfo.packageName }
            .map { info ->
                val appPackage = info.activityInfo.packageName
                mapOf(
                    "name" to info.loadLabel(packageManager).toString(),
                    "packageName" to appPackage,
                    "category" to categoryFor(appPackage)
                )
            }
            .sortedWith { first, second -> collator.compare(first["name"], second["name"]) }
            .toList()
    }

    private fun categoryFor(packageName: String): String {
        val normalized = packageName.lowercase(Locale.ROOT)
        return when {
            listOf("whatsapp", "telegram", "facebook", "instagram", "twitter", "discord", "messenger")
                .any(normalized::contains) -> "social"
            listOf("youtube", "spotify", "music", "photo", "gallery", "camera", "video")
                .any(normalized::contains) -> "media"
            listOf("settings", "systemui", "dialer", "contacts", "launcher")
                .any(normalized::contains) -> "system"
            listOf("calculator", "clock", "calendar", "files", "drive", "maps", "notes")
                .any(normalized::contains) -> "utility"
            else -> "other"
        }
    }

    private fun startPinnedMode(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            result.error("PINNING_NOT_PERMITTED", null, null)
            return
        }
        try {
            startLockTask()
            pinnedSessionStarted = currentLockTaskState() != ActivityManager.LOCK_TASK_MODE_NONE
            pinnedSessionRequested = !pinnedSessionStarted
            result.success(if (pinnedSessionStarted) "LOCK_TASK_STARTED" else "LOCK_TASK_REQUESTED")
        } catch (_: SecurityException) {
            result.error("PINNING_NOT_PERMITTED", null, null)
        } catch (_: IllegalArgumentException) {
            result.error("LOCK_TASK_FAILED", null, null)
        }
    }

    private fun stopPinnedMode(result: MethodChannel.Result) {
        try {
            if (currentLockTaskState() != ActivityManager.LOCK_TASK_MODE_NONE) stopLockTask()
            pinnedSessionRequested = false
            pinnedSessionStarted = false
            result.success(null)
        } catch (_: SecurityException) {
            result.error("PINNING_NOT_PERMITTED", null, null)
        }
    }

    private fun launchApp(targetPackage: String?, result: MethodChannel.Result) {
        if (targetPackage.isNullOrBlank()) {
            result.error("APP_NOT_FOUND", null, null)
            return
        }
        if (currentLockTaskState() == ActivityManager.LOCK_TASK_MODE_NONE) {
            result.error("PINNING_NOT_PERMITTED", null, null)
            return
        }
        pinnedSessionRequested = false
        pinnedSessionStarted = true
        val intent = packageManager.getLaunchIntentForPackage(targetPackage)
        if (intent == null) {
            result.error("APP_NOT_FOUND", null, null)
            return
        }
        try {
            intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            startActivity(intent)
            result.success(null)
        } catch (_: SecurityException) {
            result.error("PINNING_NOT_PERMITTED", null, null)
        } catch (_: Exception) {
            result.error("APP_NOT_FOUND", null, null)
        }
    }

    private fun currentLockTaskState(): Int {
        val manager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            manager.lockTaskModeState
        } else {
            @Suppress("DEPRECATION")
            if (manager.isInLockTaskMode) ActivityManager.LOCK_TASK_MODE_PINNED
            else ActivityManager.LOCK_TASK_MODE_NONE
        }
    }
}
