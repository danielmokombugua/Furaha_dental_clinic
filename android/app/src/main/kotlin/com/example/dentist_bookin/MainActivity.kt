package com.example.dentist_bookin

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.SecureRandom

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.furahadental/password"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "generateStrongPassword") {
                val length = call.argument<Int>("length") ?: 14
                try {
                    val password = PasswordGenerator.generateStrongPassword(length)
                    result.success(password)
                } catch (e: IllegalArgumentException) {
                    result.error("INVALID_LENGTH", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}

// Your Java component translated to Kotlin
object PasswordGenerator {
    private const val UPPER = "ABCDEFGHJKLMNPQRSTUVWXYZ"
    private const val LOWER = "abcdefghijkmnopqrstuvwxyz"
    private const val DIGITS = "123456789"
    private const val SPECIAL = "!@#$%^&*()_-+=<>?/[]{}"

    fun generateStrongPassword(length: Int): String {
        if (length < 12) {
            throw IllegalArgumentException("Password length must be at least 12 characters.")
        }

        val allChars = UPPER + LOWER + DIGITS + SPECIAL
        val random = SecureRandom()
        val passwordChars = CharArray(length)

        passwordChars[0] = UPPER[random.nextInt(UPPER.length)]
        passwordChars[1] = LOWER[random.nextInt(LOWER.length)]
        passwordChars[2] = DIGITS[random.nextInt(DIGITS.length)]
        passwordChars[3] = SPECIAL[random.nextInt(SPECIAL.length)]

        for (i in 4 until length) {
            passwordChars[i] = allChars[random.nextInt(allChars.length)]
        }

        for (i in passwordChars.size - 1 downTo 1) {
            val j = random.nextInt(i + 1)
            val temp = passwordChars[i]
            passwordChars[i] = passwordChars[j]
            passwordChars[j] = temp
        }

        return String(passwordChars)
    }
}