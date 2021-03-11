//
//  ConversationTableViewCell.swift
//  app-chat
//
//  Created by Bui  Huy on 3/6/21.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    
    static let identfier = "ConversationTableViewCell"
    
    private let userImageView: UIImageView = {
       let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 50
        image.layer.masksToBounds = true
        return image
    }()
    private let userNameLable:UILabel = {
       let lable = UILabel()
        lable.font = .systemFont(ofSize: 21,weight : .semibold)
        return lable
    }()
    private let userMessgerLable: UILabel = {
        let lable = UILabel()
        lable.font = .systemFont(ofSize: 19 ,weight : .regular)
        return lable
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String? ){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLable)
        contentView.addSubview(userMessgerLable)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.frame = CGRect(x: 10,
                                     y: 10,
                                     width: 100,
                                     height: 100)
        userNameLable.frame = CGRect(x: userImageView.right + 10,
                                     y: 10,
                                     width: contentView.width - 20 - userImageView.width,
                                     height: (contentView.heigth - 20)/2)
        userMessgerLable.frame = CGRect(x: userImageView.right + 10,
                                     y: userNameLable.bottom + 10,
                                     width: contentView.width - 20 - userImageView.width,
                                     height: (contentView.heigth - 20)/2)
    }
    
    public func configure(with model:Conversation){
        self.userMessgerLable.text = model.latestMessger.text
        self.userNameLable.text = model.name
        let path = "images/\(model.otherUserEmail)_profile_picture.png"
        StorageManeger.share.downloadURL(for: path, completion: {[weak self]result in
            switch result{
            case .success(let url):
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("faild to getimage: \(error)")
            }
        })
    }
}
