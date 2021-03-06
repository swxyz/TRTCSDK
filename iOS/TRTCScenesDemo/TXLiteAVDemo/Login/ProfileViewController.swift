//
//  loginProfileViewController.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 1/2/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation
import RxSwift
import NVActivityIndicatorView
import Toast_Swift

class ProfileViewController: UIViewController {
    let disposeBag = DisposeBag()
    let loading = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 60),
                                          type: .ballBeat,
                                          color: .appTint)
    /// trtc title
    let trtcTitle: UILabel = {
        let title = UILabel()
        title.textColor = .appTint
        title.font = UIFont.boldSystemFont(ofSize: 30)
        title.text = "Tencent Cloud TRTC"
        title.textAlignment = .center
        return title
    }()
    
    let avatarTip: UILabel = {
        let tip = UILabel()
        tip.text = "Avatar"
        tip.textColor = .white
        tip.font = UIFont.systemFont(ofSize: 14)
        return tip
    }()
    
    let avatarView: UIImageView = {
        let avatar = UIImageView()
        avatar.backgroundColor = .lightGray
        avatar.sd_setImage(with: URL(string: ProfileManager.shared.curUserModel?.avatar ?? ""), completed: nil)
        avatar.layer.cornerRadius = 2.0
        return avatar
    }()
    
    let userNameTip: UILabel = {
        let tip = UILabel()
        tip.text = "Set username"
        tip.textColor = .white
        tip.font = UIFont.systemFont(ofSize: 14)
        return tip
    }()
    
    let signButton: UIButton = {
        let sign = UIButton()
        sign.backgroundColor = .appTint
        sign.setTitle("Registered", for: .normal)
        sign.setTitleColor(.white, for: .normal)
        sign.layer.cornerRadius = 4
        return sign
    }()
           
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.view.makeToast("Please add user information for the first login")
        }
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
