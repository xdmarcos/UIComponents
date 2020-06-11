//
//  ActivityContainerView.swift
//
//  Created by xdmgzdev on 05/06/2020.
//  Copyright © 2020 Rabobank. All rights reserved.
//

import UIKit

public enum SpinnerSize {
  case medium
  case large
  case custom(scale: CGFloat)
}

public enum SpinnerType {
  case white(size: SpinnerSize)
  case gray(size: SpinnerSize)
  case custom(color: UIColor, size: SpinnerSize)
}

class ActivityContainerView: UIView {
  // MARK: - Properties

  private let hideBackgroundAnimationDuration: TimeInterval = 0.65
  private let showBackgroundAnimationDuration: TimeInterval = 1.375
  private let hideSpinnerAnimationDuration: TimeInterval = 0.8
  private let zeroAnimationDuration: TimeInterval = 0.0
  private let minAlpha: CGFloat = 0.0
  private let maxAlpha: CGFloat = 1.0
  private var spinnerOffSet = UIOffset(horizontal: 0.0, vertical: 0.0)
  private let backgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = .clear
    view.alpha = 0.0
    return view
  }()

  private let spinner: UIActivityIndicatorView

  // MARK: - View's lifecycle

  init(
    animationType: SpinnerType = .white(size: .medium),
    offset: UIOffset = UIOffset(horizontal: 0.0, vertical: 0.0)
  ) {
    var backgroundViewColor: UIColor = .clear
    var spinnerColor: UIColor = .white
    var selectedSize: SpinnerSize = .medium
    switch animationType {
    case let .white(size):
      backgroundViewColor = UIColor(white: 0.0, alpha: 0.4)
      spinnerColor = .white
      selectedSize = size
    case let .gray(size):
      backgroundViewColor = UIColor(white: 1.0, alpha: 0.75)
      spinnerColor = .gray
      selectedSize = size
    case let .custom(color, size):
      backgroundViewColor = UIColor(white: 1.0, alpha: 0.75)
      spinnerColor = color
      selectedSize = size
    }

    spinner = UIActivityIndicatorView()
    spinner.color = spinnerColor
    spinnerOffSet = offset

    super.init(frame: CGRect.zero)
    if #available(iOS 13.0, *) {
      setSizeAndScale(size: selectedSize)
    } else {
      setSizeAndScaleLegacy(size: selectedSize)
    }
    commonInit()
    setBackgroundColor(color: backgroundViewColor)
  }

  required init?(coder aDecoder: NSCoder) {
    spinner = UIActivityIndicatorView()
    super.init(coder: aDecoder)
    commonInit()
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    spinner.contentMode = .scaleAspectFill
    spinner.center = center
    backgroundView.frame = bounds
  }

  // MARK: - Public

  func setBackgroundColor(color: UIColor) {
    backgroundView.backgroundColor = color
  }

  func showSpinner() {
    layer.removeAllAnimations()
    spinner.center = center
    spinner.center.y = center.y + spinnerOffSet.vertical
    spinner.center.x = center.x + spinnerOffSet.horizontal
    spinner.alpha = maxAlpha
    isHidden = false
  }

  func hideSpinner(animated: Bool, completion: ((Bool) -> Void)? = nil) {
    let finalize: (_ finished: Bool) -> Void = { [weak self] finished in
      guard let self = self else { return }

      self.isHidden = true
      self.removeFromSuperview()

      completion?(finished)
    }

    if isHidden { return }

    UIView.animate(
      withDuration: animated ? hideSpinnerAnimationDuration : zeroAnimationDuration,
      animations: {
        self.spinner.alpha = self.minAlpha
        self.hideBackground(animated: animated)
      }, completion: { _ in
        finalize(true)
      }
    )
  }

  func showBackground(animated: Bool) {
    UIView.animate(
      withDuration: animated ? showBackgroundAnimationDuration : zeroAnimationDuration) {
      self.backgroundView.alpha = self.maxAlpha
    }
  }

  func hideBackground(animated: Bool) {
    UIView.animate(
      withDuration: animated ? hideBackgroundAnimationDuration : zeroAnimationDuration) {
      self.backgroundView.alpha = self.minAlpha
    }
  }

  func autoresizingSpinner() {
    spinner.autoresizingMask = [
      .flexibleLeftMargin,
      .flexibleRightMargin,
      .flexibleTopMargin,
      .flexibleBottomMargin,
    ]
  }

  func startSpinner() {
    spinner.startAnimating()
  }

  func stopSpinner() {
    spinner.stopAnimating()
  }
}

// MARK: Private

private extension ActivityContainerView {
  func commonInit() {
    backgroundColor = .clear
    addSubview(backgroundView)
    addSubview(spinner)
  }

  @available(iOS 13.0, *)
  func setSizeAndScale(size: SpinnerSize) {
    var activityStyle = UIActivityIndicatorView.Style.medium
    var activityScale: CGFloat = 1.0
    switch size {
    case .medium:
      activityStyle = .medium
      activityScale = 1.0
    case .large:
      activityStyle = .large
      activityScale = 1.0
    case let .custom(scale):
      activityStyle = .medium
      activityScale = scale
    }

    spinner.style = activityStyle
    spinner.transform = CGAffineTransform(scaleX: activityScale, y: activityScale)
  }

  func setSizeAndScaleLegacy(size: SpinnerSize) {
    var activityStyle = UIActivityIndicatorView.Style.white
    var activityScale: CGFloat = 1.0
    switch size {
    case .medium:
      activityStyle = .white
      activityScale = 1.0
    case .large:
      activityStyle = .whiteLarge
      activityScale = 1.0
    case let .custom(scale):
      activityStyle = .white
      activityScale = scale
    }

    spinner.style = activityStyle
    spinner.transform = CGAffineTransform(scaleX: activityScale, y: activityScale)
  }
}
