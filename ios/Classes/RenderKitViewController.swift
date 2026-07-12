import SwiftUI
import UIKit

class RenderKitViewController: UIViewController {
  private let screenName: String
  private let state: [String: Any]

  init(screenName: String, state: [String: Any]) {
    self.screenName = screenName
    self.state = state
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white

    // Look up and render the SwiftUI View from the registry
    if let viewBuilder = RenderKitRegistry.screens[screenName] {
      let swiftUIView = viewBuilder(state) { actionName, args in
        // Forward SwiftUI actions to Dart
        RenderKitFlutterPlugin.emit(actionName: actionName, args: args)
      }
      
      let hostingController = UIHostingController(rootView: swiftUIView)
      addChild(hostingController)
      hostingController.view.frame = self.view.bounds
      hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      self.view.addSubview(hostingController.view)
      hostingController.didMove(toParent: self)
    } else {
      let errorLabel = UILabel()
      errorLabel.text = "Screen '\(screenName)' not registered in RenderKitRegistry."
      errorLabel.textColor = .red
      errorLabel.textAlignment = .center
      errorLabel.frame = self.view.bounds
      errorLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      self.view.addSubview(errorLabel)
    }
  }
}
