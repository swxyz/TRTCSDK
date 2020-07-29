//
//  TRTCVoiceRoomListViewModel.swift
//  TRTCVoiceRoomDemo
//
//  Created by abyyxwang on 2020/6/12.
//  Copyright © 2020 tencent. All rights reserved.
//

import UIKit

protocol TRTCVoiceRoomListViewResponder: class {
    func showToast(message: String)
    func refreshList()
    func stopListRefreshing()
    func showLoading(message: String)
    func hideLoading()
    func pushRoomView(viewController: UIViewController)
}

class TRTCVoiceRoomListViewModel {
    private let dependencyContainer: TRTCVoiceRoomDependencyContainer
    weak var viewResponder: TRTCVoiceRoomListViewResponder?
    
    private var voiceRoomManager: TRTCVoiceRoomManager {
        return TRTCVoiceRoomManager.shared
    }
    
    private var voiceRoom: TRTCVoiceRoomImp {
        return dependencyContainer.getVoiceRoom()
    }
    // 视图相关属性
    private(set) var roomList: [VoiceRoomInfo] = []
    
    /// 初始化方法
    /// - Parameter container: 依赖管理容器，负责VoiceRoom模块的依赖管理
    init(container: TRTCVoiceRoomDependencyContainer) {
        self.dependencyContainer = container
    }
    
    func makeCreateViewController() -> UIViewController {
        return dependencyContainer.meakCreateVoiceRoomViewController()
    }
    
    @objc
    func getRoomList() {
        guard voiceRoom.mSDKAppID != 0 else {
            viewResponder?.showToast(message: "APPID 不正确")
            return
        }
        voiceRoomManager.getRoomList(sdkAppID: voiceRoom.mSDKAppID, success: { [weak self] (roomIds: [String]) in
            guard let `self` = self else { return }
            let roomIdsInt = roomIds.compactMap {
                Int($0)
            }
            if roomIdsInt.count == 0 {
                self.viewResponder?.showToast(message: "当前暂无内容哦~")
            }
            self.voiceRoom.getRoomInfoList(roomIdList: roomIdsInt) { (code, message, roomInfos: [VoiceRoomInfo]) in
                self.viewResponder?.stopListRefreshing()
                if code == 0 {
                    if roomInfos.count == 0 {
                        self.viewResponder?.showToast(message: "当前暂无内容哦")
                    }
                    self.roomList = roomInfos
                    self.viewResponder?.refreshList()
                } else {
                    TRTCLog.out("get room list failed. code\(code), message:\(message)")
                    self.viewResponder?.showToast(message: "获取房间列表失败")
                }
            }
        }) { [weak self] (code, message) in
            guard let `self` = self else { return }
            TRTCLog.out("error: get room list fail. code: \(code), message:\(message)")
            self.viewResponder?.showToast(message: "获取列表失败")
        }
    }
    
    func clickRoomItem(index: Int) {
        let roomInfo = self.roomList[index]
        if voiceRoom.userId == roomInfo.ownerId {
            // 开始进入已经存在的房间
            startEnterExistRoom(info: roomInfo)
        } else {
            // 正常进房逻辑
            enterRoom(info: roomInfo)
        }
    }
    
    func startEnterExistRoom(info: VoiceRoomInfo) {
        // 以主播方式进房
        let vc = self.dependencyContainer.makeVoiceRoomViewController(roomInfo: info, role: .anchor)
        self.viewResponder?.pushRoomView(viewController: vc)
    }
    
    func enterRoom(info: VoiceRoomInfo) {
        let vc = self.dependencyContainer.makeVoiceRoomViewController(roomInfo: info, role: .audience)
        self.viewResponder?.pushRoomView(viewController: vc)
    }
}
