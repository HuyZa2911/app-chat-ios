//
//  RegesterViewController.swift
//  app-chat
//
//  Created by Bui  Huy on 2/18/21.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegesterViewController: UIViewController {
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
    private let rePasswordField : UITextField = {
        let feild = UITextField()
        feild.autocapitalizationType = .none
        feild.autocorrectionType = .no
        feild.returnKeyType = .done
        feild.layer.cornerRadius = 15
        feild.layer.borderWidth = 1
        feild.layer.borderColor = UIColor.lightGray.cgColor
        feild.placeholder = "Nhập lại mật khẩu"
        feild.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        feild.leftViewMode = .always
        feild.backgroundColor = .white
        feild.isSecureTextEntry = true
        return feild
    }()
    private let nameField : UITextField = {
        let feild = UITextField()
        feild.autocapitalizationType = .none
        feild.autocorrectionType = .no
        feild.returnKeyType = .continue
        feild.layer.cornerRadius = 15
        feild.layer.borderWidth = 1
        feild.layer.borderColor = UIColor.lightGray.cgColor
        feild.placeholder = "Nhập họ tên"
        feild.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        feild.leftViewMode = .always
        feild.backgroundColor = .white
        return feild
    }()
    private let regesterButton : UIButton = {
        let button = UIButton()
        button.setTitle("Đăng kí", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20,weight: .bold)
        return button
    }()
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Đăng kí"
        view.backgroundColor = .white
        regesterButton.addTarget(self, action: #selector(regesterButtonTapped), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        rePasswordField.delegate = self
        nameField.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(rePasswordField)
        scrollView.addSubview(nameField)
        scrollView.addSubview(regesterButton)
        
        imageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfilePic))
        imageView.addGestureRecognizer(gesture)
    }
    @objc private func didTapProfilePic(){
        persenPotoActionSheet()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        imageView.layer.cornerRadius = imageView.width/2.0
        emailField.frame = CGRect(x: 30,
                                  y: imageView.bottom+30,
                                  width: scrollView.width-60,
                                  height: 52)
        nameField.frame = CGRect(x: 30,
                                 y: emailField.bottom+10,
                                 width: scrollView.width-60,
                                 height: 52)
        passwordField.frame = CGRect(x: 30,
                                     y: nameField.bottom+10,
                                     width: scrollView.width-60,
                                     height: 52)
        rePasswordField.frame = CGRect(x: 30,
                                       y: passwordField.bottom+10,
                                       width: scrollView.width-60,
                                       height: 52)
        regesterButton.frame = CGRect(x: 30,
                                      y: rePasswordField.bottom+30,
                                      width: scrollView.width-60,
                                      height: 52)
    }
    @objc private func regesterButtonTapped(){
        guard let email = emailField.text, let password = passwordField.text,
              let rePassword = rePasswordField.text, let name = nameField.text, !email.isEmpty, !password.isEmpty, !rePassword.isEmpty, !name.isEmpty else {
            alertUserLogginfError()
            return
        }
        guard rePassword == password else {
            alertUserLogginfError(messgages: "Mật khẩu không chính xác")
            return
        }
        
        spinner.show(in: view)
//        TODO: Firebase regester
        DatabaseManager.shared.userExits(with: email, completion: {[weak self]exists in
            guard let strongSelf = self else{
                return
            }
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            guard !exists else {
                strongSelf.alertUserLogginfError(messgages: "Email đã tồn tại")
                return
            }
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: {authResult,error in
                guard authResult != nil, error == nil else {
                    print("Đăng kí không thành công")
                    return
                }
                let chatUser =  ChatAppUSer(email: email, name: name)
                DatabaseManager.shared.inserUser(with: chatUser, completion: {susess in
                    if susess{
//                        upload Images
                        guard let image = strongSelf.imageView.image, let data = image.pngData() else {
                            return
                        }
                        let fileName = chatUser.profilePictureFileName
                        StorageManeger.share.upLoadProfilePicture(with: data, fileName: fileName, completion: {result in
                            switch result {
                            case .success(let dowloadUrl):
                                UserDefaults.standard.setValue(dowloadUrl, forKeyPath: "profile_picture_url")
                                print(dowloadUrl)
                            case .failure(let error):
                                print("Lỗi Storage: \(error)")
                            }
                        })
                    }
                })
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
        })
    }
    @objc private func alertUserLogginfError(messgages:String = "Vui lòng nhập đầy đủ thông tin"){
        let alert = UIAlertController(title: "",
                                      message: messgages,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}
extension RegesterViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            nameField.becomeFirstResponder()
        }else if textField == nameField{
            passwordField.becomeFirstResponder()
        }else if textField == passwordField{
            rePasswordField.becomeFirstResponder()
        }
        else if textField == rePasswordField{
            regesterButtonTapped()
        }
        return true
    }
}
extension RegesterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func persenPotoActionSheet(){
        let actionsheet = UIAlertController(title: "Lấy hình từ",
                                            message: "",
                                            preferredStyle: .actionSheet)
        actionsheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        actionsheet.addAction(UIAlertAction(title: "Camara",
                                            style: .default,
                                            handler: { [weak self] _ in
                                             self?.presentCamara()
                                            }))
        actionsheet.addAction(UIAlertAction(title: "Thư viện",
                                            style: .default,
                                            handler: { [weak self] _ in
                                             self?.presentPhotopicker()
                                            }))
        present(actionsheet, animated: true)
    }
    func presentCamara(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        //        Cho phép cắt hình ảnh
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    func presentPhotopicker(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        //        Cho phép cắt hình ảnh
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let selectImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        self.imageView.image = selectImage
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
