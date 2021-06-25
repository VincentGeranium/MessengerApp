//
//  ComposeViewModel.swift
//  MessengerApp
//
//  Created by 김광준 on 2021/06/25.
//

import Foundation
import UIKit

//protocol ComposeButtonViewModelProtocol {
//    func composeButton(vc : UIViewController,
//                       action: Selector,
//                       compltion: @escaping (Result<String, Error>) -> Void) -> UIBarButtonItem
//}


final class ComposeButtonViewModel {
//    var composeButtonViewModel: ComposeButtonViewModel?
   public func composeButton(vc : UIViewController, action: Selector) -> UIBarButtonItem {
        
        return UIBarButtonItem(barButtonSystemItem: .compose, target: vc, action: action)
    }
}

