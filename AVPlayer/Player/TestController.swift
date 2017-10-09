//
//  VideoController.swift
//  AVPlayer
//
//  Created by Tony on 2017/7/20.
//  Copyright © 2017年 Tony. All rights reserved.
//

import UIKit
import CoreMedia

class TestController: UIViewController, PlayerManagerDelegate {
    
    var playerManager: PlayerManager!
    
    lazy var videoBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor.blue
        btn.tag = 1
        btn.setTitle("视频一", for: .normal)
        btn.addTarget(self, action: #selector(changeVideo(btn:)), for: .touchUpInside)
        btn.frame = CGRect(x: 0, y: self.playerManager.playerView.bottom + 50, width: 100, height: 30)
        btn.centerX = self.view.centerX
        return btn
    }()
    
    lazy var videoBtn2: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor.blue
        btn.tag = 2
        btn.setTitle("视频二", for: .normal)
        btn.addTarget(self, action: #selector(changeVideo(btn:)), for: .touchUpInside)
        btn.frame = CGRect(x: 0, y: self.videoBtn.bottom + 50, width: 100, height: 30)
        btn.centerX = self.view.centerX
        return btn
    }()
    
    lazy var videoBtn3: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor.red
        btn.tag = 3
        btn.setTitle("无效路径视频", for: .normal)
        btn.addTarget(self, action: #selector(changeVideo(btn:)), for: .touchUpInside)
        btn.frame = CGRect(x: 0, y: self.videoBtn2.bottom + 50, width: 200, height: 30)
        btn.centerX = self.view.centerX
        return btn
    }()
    
    lazy var jumpBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor.red
        btn.setTitle("跳转控制器", for: .normal)
        btn.addTarget(self, action: #selector(jumpToViewController), for: .touchUpInside)
        btn.frame = CGRect(x: 0, y: self.videoBtn3.bottom + 100, width: 200, height: 30)
        btn.centerX = self.view.centerX
        return btn
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        // 添加视频播放器
        playerManager = PlayerManager(playerFrame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 210), contentView: self.view)
        view.addSubview(playerManager.playerView)
        
        // 添加视频切换按钮
        view.addSubview(videoBtn)
        view.addSubview(videoBtn2)
        view.addSubview(videoBtn3)
        view.addSubview(jumpBtn)
        
        playerManager.delegate = self
        playerManager.playUrlStr = "http://baobab.wdjcdn.com/1456665467509qingshu.mp4"
        playerManager.seekToTime(0)// 跳转至第N秒的进度位置，从头播放则是0
        playerManager.play()
    }
    
    // 切换播放视频
    func changeVideo(btn: UIButton) {
        
        let urlStr: String
        let startTime: Int
        if btn.tag == 1 {
            urlStr = "http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"
            startTime = 35
        } else if btn.tag == 2 {
            urlStr = "http://baobab.wdjcdn.com/1457162012752491010143.mp4"
            startTime = 15
        } else {
            urlStr = "htt"
            startTime = 0
        }
        // 传入要切换的播放地址和定位的时间(秒)
        playerManager.changePlayUrl(urlStr, startTime: startTime)
    }
    
    func test() {
        // 获取播放视频的当前进度时间和总时间
        let currentTime = playerManager.getCurrentTime()
        let totalTime = playerManager.getTotalTime()
        print(currentTime, totalTime)
    }
    
    // push跳转
    func jumpToViewController() {
        
        playerManager.pause()
        navigationController?.pushViewController(ViewController(), animated: true)
    }
    
    
    // MARK:- PlayerManagerDelegate
    // 返回按钮点击回调
    func playerViewBack() {
        navigationController?.popViewController(animated: true)
    }
    
    // 分享按钮点击回调
    func playerViewShare() {
        print("处理分享逻辑")
    }
    
    // 播放完成回调
    func playFinished() {
        print("播放完了😁")
    }
}
