//
//  PlayerManager.swift
//  AVPlayer
//
//  Created by Tony on 2017/7/20.
//  Copyright © 2017年 Tony. All rights reserved.
//

import UIKit
import CoreMedia
import AVFoundation

protocol PlayerManagerDelegate: class {
    
    func playerViewBack() // 返回
    func playerViewShare() // 分享
    func playFinished() // 播放完成
}

extension PlayerManagerDelegate {
    
    func playerViewShare() {} // 分享
    func playFinished() {} // 播放完成
}

enum ErrorType { // 异常错误类型
    case playUrlNull // 播放地址为空
}

class PlayerManager: NSObject, PlayerViewDelegate {
    
    // MARK:- 属性
    public var playerView: PlayerView!
    
    public var playerViewFrame: CGRect = CGRect.zero {
        didSet{
            initPlayerView(playerFrame: playerViewFrame)
        }
    }
    public var playUrlStr: String? {
        didSet{
            initPlayerURL()
        }
    }
    public var isAutoFull = true // 横屏时是否自动全屏
    public weak var delegate: PlayerManagerDelegate?
    
    // MARK: 控件变量属性
    private var playbackTimeObserver: NSObject?
    fileprivate var timeContext: Void?
    fileprivate var statusContext: Void?
    
    
    // MARK:- 初始化方法
    override init() {
        super.init()
        playerView = PlayerView()
    }
    
    init(playerFrame: CGRect) {
        super.init()
        playerView = PlayerView()
        initPlayerView(playerFrame: playerFrame)
    }
    
    // 初始化播放器控件
    private func initPlayerView(playerFrame: CGRect) {
        
        playerView.initFrame(playerFrame)
        playerView.delegate = self
        
        //计时器，循环执行(在视频暂停以及进入后台时会自动停止，恢复后自动开始)
        playbackTimeObserver = playerView.player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1.0, Int32(NSEC_PER_SEC)), queue: DispatchQueue.main) { [weak self] (time) in
            self?.refreshTimeObserve()
            } as? NSObject
        
        // 进入后台通知
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        // 播放完成通知
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayDidEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        // 注册屏幕旋转通知
        NotificationCenter.default.addObserver(self, selector: #selector(statusBarOrientationChange(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: UIDevice.current)
    }
    
    
    // 初始化播放地址
    private func initPlayerURL() {
        
        //视频音频设置
        do {
            _ = try
                AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: AVAudioSessionCategoryOptions.mixWithOthers)
        } catch {
            print("音视频设置捕获异常！！！！！！！")
        }
        
        self.playerView.originalScreen() // 绘制控件视图
        
        // 苹果推荐初始化方法
        DispatchQueue.global().async {
            let asset = self.getAVURLAsset(urlStr: self.playUrlStr ?? "")
            if asset.duration.seconds == 0 {
                print("无效的路径或者网络异常")
                DispatchQueue.main.async {
                    self.playerView.invalidPlayURL() // 刷新无效播放地址视图状态
                }
                return
            }
            self.playerView.playerItem = AVPlayerItem(asset: asset)
            self.playerView.playerLayer = AVPlayerLayer(player: self.playerView.player)
            self.playerView.player.replaceCurrentItem(with: self.playerView.playerItem)
            
            // 监听缓存进度和状态
            self.playerView.playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.new, context: &self.timeContext)
            self.playerView.playerItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: &self.statusContext)
            
            DispatchQueue.main.async {
                self.playerView.originalScreen()
                self.playerView.startLoadingAnimation()
            }
        }
    }
    
    // 转换url
    fileprivate func getAVURLAsset(urlStr: String) -> AVURLAsset {
        
        let url: URL?
        // 确保转成url后不会为nil
        let encodeStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? "invalidURLStr"
        if encodeStr.contains("http") == true { // 在线视频
            url = URL(string: encodeStr)
        } else {// 本地视频
            url = URL(fileURLWithPath: encodeStr)
        }
        return AVURLAsset(url: url!)
    }
    
    deinit {
        playerView.playerItem?.removeObserver(self, forKeyPath: "status")
        playerView.playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        playerView.player.replaceCurrentItem(with: nil)
        playerView.player.currentItem?.cancelPendingSeeks()
        playerView.player.currentItem?.asset.cancelLoading()
        if playbackTimeObserver != nil {
            //添加异常判断
            playerView.player.removeTimeObserver(playbackTimeObserver!)
        }
        NotificationCenter.default.removeObserver(self)
    }
}


extension PlayerManager {// MARK: 外部调用方法
    
    // 播放
    func play() {
        
        playerView.playVideo()
    }
    
    // 暂停
    func pause() {
        
        playerView.pauseVideo()
    }
    
    // 切换播放地址
    func changePlayUrl(_ urlStr: String, startTime: Int) {
        
        playerView.player.replaceCurrentItem(with: nil)
        playerView.originalScreen()
        playerView.startLoadingAnimation()
        
        DispatchQueue.global().async {
            let asset = self.getAVURLAsset(urlStr: urlStr)
            if asset.duration.seconds == 0 {
                print("无效的路径或者网络异常")
                DispatchQueue.main.async {
                    self.playerView.invalidPlayURL() // 刷新无效播放地址视图状态
                }
                return
            }
            
            self.playerView.playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
            self.playerView.playerItem?.removeObserver(self, forKeyPath: "status")
            self.playerView.playerItem = AVPlayerItem(asset: asset)
            self.playerView.playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.new, context: &self.timeContext)
            self.playerView.playerItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: &self.statusContext)
            self.playerView.player.replaceCurrentItem(with: self.playerView.playerItem)
            
            DispatchQueue.main.async {
                self.playerView.playerLayer = AVPlayerLayer(player: self.playerView.player)
                self.playerView.originalScreen()
                self.playerView.startLoadingAnimation()
                self.playerView.seekToVideo(startTime)
                self.play()
            }
        }
    }
    
    // 调整视频进度
    func seekToTime(_ startTime: Int) {
        
        playerView.seekToVideo(startTime)
    }
    
    // 获取当前时间
    func getCurrentTime() -> Int {
        return playerView.currentTime
    }
    
    // 获取总时间
    func getTotalTime() -> Int {
        return playerView.totalTime
    }
}


extension PlayerManager {
    
    // MARK:- PlayerView代理方法
    // 返回按钮点击代理
    func videoViewBackButtonClicked() {
        
        delegate?.playerViewBack()
    }
    
    //右侧分享按钮
    func shareBtnClicked() {
        
        delegate?.playerViewShare()
    }
}


extension PlayerManager {
    
    // MARK: 监听
    // 定时刷新监听
    func refreshTimeObserve() {
        
        playerView.refreshShowValues()
    }
    
    // 缓存条、视频加载状态监听
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if context == &timeContext {
            // 刷新缓冲条进度
            playerView.setProgressValue()
            
        } else if context == &statusContext {
            if playerView.player.status == AVPlayerStatus.readyToPlay {
                // 根据时间重新调整时间frame值
                playerView.resizeTimeLabel()
                playerView.stopLoadingAnimation()
                
            } else if playerView.player.status == AVPlayerStatus.unknown {
                playerView.startLoadingAnimation()
                
            } else if playerView.player.status == AVPlayerStatus.failed {
                playerView.stopLoadingAnimation()
            }
        }
    }
    
    
    // MARK: 通知
    // 进入后台通知
    @objc fileprivate func appDidEnterBackground(_ notification: Notification) {
        
        pause()
    }
    
    // 播放完成通知
    @objc fileprivate func moviePlayDidEnd(_ notification: Notification) {
        
        playerView.showToolBar()
        playerView.startToolBarTimer()
        pause()
        
        delegate?.playFinished()
    }
    
    
    // MARK: 转屏
    // 屏幕旋转
    @objc fileprivate func statusBarOrientationChange(_ notification: Notification) {
        
        if isAutoFull == false {
            return
        }
        let orientation = UIDevice.current.orientation
        if orientation == UIDeviceOrientation.landscapeLeft {
            playerView.fullScreenWithDirection(.left)
        } else if orientation == UIDeviceOrientation.landscapeRight {
            playerView.fullScreenWithDirection(.right)
        } else if orientation == UIDeviceOrientation.portrait {
            playerView.originalScreen()
        }
    }
}
