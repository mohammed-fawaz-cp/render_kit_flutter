import androidx.compose.runtime.*
import androidx.compose.ui.*
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.graphics.Color
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.ui.draw.clip

@Composable
fun IncomingCallScreen(
    state: Map<String, Any>,
    onEvent: (actionName: String, args: Map<String, Any>) -> Unit
) {
    Box(contentAlignment = Alignment.Center, modifier = Modifier.fillMaxSize()) {
        Card(modifier = Modifier.fillMaxWidth()) {
            Box(modifier = Modifier.padding(24.0.dp)) {
                Column(
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Box(
                        modifier = Modifier
                            .size(80.0.dp)
                            .clip(CircleShape)
                    ) {
                        Text("[Avatar]", modifier = Modifier.align(Alignment.Center))
                    }
                    Spacer(modifier = Modifier.weight(1f))
                    Text(text = state["callerName"].toString())
                    Spacer(modifier = Modifier.weight(1f))
                    Row(
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Button(onClick = { onEvent("AcceptCallAction", mapOf()) }) {
                            Text("Accept")
                        }
                        Spacer(modifier = Modifier.weight(1f))
                        Button(onClick = { onEvent("RejectCallAction", mapOf()) }) {
                            Text("Reject")
                        }
                    }
                }
            }
        }
    }

}
