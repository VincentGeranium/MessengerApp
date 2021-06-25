//
//  StorageErrors.swift
//  MessengerApp
//
//  Created by 김광준 on 2021/06/25.
//

import Foundation
import UIKit

public enum StorageErrors: Error {
    case failedToUpload
    case failedToGetDownloadURL
}
