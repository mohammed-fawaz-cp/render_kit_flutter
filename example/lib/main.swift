import SwiftUI

struct IncomingCallScreen: View {
    let state: [String: Any]
    let onEvent: (String, [String: Any]) -> Void

    var body: some View {
        VStack {
            Spacer()
            VStack {
                VStack {
                    Text("[Avatar]")
                        .frame(width: 80.0, height: 80.0)
                        .clipShape(Circle())
                    Spacer()
                    Text(String(describing: state["callerName"] ?? ""))
                    Spacer()
                    HStack {
                        Button(action: { onEvent("AcceptCallAction", [:]) }) {
                            Text("Accept")
                        }
                        Spacer()
                        Button(action: { onEvent("RejectCallAction", [:]) }) {
                            Text("Reject")
                        }
                    }
                }
                    .padding(.all, 24.0)
            }
            .background(Color.white)
            .cornerRadius(8)
            .shadow(radius: 4)
            Spacer()
        }
    }
}
