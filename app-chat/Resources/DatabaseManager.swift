//
//  DatabaseManager.swift
//  app-chat
//
//  Created by Bui  Huy on 2/19/21.
//

import Foundation
import FirebaseDatabase
final class DatabaseManager{
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    static func safeEmail(email :String)->String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
// TODO: - Create Acount
extension DatabaseManager{
    public func userExits(with email:String, completion: @escaping ((Bool)->Void)){
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        database.child(safeEmail).observeSingleEvent(of: .value, with: {snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    public func getAllUser(completion: @escaping (Result <[[String:String]],Error>)->Void){
        database.child("users").observeSingleEvent(of: .value, with: {snapshot in
            guard let value = snapshot.value as? [[String:String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
    public enum DatabaseError: Error{
        case failedToFetch
    }
    
    public func inserUser(with user: ChatAppUSer, completion: @escaping(Bool)-> Void){
        database.child(user.safeEmail).setValue([
            "name" : user.name
        ], withCompletionBlock: {error, _ in
            guard error == nil else{
                print("Không thể thêm vào DB")
                completion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value, with: {snapshot in
                if var userCollection = snapshot.value as? [[String: String]]{
//                    thêm vào từ điển người dùng
                    let newElement = ["name":user.name,
                                      "email":user.safeEmail]
                    userCollection.append(newElement)
                    
                    self.database.child("users").setValue(userCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                    
                }else{
//                    Tạo mảng
                    let newCollection : [[String:String]] = [
                        ["name":user.name,
                         "email":user.safeEmail]
                    ]
                    self.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            return
                        }
                        completion(true)
                    })
                }
            })
        })
    }
}

extension DatabaseManager{
    public func createNewConversation(with otherEmail:String,name: String,fistMessengger: Message,completion: @escaping (Bool)->Void ){
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(email: currentEmail)
        let ref = database.child("\(safeEmail)")
        ref.observeSingleEvent(of: .value, with: {[weak self] snapshot in
            guard var userNode = snapshot.value as?[String:Any] else{
                completion(false)
                print("user not found")
                return
            }
            let messageDate = fistMessengger.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            var message = ""
            switch fistMessengger.kind{
            case .text(let messagerText):
                message = messagerText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            let conversationId = "conversation_\(fistMessengger.messageId)"
            let newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_email": otherEmail,
                "name": name,
                "latest_message":[
                    "date":dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            let recipient_newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_email": safeEmail,
                "name": "Self",
                "latest_message":[
                    "date":dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            self?.database.child("\(otherEmail)/conversation").observeSingleEvent(of: .value, with: {[weak self] snapshot in
                if var conversation = snapshot.value as? [[String:Any]]{
                    conversation.append(recipient_newConversationData)
                    self?.database.child("\(otherEmail)/conversation").setValue(conversation)
                }else{
                    self?.database.child("\(otherEmail)/conversation").setValue([recipient_newConversationData])
                }
            })
            
            if var conversation = userNode["conversation"] as? [[String:Any]]{
                conversation.append(newConversationData)
                userNode["conversation"] = conversation
                ref.setValue(userNode, withCompletionBlock: {[weak self]error, _ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    self?.finishCreatingConveration(name: name,
                                                    conversationId: conversationId,
                                                    fistMessage: fistMessengger,
                                                    completion: completion)
                })
            }else{
                userNode["conversation"] = [
                    newConversationData
                ]
                
                ref.setValue(userNode, withCompletionBlock: {[weak self]error, _ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    self?.finishCreatingConveration(name: name,
                                                    conversationId: conversationId,
                                                    fistMessage: fistMessengger,
                                                    completion: completion)
                })
            }
        })
    }
    
    private func finishCreatingConveration(name: String,conversationId: String, fistMessage : Message,completion: @escaping (Bool)->Void){
//        {
//            "id": String,
//            "type": text, photo,video,
//            "content": String,
//            "date": Date(),
//            "sender_email": String,
//            "isRead":true/false
//        }
        let messageDate = fistMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        var message = ""
        switch fistMessage.kind{
        case .text(let messagerText):
            message = messagerText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        let currentEmail = DatabaseManager.safeEmail(email: myEmail)
        let collectionMessage:[String:Any]=[
            "id": fistMessage.messageId,
            "type": fistMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentEmail,
            "is_read":false,
            "name":name
        ]
        let value: [String:Any] = [
            "message":[
                collectionMessage
            ]
        ]
        print("adding id: \(conversationId)")
        database.child("conversation").child("\(conversationId)").setValue(value, withCompletionBlock: {error, _ in
            guard error == nil else{
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    public func getAllConversation(for email: String,completion: @escaping (Result<[Conversation],Error>)->Void){
        database.child("\(email)/conversation").observe(.value, with: {snapshot in
            guard let value = snapshot.value as? [[String:Any]] else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            let convaersation: [Conversation] = value.compactMap({dictionary in
                guard let conversationId = dictionary ["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String:Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else{
                    return nil
                }
                let latestMmessageObject = latestMessger(date: date,
                                                         text: message,
                                                         isRead: isRead)
                return Conversation(id: conversationId,
                                    name: name,
                                    otherUserEmail: otherUserEmail,
                                    latestMessger: latestMmessageObject)
            })
            completion(.success(convaersation))
        })
    }
    public func getAllMessagesForConversation(wit id:String, completion: @escaping (Result<[Message],Error>)->Void){
        database.child("conversation").child("\(id)/message").observe(.value, with: {snapshot in
            guard let value = snapshot.value as? [[String:Any]] else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            let messages: [Message] = value.compactMap({dictionary in
                guard let name = dictionary["name"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let messageID = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let type = dictionary["type"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let date = ChatViewController.dateFormatter.date(from: dateString)else {
                    return nil
                }
                let sender = Sender(photoURl: "",
                                   senderId: senderEmail,
                                   displayName: name)
                
                return Message(sender: sender,
                               messageId: messageID,
                               sentDate: date,
                               kind: .text(content))
            })
            completion(.success(messages))
        })
    }
    
    public func senMessager(to conversation: String, mmessage: Message,completion: @escaping (Result<String,Error>)->Void){
        
    }
}

struct ChatAppUSer {
    let email: String
    let name : String
    var safeEmail:String{
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    var profilePictureFileName: String{
        return "\(safeEmail)_profile_picture.png"
    }
}
