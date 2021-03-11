//
//  StorageManage.swift
//  app-chat
//
//  Created by Bui  Huy on 2/26/21.
//

import Foundation
import  FirebaseStorage

final class StorageManeger{
    static let share  = StorageManeger()
    private let storage = Storage.storage().reference()
    public typealias UploadPictureCompletion = (Result<String,Error>)->Void
    public func upLoadProfilePicture(with data:Data,
                                fileName : String ,
                                completion: @escaping UploadPictureCompletion){
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: {metaData, error in
            guard error == nil else{
                print("Failed to upload")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            self.storage.child("images/\(fileName)").downloadURL(completion: {url, error in
                guard let url = url else{
                    print("")
                    completion(.failure(StorageErrors.FailedToDowloadUrl))
                    return
                }
                let urlString = url.absoluteString
                print("dowload url return :\(urlString)")
                completion(.success(urlString))
            })
        })
    }
    public enum StorageErrors: Error{
        case failedToUpload
        case FailedToDowloadUrl
    }
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
         let reference = storage.child(path)

         reference.downloadURL(completion: { url, error in
             guard let url = url, error == nil else {
                 completion(.failure(StorageErrors.FailedToDowloadUrl))
                 return
             }

             completion(.success(url))
         })
     }
}
