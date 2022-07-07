import SwiftUI
import UIKit

public struct UIHostingConfigurationBackport<Content>: UIContentConfiguration where Content: View {
  let content: Content

  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  public func makeContentView() -> UIView & UIContentView {
    return UIHostingContentViewBackport<Content>(configuration: self)
  }

  public func updated(for state: UIConfigurationState) -> UIHostingConfigurationBackport {
    return self
  }
}

final class UIHostingContentViewBackport<Content>: UIView, UIContentView where Content: View {
  private let hostingController: UIHostingController<Content?> = {
    let controller = UIHostingController<Content?>(rootView: nil)
    controller.view.backgroundColor = .clear
    controller.view.translatesAutoresizingMaskIntoConstraints = false
    return controller
  }()

  var configuration: UIContentConfiguration {
    didSet {
      if let configuration = configuration as? UIHostingConfigurationBackport<Content> {
        hostingController.rootView = configuration.content
      }
    }
  }

  init(configuration: UIContentConfiguration) {
    self.configuration = configuration

    super.init(frame: .zero)

    addSubview(hostingController.view)
    NSLayoutConstraint.activate([
      hostingController.view.topAnchor.constraint(equalTo: topAnchor),
      hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor),
      hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func didMoveToSuperview() {
    if superview == nil {
      hostingController.willMove(toParent: nil)
      hostingController.removeFromParent()
    } else {
      parentViewController?.addChild(hostingController)
      hostingController.didMove(toParent: parentViewController)
    }
  }
}

private extension UIResponder {
  var parentViewController: UIViewController? {
    return next as? UIViewController ?? next?.parentViewController
  }
}
