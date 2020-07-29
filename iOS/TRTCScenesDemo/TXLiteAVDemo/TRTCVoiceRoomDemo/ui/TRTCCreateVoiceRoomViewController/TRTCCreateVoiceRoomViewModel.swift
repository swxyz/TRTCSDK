//
//  TRTCCreateVoiceRoomViewModel.swift
//  TRTCVoiceRoomDemo
//
//  Created by abyyxwang on 2020/6/8.
//  Copyright © 2020 tencent. All rights reserved.
//

import UIKit

enum VoiceRoomRole {
    case anchor // 主播
    case audience // 观众
}

enum VoiceRoomToneQuality {
    case music
    case defaultQuality
    case speech
}

protocol TRTCCreateVoiceRoomViewResponder: class {
    func push(viewController: UIViewController)
}

class TRTCCreateVoiceRoomViewModel {
    private let dependencyContainer: TRTCVoiceRoomDependencyContainer
    
    weak var viewResponder: TRTCCreateVoiceRoomViewResponder?
    
    var voiceRoom: TRTCVoiceRoomImp {
        return dependencyContainer.getVoiceRoom()
    }
    
    var roomName: String = ""
    var userName: String = ""
    var needRequest: Bool = true
    var toneQuality: VoiceRoomToneQuality = .music
    
    /// 初始化方法
    /// - Parameter container: 依赖管理容器，负责VoiceRoom模块的依赖管理
    init(container: TRTCVoiceRoomDependencyContainer) {
        self.dependencyContainer = container
    }
    
    func createRoom() {
        let userId = ProfileManager.shared.curUserID() ?? voiceRoom.userId
        let coverAvatar = ProfileManager.shared.curUserModel?.avatar ?? ""
        let roomId = getRoomId()
        let roomInfo = VoiceRoomInfo.init(roomID: roomId, ownerId: userId, memberCount: 7)
        roomInfo.ownerName = userName
        roomInfo.coverUrl = coverAvatar
        roomInfo.roomName = roomName
        roomInfo.needRequest = needRequest
        let vc = self.dependencyContainer.makeVoiceRoomViewController(roomInfo:roomInfo, role: .anchor)
        viewResponder?.push(viewController: vc)
    }
    
    func getRoomId() -> Int {
        let userId = ProfileManager.shared.curUserID() ?? voiceRoom.userId
        let result = "\(userId)_voice_room".hash & 0x7FFFFFFF
        TRTCLog.out("hashValue:room id:\(result), userId: \(userId)")
        return result
    }
}
