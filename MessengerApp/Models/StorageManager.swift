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
    
    // internal private reference to the firebase storage object
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
    
    // general function, return 'the download url' based 'path' that I give it.
        // this function provide completion handler
        // completion handler will give me a result value back with 'String' or 'optionally Error' rather in the failer case as Error
        // this hole completion handler return 'void'

    public func downloadURL(for path: String, completion:  @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        
        reference.downloadURL { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadURL))
                return
            }
            completion(.success(url))
        }
    }
    
}
