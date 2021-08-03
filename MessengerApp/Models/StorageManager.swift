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
    
    public typealias UploadPhotoComplertionHandler = (Result<String, Error>) -> Void
    
    public typealias UploadVideoComplertionHandler = (Result<String, Error>) -> Void
    
    public typealias DownloadURLCompletionHandler = (Result<URL, Error>) -> Void
    
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

    public func downloadURL(for path: String, completion:  @escaping DownloadURLCompletionHandler) {
        let reference = storage.child(path)
        
        reference.downloadURL { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadURL))
                return
            }
            completion(.success(url))
        }
    }
    
    /// Upload image that will be sent in a conversation message
    public func uploadMessagePhoto(with data: Data, fileName: String, completion: @escaping UploadPhotoComplertionHandler) {
        // Put the data into new folder in my bucket and it call 'message_images'
        storage.child("message_images/\(fileName)").putData(data, metadata: nil) { [weak self] storageMetaData, error in
            guard error == nil else {
                // failed
                print("Failed to upload photo data to firebase for send photo message")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            // get to image URL
            self?.storage.child("message_images/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    print("Failed to get download URL that photo data of message_images")
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                // URL is gonna be content of message in the messaages collection and in the real time database, So get the URL
                let urlString = url.absoluteString
                print("download url returned this : \(urlString)")
                completion(.success(urlString))
            }
        }
    }
    
    /// Upload video that will be sent in a conversation message
    public func uploadMessageVideo(with fileUrl: URL, fileName: String, completion: @escaping UploadPictureCompletion) {
        // insert video in storage
        let videoRef = storage.child("message_videos_/\(fileName)")
        
        videoRef.putFile(from: fileUrl, metadata: nil) { [weak self] storageMetaData, error in
            guard error == nil else {
                // failed
                print("Failed to upload video data to firebase for send video message")
                videoRef.getMetadata { meta, error in
                    if let error = error {
                        print("🎯🎯Failed to get metadata : \(error)")
                    } else {
                        print("🎯🎯get metadata : \(meta)")
                    }
                }

                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            // get video metadata
            videoRef.getMetadata { metadata, error in
                guard error == nil else {
                    // failed to get metadata
                    print("Failed to get metadata from storage")
                    return
                }
                print("🎯This is metadaata\(metadata)🎯")
            }
            
            // get to video URL
            self?.storage.child("message_videos_/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    print("Failed to get download URL that video data of message_videos")
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                // URL is gonna be content of message in the messaages collection and in the real time database, So get the URL
                let urlString = url.absoluteString
                print("download url returned this : \(urlString)")
                completion(.success(urlString))
            }
        }
    }
}
