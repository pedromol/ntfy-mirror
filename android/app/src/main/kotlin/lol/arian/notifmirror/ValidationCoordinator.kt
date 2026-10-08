package br.mol.net.br

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import androidx.core.app.NotificationCompat
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

/**
 * Coordinates the round-trip validation ("send a message, expect to receive it back").
 *
 * The app posts a local test notification carrying a unique token; the
 * [MsgNotificationListener] is expected to capture it (bypassing the allowed-packages
 * and self-app filters) and report the echo back to whichever Flutter engine is
 * running the validation.
 *
 * A single pending token is kept per device; starting a new validation replaces it.
 */
object ValidationCoordinator {
    const val CHANNEL_ID = "ntfy_mirror_test"
    private const val NOTIFICATION_ID = 424242

    @Volatile
    private var pendingToken: String? = null

    /** Currently pending validation token, if any. */
    val pending: String?
        get() = pendingToken

    /** True when [text] carries the currently pending validation token. */
    fun matchesPendingEcho(text: String): Boolean {
        val t = pendingToken ?: return false
        return t.isNotEmpty() && text.contains(t)
    }

    /**
     * If [text] carries the pending token, reports the echo back and disarms.
     * Called by [MsgNotificationListener] when the test notification comes back.
     */
    fun maybeDeliverEcho(context: Context, text: String) {
        val t = pendingToken ?: return
        if (t.isNotEmpty() && text.contains(t)) {
            deliverEcho(context, t)
        }
    }

    fun arm(token: String) {
        pendingToken = token
    }

    fun disarm() {
        pendingToken = null
    }

    fun postTestNotification(context: Context, token: String) {
        val mgr = context.getSystemService(NotificationManager::class.java)
        if (Build.VERSION.SDK_INT >= 26) {
            val chan = NotificationChannel(
                CHANNEL_ID,
                "Ntfy Mirror Test",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            mgr.createNotificationChannel(chan)
        }
        val notification: Notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Ntfy Mirror validation")
            .setContentText(token)
            .setStyle(NotificationCompat.BigTextStyle().bigText("Ntfy Mirror validation test — $token"))
            .setAutoCancel(true)
            .build()
        arm(token)
        try {
            mgr.notify(NOTIFICATION_ID, notification)
        } catch (e: Exception) {
            disarm()
            try { LogStore.append(context, "postTestNotification failed: ${e.message ?: e.javaClass.simpleName}") } catch (_: Exception) {}
            throw e
        }
    }

    fun cancelTestNotification(context: Context) {
        disarm()
        try {
            context.getSystemService(NotificationManager::class.java).cancel(NOTIFICATION_ID)
        } catch (_: Exception) {}
    }

    /**
     * Tells the Dart isolate that is waiting for the echo that the test message came back.
     * Uses the UI engine first, falling back to the background engine.
     */
    fun deliverEcho(context: Context, token: String) {
        if (pendingToken != token) return
        disarm()
        var ch: MethodChannel? = null
        try {
            val ui = FlutterEngineCache.getInstance().get("ui_engine")
            if (ui != null) {
                ch = MethodChannel(ui.dartExecutor.binaryMessenger, "msg_mirror_result")
            }
        } catch (_: Exception) {}
        if (ch == null) {
            try {
                val bg = FlutterEngineCache.getInstance().get("always_on_engine")
                if (bg != null) {
                    ch = MethodChannel(bg.dartExecutor.binaryMessenger, "msg_mirror_result")
                }
            } catch (_: Exception) {}
        }
        try {
            ch?.invokeMethod("onValidationEcho", token)
            try { LogStore.append(context, "Validation echo delivered (token=$token)") } catch (_: Exception) {}
        } catch (e: Exception) {
            try { LogStore.append(context, "Validation echo delivery failed: ${e.message ?: e.javaClass.simpleName}") } catch (_: Exception) {}
        }
    }
}