// android/app/src/main/kotlin/com/example/must_invest/MainActivity.kt
package com.example.must_invest

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterFragmentActivity() {

    private lateinit var settingsMethodChannel: SettingsMethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Configure the settings method channel
        settingsMethodChannel = SettingsMethodChannel(this)
        settingsMethodChannel.configureFlutterEngine(flutterEngine)
    }
}
