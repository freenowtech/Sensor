//
//  UIAlertController+Rx.swift
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

protocol RxAlertActionType {
    var title: String? { get }
    var style: UIAlertAction.Style { get }
    var result: RxAlertResult { get }
}

struct RxAlertAction: RxAlertActionType {
    let title: String?
    let style: UIAlertAction.Style
    let result: RxAlertResult
}

enum RxAlertResult {
    case succeedAction
    case cancelAction
}

struct RxAlert {
    let alert: UIAlertController
    let signal: Signal<RxAlertResult>
}

extension UIAlertController {
    static func rx_alert(
        title: String?,
        message: String?,
        preferredStyle: UIAlertController.Style = .alert,
        actions: [RxAlertAction]) -> RxAlert {

        let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)

        let observable = Observable<RxAlertResult>.create { observer -> Disposable in
            actions.map { rxAction in
                UIAlertAction(title: rxAction.title, style: rxAction.style, handler: { _ in
                    observer.onNext(rxAction.result)
                })
                }
                .forEach(alertController.addAction)

            return Disposables.create {
                alertController.dismiss(animated: true, completion: nil)
            }
        }
        let signal = ControlEvent(events: observable).asSignal()
        return RxAlert(alert: alertController, signal: signal)
    }
}
