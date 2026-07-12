package com.renderkit.generated

import androidx.compose.runtime.Composable

object RenderKitRegistry {
    val screens = mapOf<String, @Composable (state: Map<String, Any>, onEvent: (String, Map<String, Any>) -> Unit) -> Unit>(
        "IncomingCallScreen" to { state, onEvent -> IncomingCallScreen(state = state, onEvent = onEvent) }
    )
}
