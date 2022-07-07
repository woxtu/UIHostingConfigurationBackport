import SwiftUI
import UIKit

public struct UIHostingConfigurationBackport<Content, Background>: UIContentConfiguration where Content: View, Background: View {
  let content: Content
  let background: Background
  let margins: NSDirectionalEdgeInsets

  public init(@ViewBuilder content: () -> Content) where Background == EmptyView {
    self.content = content()
    background = .init()
    margins = .zero
  }

  init(content: Content, background: Background, margins: NSDirectionalEdgeInsets) {
    self.content = content
    self.background = background
    self.margins = margins
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
      background: .init(style: style),
      margins: margins
    )
  }

  public func background<B>(@ViewBuilder content: () -> B) -> UIHostingConfigurationBackport<Content, B> where B: View {
    return UIHostingConfigurationBackport<Content, B>(
      content: self.content,
      background: content(),
      margins: margins
    )
  }

  public func margins(_ insets: EdgeInsets) -> UIHostingConfigurationBackport<Content, Background> {
    return UIHostingConfigurationBackport<Content, Background>(
      content: content,
      background: background,
      margins: .init(insets)
    )
  }

  public func margins(_ edges: Edge.Set = .all, _ length: CGFloat) -> UIHostingConfigurationBackport<Content, Background> {
    return UIHostingConfigurationBackport<Content, Background>(
      content: content,
      background: background,
      margins: .init(
        top: edges.contains(.top) ? length : margins.top,
        leading: edges.contains(.leading) ? length : margins.leading,
        bottom: edges.contains(.bottom) ? length : margins.bottom,
        trailing: edges.contains(.trailing) ? length : margins.trailing
      )
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
        directionalLayoutMargins = configuration.margins
      }
    }
  }

  init(configuration: UIContentConfiguration) {
    self.configuration = configuration

    super.init(frame: .zero)

    addSubview(hostingController.view)
    NSLayoutConstraint.activate([
      hostingController.view.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
      hostingController.view.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
      hostingController.view.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
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
