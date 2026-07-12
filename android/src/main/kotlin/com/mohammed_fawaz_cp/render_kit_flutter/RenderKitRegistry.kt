package com.mohammed_fawaz_cp.render_kit_flutter

import androidx.compose.runtime.Composable

object RenderKitRegistry {
    val screens = HashMap<String, @Composable (state: Map<String, Any>, onEvent: (String, Map<String, Any>) -> Unit) -> Unit>()
}
