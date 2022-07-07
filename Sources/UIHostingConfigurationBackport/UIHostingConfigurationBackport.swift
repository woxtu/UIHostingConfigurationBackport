import SwiftUI
import UIKit

public struct UIHostingConfigurationBackport<Content, Background>: UIContentConfiguration where Content: View, Background: View {
  let content: Content
  let background: Background

  public init(@ViewBuilder content: () -> Content) where Background == EmptyView {
    self.content = content()
    background = .init()
  }

  init(content: Content, background: Background) {
    self.content = content
    self.background = background
  }

  public func makeContentView() -> UIView & UIContentView {
    return UIHostingContentViewBackport<Content, Background>(configuration: self)
  }

  public func updated(for state: UIConfigurationState) -> UIHostingConfigurationBackport {
    return self
  }

  public func background<S>(_ style: S) -> UIHostingConfigurationBackport<Content, _UIHostingConfigurationBackgroundViewBackport<S>> where S: ShapeStyle {
    return UIHostingConfigurationBackport<Content, _UIHostingConfigurationBackgroundViewBackport<S>>(
      content: content,
      background: .init(style: style)
    )
  }

  public func background<B>(@ViewBuilder content: () -> B) -> UIHostingConfigurationBackport<Content, B> where B: View {
    return UIHostingConfigurationBackport<Content, B>(
      content: self.content,
      background: content()
    )
  }
}

final class UIHostingContentViewBackport<Content, Background>: UIView, UIContentView where Content: View, Background: View {
  private let hostingController: UIHostingController<ZStack<TupleView<(Background, Content)>>?> = {
    let controller = UIHostingController<ZStack<TupleView<(Background, Content)>>?>(rootView: nil)
    controller.view.backgroundColor = .clear
    controller.view.translatesAutoresizingMaskIntoConstraints = false
    return controller
  }()

  var configuration: UIContentConfiguration {
    didSet {
      if let configuration = configuration as? UIHostingConfigurationBackport<Content, Background> {
        hostingController.rootView = ZStack {
          configuration.background
          configuration.content
        }
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

public struct _UIHostingConfigurationBackgroundViewBackport<S>: View where S: ShapeStyle {
  let style: S

  public var body: some View {
    Rectangle().fill(style)
  }
}

private extension UIResponder {
  var parentViewController: UIViewController? {
    return next as? UIViewController ?? next?.parentViewController
  }
}
