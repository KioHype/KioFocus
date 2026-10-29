package com.kiohype.kiofocus

import android.accessibilityservice.AccessibilityService
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import org.json.JSONArray
import org.json.JSONObject

class KioFocusAccessibilityService : AccessibilityService() {

    private val TAG = "KioFocus"
    private val CHANNEL_ID = "kiofocus_timer"
    private val NOTIFICATION_ID = 1001
    private val RELEASE_WINDOW_MS = 10 * 60 * 1000L

    private val handler = Handler(Looper.getMainLooper())

    // Timer ativo (só existe um por vez)
    private var activeApp: String? = null
    private var activeAppName = ""
    private var activeEndMs = 0L
    private var endRunnable: Runnable? = null

    // Apps liberados (timer terminou) -> até quando o passe vale
    private val released = mutableMapOf<String, Long>()
    private var usingReleased: String? = null

    private var currentForeground = ""
    private var lastLaunchMs = 0L
    private val recommendedApps = mutableSetOf<String>()

    override fun onServiceConnected() {
        super.onServiceConnected()
        createChannel()
        Log.d(TAG, "Serviço conectado!")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return
        val pkg = event.packageName?.toString() ?: return

        // O próprio KioFocus só atualiza quem está na tela
        if (pkg == packageName) {
            currentForeground = pkg
            return
        }
        if (isIgnorable(pkg)) return

        currentForeground = pkg

        // Saiu de um app liberado? Então o passe acaba
        usingReleased?.let {
            if (it != pkg) {
                released.remove(it)
                usingReleased = null
            }
        }

        checkTimerFinished()

        // Continua usando o app liberado
        if (usingReleased == pkg) return

        // Tem passe válido para esse app?
        val until = released[pkg]
        if (until != null) {
            if (SystemClock.elapsedRealtime() <= until) {
                usingReleased = pkg
                cancelNotification()
                Log.d(TAG, "$pkg liberado")
                return
            }
            released.remove(pkg)
        }

        // Está na lista de bloqueados?
        val blocked = getBlockedApp(pkg) ?: return

        val totalSec = blocked.third * 60 + blocked.fourth

        // Outro app bloqueado: começa um timer novo (cancela o anterior)
        if (activeApp != pkg) {
            startTimer(pkg, blocked.second, totalSec)
        }

        // Evita lançar várias vezes seguidas
        val now = SystemClock.elapsedRealtime()
        if (now - lastLaunchMs < 600) return
        lastLaunchMs = now

        val remainingMs = (activeEndMs - now).coerceAtLeast(0L)
        Log.d(TAG, "BLOQUEANDO $pkg, faltam ${remainingMs / 1000}s")

        val intent = Intent(this, MainActivity::class.java).apply {
            action = "com.kiohype.kiofocus.CHECK_APP"
            putExtra("package_name", pkg)
            putExtra("app_name", blocked.second)
            putExtra("total_seconds", totalSec)
            putExtra("end_time_ms", System.currentTimeMillis() + remainingMs)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }
        startActivity(intent)
    }

    private fun isIgnorable(pkg: String): Boolean {
        return pkg == "android" ||
            pkg == "com.android.systemui" ||
            pkg.contains("inputmethod") ||
            pkg.contains("honeyboard") ||
            pkg.contains("keyboard") ||
            pkg.contains("biometrics")
    }

    private fun startTimer(pkg: String, name: String, totalSec: Int) {
        endRunnable?.let { handler.removeCallbacks(it) }
        cancelNotification()

        activeApp = pkg
        activeAppName = name
        activeEndMs = SystemClock.elapsedRealtime() + totalSec * 1000L

        val r = Runnable { finishTimer() }
        endRunnable = r
        handler.postDelayed(r, totalSec * 1000L)
        Log.d(TAG, "Timer iniciado para $pkg: ${totalSec}s")
    }

    private fun checkTimerFinished() {
        if (activeApp != null && SystemClock.elapsedRealtime() >= activeEndMs) {
            finishTimer()
        }
    }

    private fun finishTimer() {
        val pkg = activeApp ?: return
        val name = activeAppName

        endRunnable?.let { handler.removeCallbacks(it) }
        endRunnable = null
        activeApp = null

        released[pkg] = SystemClock.elapsedRealtime() + RELEASE_WINDOW_MS
        Log.d(TAG, "Timer de $pkg terminou, liberado")

        // Sem notificação se já está no KioFocus, no próprio app ou num app recomendado
        if (currentForeground == packageName || currentForeground == pkg) return
        loadRecommendedApps()
        if (recommendedApps.contains(currentForeground)) return

        showNotification(pkg, name)
    }

    private fun createChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val channel = NotificationChannel(
                CHANNEL_ID, "Timer KioFocus", NotificationManager.IMPORTANCE_HIGH
            )
            channel.description = "Avisa quando o tempo de espera acaba"
            nm.createNotificationChannel(channel)
        }
    }

    private fun showNotification(pkg: String, name: String) {
        try {
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                Notification.Builder(this, CHANNEL_ID)
            } else {
                Notification.Builder(this).setDefaults(Notification.DEFAULT_ALL)
            }

            builder
                .setSmallIcon(applicationInfo.icon)
                .setContentTitle("KioFocus — tempo concluído!")
                .setContentText("Você já pode abrir $name.")
                .setAutoCancel(true)

            // Tocar na notificação abre o app que estava bloqueado
            val launch = packageManager.getLaunchIntentForPackage(pkg)
            if (launch != null) {
                val pi = PendingIntent.getActivity(
                    this, 0, launch,
                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
                )
                builder.setContentIntent(pi)
            }

            // KioHype: para som personalizado, depois a gente configura aqui
            nm.notify(NOTIFICATION_ID, builder.build())
        } catch (e: Exception) {
            Log.e(TAG, "Erro na notificação: ${e.message}")
        }
    }

    private fun cancelNotification() {
        try {
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.cancel(NOTIFICATION_ID)
        } catch (e: Exception) {
        }
    }

    private fun loadRecommendedApps() {
        try {
            val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val raw = prefs.all["flutter.recommended_apps"] as? String ?: return
            val jsonString = if (raw.contains("!")) raw.substringAfter("!") else raw
            val array = JSONArray(jsonString)
            recommendedApps.clear()
            for (i in 0 until array.length()) {
                val obj = JSONObject(array.getString(i))
                recommendedApps.add(obj.getString("packageName"))
            }
        } catch (e: Exception) {
            Log.e(TAG, "Erro ao carregar recomendados: ${e.message}")
        }
    }

    private fun getBlockedApp(pkg: String): Quadruple<String, String, Int, Int>? {
        try {
            val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val raw = prefs.all["flutter.blocked_apps"] as? String ?: return null
            val jsonString = if (raw.contains("!")) raw.substringAfter("!") else raw
            val array = JSONArray(jsonString)

            for (i in 0 until array.length()) {
                val obj = JSONObject(array.getString(i))
                if (obj.getString("packageName") == pkg) {
                    return Quadruple(
                        obj.getString("packageName"),
                        obj.getString("appName"),
                        obj.getInt("timerMinutes"),
                        obj.getInt("timerSeconds")
                    )
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Erro ao ler bloqueados: ${e.message}")
        }
        return null
    }

    override fun onInterrupt() {
        endRunnable?.let { handler.removeCallbacks(it) }
    }

    override fun onDestroy() {
        super.onDestroy()
        endRunnable?.let { handler.removeCallbacks(it) }
    }
}

data class Quadruple<A, B, C, D>(
    val first: A,
    val second: B,
    val third: C,
    val fourth: D
)