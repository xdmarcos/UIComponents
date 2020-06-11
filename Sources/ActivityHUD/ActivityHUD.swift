//
//  ActivityHUD.swift
//  NyanBankVIP
//
//  Created by xdmgzdev on 05/06/2020.
//  Copyright © 2020 Rabobank. All rights reserved.
//

import UIKit

public typealias TimerAction = (Bool) -> Void

public enum DelayHUD {
  case now
  case graceTime(delay: TimeInterval)

  var gracetime: TimeInterval {
    switch self {
    case .now:
      return 0.0
    case let .graceTime(delay):
      return max(delay, 0.0)
    }
  }
}

public class ActivityHUD {
  // MARK: Constants

  private static let shared = ActivityHUD()

  // MARK: Properties

  /// Grace time is the period of time (in seconds) that the invoked method may be running without
  /// showing the HUD. If the task finishes before the grace time runs out, the HUD will
  /// not be shown at all.
  /// This may be used to prevent HUD display for very short tasks.
  private var container: ActivityContainerView
  private var graceTimer: Timer?
  private var hideTimer: Timer?
  private var viewToPresentOn: UIView?
  private var timerActions = [String: TimerAction]()

  var isVisible: Bool { return !container.isHidden }
  var userInteractionOnUnderlyingViewsEnabled: Bool {
    get { return !container.isUserInteractionEnabled }

    set { container.isUserInteractionEnabled = !newValue }
  }

  // MARK: View's lifecycle

  public init(
    viewToPresentOn view: UIView? = nil,
    animationType: SpinnerType = .white(size: .medium),
    backgroundColor: UIColor? = nil,
    offset: UIOffset = UIOffset(horizontal: 0.0, vertical: 0.0)
  ) {
    container = ActivityContainerView(animationType: animationType, offset: offset)
    container.autoresizingSpinner()
    if let backgroundColor = backgroundColor {
      container.setBackgroundColor(color: backgroundColor)
    }

    viewToPresentOn = view

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(willEnterForeground(_:)),
      name: UIApplication.willEnterForegroundNotification,
      object: nil
    )

    userInteractionOnUnderlyingViewsEnabled = false
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  // MARK: - Public

  public static func show(when: DelayHUD = .graceTime(delay: 0.7)) {
    shared.show(when: when)
  }

  public static func hide(
    animated anim: Bool = true,
    completion: @escaping (_ completion: Bool) -> Void
  ) {
    shared.hide(animated: anim, completion: completion)
  }

  public static func hide(animated anim: Bool = true) {
    shared.hide(animated: anim)
  }

  public func show(when: DelayHUD = .graceTime(delay: 0.7)) {
    guard let view = viewToPresentOn else {
      guard let keyView = UIApplication.shared.connectedScenes
      .filter({ $0.activationState == .foregroundActive })
      .map({ $0 as? UIWindowScene })
      .compactMap({ $0 })
      .first?.windows
      .filter({ $0.isKeyWindow }).first else { return }

      show(inView: keyView, withDelay: when)
      return
    }

    // view
    show(inView: view, withDelay: when)
  }

  public func hide(animated anim: Bool = true, completion: TimerAction? = nil) {
    graceTimer?.invalidate()

    container.hideSpinner(animated: anim, completion: completion)
    stopAnimating()
  }

  public func startAnimating() {
    container.startSpinner()
  }

  public func stopAnimating() {
    container.stopSpinner()
  }

  // MARK: Actions

  @objc private func willEnterForeground(_: Notification?) {
    startAnimating()
  }

  @objc private func handleGraceTimer(_: Timer? = nil) {
    // Show the HUD only if the task is still running
    guard let valid = graceTimer?.isValid, valid else { return }
    showAndStartIndicator()
  }
}

// MARK: Private

private extension ActivityHUD {
  private func showAndStartIndicator() {
    graceTimer?.invalidate()

    container.showBackground(animated: true)
    container.showSpinner()

    startAnimating()
  }

  private func show(inView view: UIView, withDelay when: DelayHUD) {
    if !view.subviews.contains(container) {
      view.addSubview(container)
      container.frame.origin = CGPoint.zero
      container.frame.size = view.frame.size
      container.autoresizingMask = [.flexibleHeight, .flexibleWidth]
      container.isHidden = true
    }

    // If the grace time is set, postpone the HUD display
    if when.gracetime > 0.0 {
      let timer = Timer(
        timeInterval: when.gracetime,
        target: self,
        selector: #selector(handleGraceTimer(_:)),
        userInfo: nil,
        repeats: false
      )
      RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
      graceTimer = timer
    } else {
      showAndStartIndicator()
      graceTimer = nil
    }
  }
}
