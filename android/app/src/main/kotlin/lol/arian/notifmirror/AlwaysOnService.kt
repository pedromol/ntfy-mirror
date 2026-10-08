package br.mol.net.br

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import android.Manifest
import android.content.pm.PackageManager
import android.provider.Telephony
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

class AlwaysOnService : Service() {
    companion object {
        // Testing flag to avoid loading Flutter native engine in unit tests
        @JvmStatic var testSkipEngine: Boolean = false
    }

    private var engine: FlutterEngine? = null
    private var smsObserver: SmsObserver? = null
    private var msgChannel: MethodChannel? = null

    override fun onCreate() {
        super.onCreate()
        LogStore.append(this, "AlwaysOnService onCreate")
        val started = startAsForeground()
        if (!started) {
            // Foreground start failed; abort further initialization
            return
        }
        if (testSkipEngine) {
            LogStore.append(this, "AlwaysOnService skipping engine init (test)")
        } else {
            initFlutterEngine()
        }
        try {
            val prefs = getSharedPreferences("ntfy_mirror", MODE_PRIVATE)
            prefs.edit().putBoolean("service_running", true).apply()
        } catch (_: Exception) {}
    }

    private fun startAsForeground(): Boolean {
        val channelId = "ntfy_mirror"
        val mgr = getSystemService(NotificationManager::class.java)
        if (Build.VERSION.SDK_INT >= 26) {
            val chan = NotificationChannel(channelId, "Ntfy Mirror", NotificationManager.IMPORTANCE_MIN)
            mgr.createNotificationChannel(chan)
        }
        val notif: Notification = NotificationCompat.Builder(this, channelId)
            .setOngoing(true)
            .setContentTitle("Ntfy Mirror running")
            .setSmallIcon(android.R.drawable.stat_notify_sync)
            .build()
        return try {
            startForeground(1, notif)
            LogStore.append(this, "AlwaysOnService startForeground")
            true
        } catch (e: Exception) {
            try {
                LogStore.append(this, "Failed to start foreground service: ${e.message ?: e.javaClass.simpleName}. If this persists, ensure required permissions are granted and app is up to date.")
                val prefs = getSharedPreferences("ntfy_mirror", MODE_PRIVATE)
                prefs.edit().putBoolean("service_running", false).apply()
            } catch (_: Exception) {}
            stopSelf()
            false
        }
    }

    private fun initFlutterEngine() {
        val loader = FlutterInjector.instance().flutterLoader()
        try {
            loader.startInitialization(this)
            loader.ensureInitializationComplete(this, null)
        } catch (_: Exception) {}
        val appBundlePath = loader.findAppBundlePath()
        val dartEntrypoint = DartExecutor.DartEntrypoint(appBundlePath, "backgroundMain")
        engine = FlutterEngine(this)

        // Set up channels BEFORE running Dart, so early Dart logs/reads work
        val messenger = engine!!.dartExecutor.binaryMessenger

        // Logs channel for background engine
        MethodChannel(messenger, "msg_mirror_logs").setMethodCallHandler { call, result ->
            when (call.method) {
                "append" -> { LogStore.append(this, (call.arguments as? String) ?: ""); result.success(null) }
                "read" -> result.success(LogStore.read(this))
                "clear" -> { LogStore.clear(this); result.success(null) }
                else -> result.notImplemented()
            }
        }

        // Prefs channel
        val prefs = getSharedPreferences("ntfy_mirror", MODE_PRIVATE)
        MethodChannel(messenger, "msg_mirror_prefs").setMethodCallHandler { call, result ->
            when (call.method) {
                "getReception" -> result.success(prefs.getString("reception", ""))
                "setReception" -> {
                    val v = call.arguments as? String ?: ""
                    prefs.edit().putString("reception", v).apply()
                    result.success(null)
                }
                "getEndpoint" -> result.success(prefs.getString("endpoint", ""))
                "setEndpoint" -> {
                    val v = call.arguments as? String ?: ""
                    prefs.edit().putString("endpoint", v).apply()
                    result.success(null)
                }
                "getAuth" -> {
                    val enc = prefs.getString("auth_enc", null)
                    if (enc.isNullOrEmpty()) {
                        result.success("")
                    } else {
                        result.success(
                            try {
                                SecureAuthStore.decrypt(enc)
                            } catch (e: Exception) {
                                try { LogStore.append(this, "getAuth decrypt failed: ${e.message ?: e.javaClass.simpleName}") } catch (_: Exception) {}
                                null
                            }
                        )
                    }
                }
                "setAuth" -> {
                    val v = call.arguments as? String ?: ""
                    if (v.isBlank()) {
                        prefs.edit().remove("auth_enc").apply()
                    } else {
                        prefs.edit().putString("auth_enc", SecureAuthStore.encrypt(v)).apply()
                    }
                    result.success(null)
                }
                "getSmsEnabled" -> result.success(prefs.getBoolean("sms_enabled", true))
                "setSmsEnabled" -> {
                    val v = (call.arguments as? Boolean) ?: true
                    prefs.edit().putBoolean("sms_enabled", v).apply()
                    // Dynamically register/unregister observer
                    try { toggleSmsObserver(v) } catch (_: Exception) {}
                    result.success(null)
                }
                // Parity with MainActivity prefs channel for background engine
                "getAllowedPackages" -> {
                    val set = prefs.getStringSet("allowed_packages", setOf()) ?: setOf()
                    result.success(set.toList())
                }
                "setAllowedPackages" -> {
                    val list = (call.arguments as? List<*>)?.mapNotNull { it as? String } ?: emptyList()
                    prefs.edit().putStringSet("allowed_packages", list.toSet()).apply()
                    result.success(null)
                }
                "getRetryQueue" -> {
                    result.success(prefs.getString("retry_queue", "[]"))
                }
                "setRetryQueue" -> {
                    val v = call.arguments as? String ?: "[]"
                    prefs.edit().putString("retry_queue", v).apply()
                    result.success(null)
                }
                "getPayloadTemplate" -> {
                    val def = (
                            """
                            {
  "message_body": "{{body}}",
  "message_from": "{{from}}",
  "message_date": "{{date}}",
  "app": "{{app}}",
  "type": "{{type}}",
  "reception": "{{reception}}",
  "title": "{{title}}",
  "text": "{{text}}",
  "big_text": "{{bigText}}",
  "sub_text": "{{subText}}",
  "summary_text": "{{summaryText}}",
  "info_text": "{{infoText}}",
  "category": "{{category}}",
  "priority": "{{priority}}",
  "channel_id": "{{channelId}}",
  "visibility": "{{visibility}}",
  "color": "{{color}}",
  "group_key": "{{groupKey}}",
  "is_group_summary": "{{isGroupSummary}}",
  "when": "{{when}}",
  "actions": "{{actions}}",
  "people": "{{people}}",
  "badge_icon_type": "{{badgeIconType}}",
  "small_icon_base64": "{{smallIcon}}",
  "large_icon_base64": "{{largeIcon}}",
  "picture_base64": "{{picture}}"
}
                            """
                        ).trimIndent()
                    result.success(prefs.getString("payload_template", def))
                }
                "setPayloadTemplate" -> {
                    val v = (call.arguments as? String) ?: ""
                    prefs.edit().putString("payload_template", v).apply()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // Message channel
        val channel = MethodChannel(messenger, "msg_mirror")
        msgChannel = channel
        MsgNotificationListener.setChannelAndFlush(channel)

        // Now run Dart entrypoint
        engine!!.dartExecutor.executeDartEntrypoint(dartEntrypoint)
        FlutterEngineCache.getInstance().put("always_on_engine", engine)

        // Optional: register SMS observer if permission granted
        // reuse prefs declared above
        val smsEnabled = prefs.getBoolean("sms_enabled", true)
        if (smsEnabled && checkSelfPermission(Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED) {
            smsObserver = SmsObserver(this, channel)
            contentResolver.registerContentObserver(
                Telephony.Sms.Inbox.CONTENT_URI,
                true,
                smsObserver as SmsObserver
            )
            LogStore.append(this, "SmsObserver registered")
        } else {
            LogStore.append(this, "SmsObserver not registered (enabled=$smsEnabled, hasPerm=${checkSelfPermission(Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED})")
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        LogStore.append(this, "AlwaysOnService onStartCommand")
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        LogStore.append(this, "AlwaysOnService onDestroy")
        try {
            val prefs = getSharedPreferences("ntfy_mirror", MODE_PRIVATE)
            prefs.edit().putBoolean("service_running", false).apply()
        } catch (_: Exception) {}
        smsObserver?.let {
            try { contentResolver.unregisterContentObserver(it) } catch (_: Exception) {}
        }
        smsObserver = null
        MsgNotificationListener.channel = null
        engine?.destroy()
        engine = null
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun toggleSmsObserver(enable: Boolean) {
        if (enable) {
            if (checkSelfPermission(Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED) {
                if (smsObserver == null) {
                    val ch = msgChannel
                    if (ch != null) {
                        smsObserver = SmsObserver(this, ch)
                        contentResolver.registerContentObserver(
                            Telephony.Sms.Inbox.CONTENT_URI,
                            true,
                            smsObserver as SmsObserver
                        )
                        LogStore.append(this, "SmsObserver registered (toggle)")
                    } else {
                        LogStore.append(this, "SmsObserver toggle failed: no channel")
                    }
                }
            } else {
                LogStore.append(this, "SmsObserver toggle skipped: no permission")
            }
        } else {
            smsObserver?.let {
                try { contentResolver.unregisterContentObserver(it) } catch (_: Exception) {}
            }
            smsObserver = null
            LogStore.append(this, "SmsObserver unregistered (toggle)")
        }
    }

    // Test helper
    fun debugToggleSmsObserver(enable: Boolean) { toggleSmsObserver(enable) }
}
