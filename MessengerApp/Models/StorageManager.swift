//
//  StorageManager.swift
//  MessengerApp
//
//  Created by 김광준 on 2021/06/25.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    /*
     storage path will be like this below
     /image/morgan-gmail-com_profile_picture.png
     */
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    // function get take bits the data and add file, written too.
    /// Uploads picture to firebase storage and return complition with url string to download
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        // put is samething with "REST API of uploading it"
        storage.child("images/\(fileName)").putData(data, metadata: nil) { metaData, error in
            guard error == nil else {
                print("Failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            }
        }
    }
    
    // create general function which is going to return the 'download URL' based on a path that I give it.
    
}
