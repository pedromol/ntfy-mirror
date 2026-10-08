package br.mol.net.br

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (Intent.ACTION_BOOT_COMPLETED == intent.action) {
            LogStore.append(context, "BootReceiver ACTION_BOOT_COMPLETED")
            val svc = Intent(context, AlwaysOnService::class.java)
            try {
                context.startForegroundService(svc)
            } catch (e: Exception) {
                try { LogStore.append(context, "Failed to auto-start service after boot: ${e.message ?: e.javaClass.simpleName}") } catch (_: Exception) {}
            }
        }
    }
}
