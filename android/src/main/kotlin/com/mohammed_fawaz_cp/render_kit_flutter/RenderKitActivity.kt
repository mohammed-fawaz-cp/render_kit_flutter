package com.mohammed_fawaz_cp.render_kit_flutter

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface

class RenderKitActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val screenName = intent.getStringExtra("screen_name") ?: ""
        val state = (intent.getSerializableExtra("state") as? HashMap<String, Any>) ?: hashMapMapOf()

        // Dynamically invoke generated registry initializer if map is empty
        if (RenderKitRegistry.screens.isEmpty()) {
            try {
                val clazz = Class.forName("com.renderkit.generated.RenderKitRegistryInitializer")
                val method = clazz.getMethod("initialize")
                method.invoke(null)
            } catch (e: Exception) {
                // Registry not compiled yet or not found
            }
        }

        setContent {
            MaterialTheme {
                Surface {
                    val screen = RenderKitRegistry.screens[screenName]
                    if (screen != null) {
                        screen(state) { actionName, args ->
                            // Pipe events back through the plugin's MethodChannel
                            RenderKitFlutterPlugin.emit(actionName, args)
                        }
                    } else {
                        androidx.compose.material3.Text("Screen '$screenName' not registered in RenderKitRegistry.")
                    }
                }
            }
        }
    }

    private fun hashMapMapOf(): HashMap<String, Any> = HashMap()
}
