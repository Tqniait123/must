// android/app/src/main/kotlin/com/example/must_invest/MainActivity.kt
package com.example.must_invest

import android.content.pm.PackageManager
import androidx.biometric.BiometricManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "biometric_capabilities"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getBiometricCapabilities" -> {
                    try {
                        val capabilities = getBiometricCapabilities()
                        result.success(capabilities)
                    } catch (e: Exception) {
                        result.error("ERROR", "Failed to get biometric capabilities", e.message)
                    }
                }
                "hasFaceUnlock" -> {
                    try {
                        val hasFace = hasFaceUnlock()
                        result.success(hasFace)
                    } catch (e: Exception) {
                        result.error("ERROR", "Failed to check face unlock", e.message)
                    }
                }
                "hasFingerprint" -> {
                    try {
                        val hasFingerprint = hasFingerprint()
                        result.success(hasFingerprint)
                    } catch (e: Exception) {
                        result.error("ERROR", "Failed to check fingerprint", e.message)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getBiometricCapabilities(): Map<String, Any> {
        val biometricManager = BiometricManager.from(this)
        val packageManager = this.packageManager

        val capabilities = HashMap<String, Any>()

        // Check overall biometric availability
        val canAuthenticate = biometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG)
        capabilities["canAuthenticate"] = canAuthenticate == BiometricManager.BIOMETRIC_SUCCESS

        // Check for face authentication capability
        val hasFaceAuth = packageManager.hasSystemFeature(PackageManager.FEATURE_FACE) ||
                         packageManager.hasSystemFeature("android.hardware.biometrics.face") ||
                         packageManager.hasSystemFeature("android.hardware.face")
        capabilities["hasFaceAuth"] = hasFaceAuth

        // Check for fingerprint capability
        val hasFingerprint = packageManager.hasSystemFeature(PackageManager.FEATURE_FINGERPRINT) ||
                            packageManager.hasSystemFeature("android.hardware.fingerprint")
        capabilities["hasFingerprint"] = hasFingerprint

        // Check for iris capability
        val hasIris = packageManager.hasSystemFeature("android.hardware.biometrics.iris") ||
                     packageManager.hasSystemFeature("android.hardware.iris")
        capabilities["hasIris"] = hasIris

        // Get biometric status
        capabilities["biometricStatus"] = when (canAuthenticate) {
            BiometricManager.BIOMETRIC_SUCCESS -> "available"
            BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE -> "no_hardware"
            BiometricManager.BIOMETRIC_ERROR_HW_UNAVAILABLE -> "hardware_unavailable"
            BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED -> "none_enrolled"
            BiometricManager.BIOMETRIC_ERROR_SECURITY_UPDATE_REQUIRED -> "security_update_required"
            BiometricManager.BIOMETRIC_ERROR_UNSUPPORTED -> "unsupported"
            BiometricManager.BIOMETRIC_STATUS_UNKNOWN -> "unknown"
            else -> "unknown"
        }

        // Additional checks for face unlock
        try {
            val faceManager = getSystemService("face")
            capabilities["hasFaceManager"] = faceManager != null
        } catch (e: Exception) {
            capabilities["hasFaceManager"] = false
        }

        // Debug logging
        android.util.Log.d("BiometricCapabilities", "canAuthenticate: ${capabilities["canAuthenticate"]}")
        android.util.Log.d("BiometricCapabilities", "hasFaceAuth: ${capabilities["hasFaceAuth"]}")
        android.util.Log.d("BiometricCapabilities", "hasFingerprint: ${capabilities["hasFingerprint"]}")
        android.util.Log.d("BiometricCapabilities", "biometricStatus: ${capabilities["biometricStatus"]}")

        return capabilities
    }

    private fun hasFaceUnlock(): Boolean {
        val packageManager = this.packageManager
        return packageManager.hasSystemFeature(PackageManager.FEATURE_FACE) ||
               packageManager.hasSystemFeature("android.hardware.biometrics.face") ||
               packageManager.hasSystemFeature("android.hardware.face")
    }

    private fun hasFingerprint(): Boolean {
        val packageManager = this.packageManager
        return packageManager.hasSystemFeature(PackageManager.FEATURE_FINGERPRINT) ||
               packageManager.hasSystemFeature("android.hardware.fingerprint")
    }
}
