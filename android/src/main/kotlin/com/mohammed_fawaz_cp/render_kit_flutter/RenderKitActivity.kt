package com.mohammed_fawaz_cp.render_kit_flutter

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import com.renderkit.generated.RenderKitRegistry

class RenderKitActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val screenName = intent.getStringExtra("screen_name") ?: ""
        val state = (intent.getSerializableExtra("state") as? HashMap<String, Any>) ?: hashMapMapOf()

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
