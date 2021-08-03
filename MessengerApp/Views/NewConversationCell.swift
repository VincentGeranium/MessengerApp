//
//  NewConversationCell.swift
//  MessengerApp
//
//  Created by 김광준 on 2021/08/02.
//

import Foundation
/*
 Discription :
 -> SDWebImage is allows the download and cache basically what I need
 SDWebImage is doing basically takes care of caching for me.
 */
import SDWebImage

class NewConversationCell: UITableViewCell {
    
    /*
     Reason of make static constant
     -> Because when regist the this cell to tabelView that need identifier
     */
    static let identifire: String = "NewConversationCell"
    
    // ImageView, loading the user's avatar.
    /*
     If make 'corner radius value' that way of hard coding and do substitute the
     specific number that '50', It will be circular.
     */
    private let userAvatarImageView: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // add all the subviews in here
        contentView.addSubview(userAvatarImageView)
        contentView.addSubview(userNameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // frame each of subviews
        /*
         Discussion: About Cell Height
         As I can see the userAvatarImageView's frame that got top buffer is 10 and bottom buffer 10 picxel
         */
        userAvatarImageView.frame = CGRect(x: 10,
                                           y: 10,
                                           width: 70,
                                           height: 70)
        
        userNameLabel.frame = CGRect(x: userAvatarImageView.right + 10,
                                     y: 20,
                                     width: contentView.width - 20 - userAvatarImageView.width,
                                     height: 50)
    }
    
    public func configure(with model: SearchReslut) {
        self.userNameLabel.text = model.name
        
        /*
         When download image in Profile tap, actually downloads image every single time.
         But that way to downloads images which is not ideal way.
         So, I did create the code which is download used by 'SDWebImage' framework.
         To add SDWebImage is doing it basically takes care of caching for me.
         */
        
        
        // This should be the email address of the target user
        let path = "images/\(model.email)_profile_picture.png"
        StorageManager.shared.downloadURL(for: path) { [weak self] result in
            switch result {
            // in the success case, it's give to download URL for the asset
            case .success(let url):
                // Actually this is take care of downloading image and ready assigning it to image view
                // And keep in mind this is UI operation, so do it on the main thread
                DispatchQueue.main.async {
                    self?.userAvatarImageView.sd_setImage(with: url, completed: { image, error, sdImageCacheType, url in
                        print("🙌result of the 'image' param that sd_setImage method in completed : \(image)")
                        print("🙌result of the 'error' param that sd_setImage method in completed : \(error)")
                        print("🙌result of the 'sdImageCacheType' param that sd_setImage method in completed : \(sdImageCacheType)")
                        print("🙌result of the 'url' param that sd_setImage method in completed : \(url)")
                    })
                }
            
            // in the failure case, it's give error
            case .failure(let error):
                print("The reason of failed to get image url : \(error)")
            }
        }
        
    }

}
