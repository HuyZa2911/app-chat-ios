//
//  ChatViewController.swift
//  app-chat
//
//  Created by Bui  Huy on 2/23/21.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message : MessageType {
    public var sender : SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}

extension MessageKind{
    var messageKindString:String{
        switch self{
            
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributedText"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
}

struct Sender: SenderType {
    public var photoURl: String
    public var senderId: String
    public var displayName: String
}
class ChatViewController: MessagesViewController {
    
    public static var dateFormatter: DateFormatter = {
       let formmater = DateFormatter()
        formmater.dateStyle = .medium
        formmater.timeStyle = .long
        formmater.locale = .current
        return formmater
    }()
    
    public let otherUserEmail: String
    private let conversationId: String?
    public var isNewConversation = false
    
    
    private var messages = [Message]()
    private var selfSender: Sender? {
    guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
        return nil
    }
        let safeEmail = DatabaseManager.safeEmail(email: email)
        return Sender(photoURl: "",
                      senderId: safeEmail,
                      displayName: "Me")
    }
    
    init(with email: String, id: String?) {
        self.conversationId = id
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    private func listenForMessages(id: String, shouldScollToBottom: Bool){
        DatabaseManager.shared.getAllMessagesForConversation(wit: id, completion: { [weak self] result in
            switch result{
            case .success(let messages):
                print("success in getting messages: \(messages)")
                guard !messages.isEmpty else {
                    print("messages are empty")
                    return
                }
                self?.messages = messages
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScollToBottom {
                        self?.messagesCollectionView.scrollToLastItem()
                    }
                }
            case .failure(let error):
                print("faild to messgager: \(error)")
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conersation = conversationId{
            listenForMessages(id: conersation, shouldScollToBottom: true)
        }
    }
}
extension ChatViewController: InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: " ").isEmpty,
        let  selfSender = self.selfSender,
        let  messageId = createMessgerId() else {
            return
        }
        print("Sending: \(text)")
//        Gửi tin nhắn
        if isNewConversation{
            let mmessage = Message(sender: selfSender,
                                   messageId: messageId,
                                   sentDate: Date(),
                                   kind: .text(text))
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User", fistMessengger: mmessage, completion: { [weak self] succeess in
                if succeess{
                    self?.isNewConversation = false
                    print("đã gửi tin nhắn")
                }else{
                    print("Chưa gửi tin nhắn")
                }
            })
        }else{
            
        }
    }
    private func createMessgerId()->String?{
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeCurrentEmail = DatabaseManager.safeEmail(email: currentUserEmail)
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"
        print("send messges: \(newIdentifier)")
        return newIdentifier
    }
}
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate{
    func currentSender() -> SenderType {
        if let sender  = selfSender{
            return sender
        }
        fatalError("self sender is nil, email should became")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}
