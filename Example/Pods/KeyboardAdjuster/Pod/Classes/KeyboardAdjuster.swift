//
//  Copyright 2016 Lionheart Software LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

public protocol KeyboardAdjusterOptions {
    var animateKeyboardTransition: Bool { get }
    func keyboardWillHideHandler()
    func keyboardWillShowHandler()
}

public class KeyboardLayoutGuide: UILayoutGuide {
    fileprivate var willHideBlockObserver: NSObjectProtocol?
    fileprivate var willShowBlockObserver: NSObjectProtocol?
    fileprivate var constraint: NSLayoutConstraint!

    init(view: UIView) {
        super.init()
        
        identifier = "KeyboardLayoutGuide"
        
        view.addLayoutGuide(self)

        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        constraint = topAnchor.constraint(equalTo: view.bottomAnchor)
        constraint.isActive = true
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        // See https://useyourloaf.com/blog/unregistering-nsnotificationcenter-observers-in-ios-9/
        let center = NotificationCenter.default
        if let willShowBlockObserver = willShowBlockObserver {
            center.removeObserver(willShowBlockObserver)
        }
        
        if let willHideBlockObserver = willHideBlockObserver {
            center.removeObserver(willHideBlockObserver)
        }
    }
}

extension UIViewController {
    public var keyboardLayoutGuide: KeyboardLayoutGuide {
        guard let guide = view.layoutGuides.first(where: { $0 is KeyboardLayoutGuide }) as? KeyboardLayoutGuide else {
            return makeKeyboardLayoutGuide()
        }
        
        return guide
    }

    private func makeKeyboardLayoutGuide() -> KeyboardLayoutGuide {
        let guide = KeyboardLayoutGuide(view: view)
        
        let center = NotificationCenter.default
        let queue = OperationQueue.main
        guide.willHideBlockObserver = center.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: queue, using: { [weak self] notification in
            (self as? KeyboardAdjusterOptions)?.keyboardWillHideHandler()

            self?.keyboardWillChangeAppearance(notification, toState: .hidden)
        })
        
        guide.willShowBlockObserver = center.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: queue, using: { [weak self] notification in
            (self as? KeyboardAdjusterOptions)?.keyboardWillShowHandler()

            self?.keyboardWillChangeAppearance(notification, toState: .visible)
        })
        
        return guide
    }
    
    enum KeyboardState {
        case hidden
        case visible
    }

    private func keyboardWillChangeAppearance(_ sender: Notification, toState: KeyboardState) {
        guard let userInfo = sender.userInfo,
            let _curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
            let curve = UIView.AnimationCurve(rawValue: _curve),
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
                return
        }

        let curveAnimationOption: UIView.AnimationOptions
        switch curve {
        case .easeIn:
            curveAnimationOption = .curveEaseIn

        case .easeInOut:
            curveAnimationOption = []

        case .easeOut:
            curveAnimationOption = .curveEaseOut

        case .linear:
            curveAnimationOption = .curveLinear
            
        default:
            // This probably doesn't map 1-1 with the animation curve provided in userInfo, but there's no way to tell which one it should really be, so I made an educated guess. :)
            curveAnimationOption = .curveEaseOut
        }

        switch toState {
        case .hidden:
            keyboardLayoutGuide.constraint.constant = 0

        case .visible:
            guard let value = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
                debugPrint("UIKeyboardFrameEndUserInfoKey not available.")
                break
            }

            let frame = value.cgRectValue
            keyboardLayoutGuide.constraint.constant = -frame.height
        }

        if (self as? KeyboardAdjusterOptions)?.animateKeyboardTransition ?? true {
            let animationOptions: UIView.AnimationOptions = [.beginFromCurrentState, curveAnimationOption]
            UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: {
                self.view.layoutIfNeeded()
            })
        } else {
            view.layoutIfNeeded()
        }
    }
}
