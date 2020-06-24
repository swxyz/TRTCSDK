//
//  AudioCallMainViewController.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 12/23/19.
//  Copyright © 2019 xcoderliu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum AudioUserRemoveReason: UInt32 {
    case leave = 0
    case reject
    case noresp
    case busy
}

class AudioCallMainViewController: UIViewController, TRTCAudioCallDelegate {
    let disposebag = DisposeBag()
    var callVC: AudioCallViewController? = nil
    
    lazy var noHistoryView: UIView = {
        let noHistory = UIView()
        noHistory.backgroundColor = .appBackGround
        return noHistory
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    deinit {
    }
    
    func onError(code: Int32, msg: String?) {
        debugPrint("� onError: code \(code), msg: \(String(describing: msg))")
    }
    
    func onInvited(sponsor: String, userIds: [String], isFromGroup: Bool) {
        debugPrint("📳 onInvited sponsor:\(sponsor) userIds:\(userIds)")
        ProfileManager.shared.queryUserInfo(userID: sponsor, success: { [weak self] (user) in
            guard let self = self else {return}
            ProfileManager.shared.queryUserListInfo(userIDs: userIds, success: { (usermodels) in
                var list:[AudioCallUserModel] = []
                for UserModel in usermodels {
                    list.append(self.covertUser(user: UserModel))
                }
                self.showCallVC(invitedList: list, sponsor: self.covertUser(user: user, isEnter: true))
            }) { (error) in
                
            }
        }) { (error) in
            
        }
    }
    
    func onGroupCallInviteeListUpdate(userIds: [String]) {
        debugPrint("📳 onGroupCallInviteeListUpdate userIds:\(userIds)")
    }
    
    func onUserEnter(uid: String) {
        debugPrint("📳 onUserEnter: \(uid)")
        if let vc = callVC {
            ProfileManager.shared.queryUserInfo(userID: uid, success: { [weak self, weak vc] (UserModel) in
                guard let self = self else {return}
                vc?.enterUser(user: self.covertUser(user: UserModel, isEnter: true))
                vc?.view.makeToast("\(UserModel.name) Enter the call")
            }) { (error) in
                
            }
        }
    }
    
    func onUserLeave(uid: String) {
        debugPrint("📳 onUserLeave: \(uid)")
        removeUserFromCallVC(uid: uid, reason: .leave)
    }
    
    func onReject(uid: String) {
        debugPrint("📳 onReject: \(uid)")
        removeUserFromCallVC(uid: uid, reason: .reject)
    }
    
    func onNoResp(uid: String) {
        debugPrint("📳 onNoResp: \(uid)")
        removeUserFromCallVC(uid: uid, reason: .noresp)
    }
    
    func onLineBusy(uid: String) {
        debugPrint("📳 onLineBusy: \(uid)")
        removeUserFromCallVC(uid: uid, reason: .busy)
    }
    
    func onCallingCancel() {
        debugPrint("📳 onCallingCancel")
        if let vc = callVC {
            view.makeToast("\((vc.curSponsor?.name) ?? "")通话取消")
            vc.disMiss()
        }
    }
    
    func onCallingTimeOut() {
        debugPrint("📳 onCallingTimeOut")
        if let vc = callVC {
            view.makeToast("Call timeout")
            vc.disMiss()
        }
    }
    
    func onCallEnd() {
        debugPrint("📳 onCallEnd")
        if let vc = callVC {
            vc.disMiss()
        }
    }
    
    func onUserAudioAvailable(uid: String, available: Bool) {
        debugPrint("📳 onUserAudioAvailable , uid: \(uid), available: \(available)")
    }
    
    func onUserVoiceVolume(uid: String, volume: UInt32) {
        if let vc = callVC {
            if let user = vc.getUserById(userId: uid) {
                var newUser = user
                newUser.volume = Float(volume) / 100
                vc.updateUser(user: newUser)
            } else {
                ProfileManager.shared.queryUserInfo(userID: uid, success: { (UserModel) in
                    vc.enterUser(user: self.covertUser(user: UserModel, volume: volume, isEnter: true))
                }) { (error) in
                    
                }
            }
        }
    }
    
    func covertUser(user: UserModel,
                    volume: UInt32 = 0,
                    isEnter: Bool = false) -> AudioCallUserModel {
        var dstUser = AudioCallUserModel()
        dstUser.name = user.name
        dstUser.avatarUrl = user.avatar
        dstUser.userId = user.userId
        dstUser.isEnter = isEnter
        dstUser.volume = Float(volume) / 100
        return dstUser
    }
    
    func removeUserFromCallVC(uid: String, reason: AudioUserRemoveReason = .noresp) {
        if let vc = callVC {
            ProfileManager.shared.queryUserInfo(userID: uid, success: { [weak self, weak vc] (UserModel) in
                guard let self = self else {return}
                let userInfo = self.covertUser(user: UserModel)
                vc?.leaveUser(user: userInfo)
                var toast = "\(userInfo.name)"
                switch reason {
                case .reject:
                    toast += "Rejected the call"
                    break
                case .leave:
                    toast += "Leave the call"
                    break
                case .noresp:
                    toast += "Not responding"
                    break
                case .busy:
                    toast += "Busy Line"
                    break
                }
                vc?.view.makeToast(toast)
                self.view.makeToast(toast)
            }) { (error) in
                
            }
        }
    }
}
