//
//  LoginViewController.swift
//  app-chat
//
//  Created by Bui  Huy on 2/18/21.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class LoginViewController: UIViewController {
    private let spinner = JGProgressHUD(style: .dark)
    private let scrollView : UIScrollView = {
       let scollView = UIScrollView()
        scollView.clipsToBounds = true
        return scollView
    }()
    
    private let emailField : UITextField = {
        let feild = UITextField()
        feild.autocapitalizationType = .none
        feild.autocorrectionType = .no
        feild.returnKeyType = .continue
        feild.layer.cornerRadius = 15
        feild.layer.borderWidth = 1
        feild.layer.borderColor = UIColor.lightGray.cgColor
        feild.placeholder = "Nhập email"
        feild.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        feild.leftViewMode = .always
        feild.backgroundColor = .white
       return feild
    }()
    private let passwordField : UITextField = {
        let feild = UITextField()
        feild.autocapitalizationType = .none
        feild.autocorrectionType = .no
        feild.returnKeyType = .done
        feild.layer.cornerRadius = 15
        feild.layer.borderWidth = 1
        feild.layer.borderColor = UIColor.lightGray.cgColor
        feild.placeholder = "Nhập mật khẩu"
        feild.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        feild.leftViewMode = .always
        feild.backgroundColor = .white
        feild.isSecureTextEntry = true
       return feild
    }()
    private let loginButton : UIButton = {
       let button = UIButton()
        button.setTitle("Đăng nhập", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20,weight: .bold)
        return button
    }()
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Đăng nhập"
  
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Đăng kí",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegester))
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        emailField.frame = CGRect(x: 30,
                                  y: imageView.bottom+30,
                                  width: scrollView.width-60,
                                 height: 52)
        passwordField.frame = CGRect(x: 30,
                                  y: emailField.bottom+10,
                                  width: scrollView.width-60,
                                 height: 52)
        loginButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom+30,
                                   width: scrollView.width-60,
                                  height: 52)
    }
    @objc private func loginButtonTapped(){
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty else {
            alertUserLogginfError()
            return
        }
        
        spinner.show(in: view)
//        TODO: Firebase login
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult,error in
            guard let strongSelf = self else{
                return
            }
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            guard let result = authResult, error == nil else {
                print("Đăng nhập không thành công")
                strongSelf.alertUserLogginfError(messages: "Sai tài khoản hoặc mật khẩu")
                return
            }
            let user = result.user
            
            UserDefaults.standard.set(email, forKey: "email")
            
            print("Đã đăng nhập: \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    @objc private func alertUserLogginfError(messages : String = "Vui lòng nhập đầy đủ thông tin"){
        let alert = UIAlertController(title: "",
                                      message: messages,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
        present(alert, animated: true)
        
    }
    @objc private func didTapRegester(){
        let vc = RegesterViewController()
        vc.title = "Đăng kí"
        navigationController?.pushViewController(vc, animated: true)
    }
}
extension LoginViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField{
            loginButtonTapped()
        }
        return true
    }
}
