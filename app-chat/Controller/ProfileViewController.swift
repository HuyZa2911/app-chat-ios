//
//  ProfileViewController.swift
//  app-chat
//
//  Created by Bui  Huy on 2/18/21.
//

import UIKit
import FirebaseAuth
class ProfileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let data = ["Đăng xuất"]
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createHeaderTable()
    }
    func createHeaderTable() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(email: email)
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images/" + fileName
        let view = UIView(frame: CGRect(x: 0,
                                        y: 0,
                                        width: self.view.width,
                                        height: 300))
        view.backgroundColor = .link
        let imageView = UIImageView(frame: CGRect(x: (view.width - 150)/2,
                                                  y: 75,
                                                  width: 150,
                                                  height: 150))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = imageView.width/2
        view.addSubview(imageView)
        
        StorageManeger.share.downloadURL(for: path, completion: {[weak self] result in
            switch result {
            case .success(let url):
                self?.dowloadImage(imageView: imageView, url: url)
            case .failure(let error):
                print("Lỗi h/a: \(error)")
            }
        })
        
        return view
    }
    func dowloadImage(imageView: UIImageView, url: URL) {
        URLSession.shared.dataTask(with: url,completionHandler: {data, _, error in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }
        }).resume()
    }
}
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let actionSheet = UIAlertController(title: "",
                                            message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Đăng xuất",
                                            style: .destructive,
                                            handler: { [weak self] _ in
                                             guard let strongSelf = self else{
                                                return
                                             }
                                             do{
                                                try FirebaseAuth.Auth.auth().signOut()
                                                
                                                let vc = LoginViewController()
                                                let nav = UINavigationController(rootViewController: vc)
                                                nav.modalPresentationStyle = .fullScreen
                                                strongSelf.present(nav,animated:true)
                                             }catch{
                                                print("Đăng xuất thất bại")
                                             }
                                            }))
        actionSheet.addAction(UIAlertAction(title: "Hủy",
                                            style: .cancel,
                                            handler: nil))
       present(actionSheet, animated: true)
    }
}
