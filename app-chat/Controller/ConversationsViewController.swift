//
//  ViewController.swift
//  app-chat
//
//  Created by Bui  Huy on 2/18/21.
//

import UIKit
import  FirebaseAuth
import JGProgressHUD

struct Conversation {
    let id:String
    let name:String
    let otherUserEmail:String
    let latestMessger: latestMessger
}
struct latestMessger {
    let date: String
    let text: String
    let isRead: Bool
}

class ConversationsViewController: UIViewController {
    private let spinner = JGProgressHUD(style: .dark)
    
    private var conversations = [Conversation]()
    
    private let tableView:UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(ConversationTableViewCell.self,
                       forCellReuseIdentifier: ConversationTableViewCell.identfier)
        return table
    }()
    private let noConversationLable: UILabel = {
       let lable = UILabel()
        lable.text = "Không có cuộc trò chuyện nào!"
        lable.textAlignment = .center
        lable.textColor = .gray
        lable.font = .systemFont(ofSize: 21, weight: .medium)
        lable.isHidden = true
        return lable
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(didTapComposeButton))
        view.addSubview(tableView)
        view.addSubview(noConversationLable)
        setupTableView()
        fetchConversation()
        startListeningForConversation()
    }
    
    private func startListeningForConversation(){
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        print("starting conversation fetch...")
        let safeEmail = DatabaseManager.safeEmail(email: email)
        DatabaseManager.shared.getAllConversation(for: safeEmail, completion: {[weak self]result in
            switch result{
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    return
                }
                self?.conversations = conversations
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            case .failure(let error):
                print("không nhận được chuyển đổi \(error)")
            }
        })
    }
    
    @objc private func didTapComposeButton() {
        let vc  = NewConersationViewController()
        vc.completion = { result in
            self.createNewConvertion(result: result)
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    private func createNewConvertion(result: [String:String]){
        guard let name = result["name"] , let email = result["email"] else {
            return
        }
        let vc = ChatViewController(with: email, id: nil)
        vc.isNewConversation = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    private func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
                    let vc = LoginViewController()
                    let nav = UINavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .fullScreen
                    present(nav,animated:false)
                }
    }
    private func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    private func fetchConversation(){
        tableView.isHidden = false
    }
}
extension ConversationsViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identfier,
                                                 for: indexPath) as! ConversationTableViewCell
        cell.configure(with: model)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        
        let vc = ChatViewController(with: model.otherUserEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
