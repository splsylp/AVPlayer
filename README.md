# AVPlayer
#### 自定义视频播放器控件，实现多个视频(在线、本地)切换播放、半全屏切换、滑动手势调节视频进度音量亮度等功能<br>

![image](https://github.com/splsylp/AVPlayer/blob/master/AVPlayer.gif )<br>

#### 实现功能
* 多个视频(章节目录)切换播放<br>
* 通过点击全屏按钮或者自动转屏实现半全屏切换<br>
* 通过拖动滑条或者左右滑动手势调节视频进度，上下滑动手势调节音量、屏幕亮度<br>
* 解决在网速很慢的情况下加载视频导致主线程卡顿的问题
* 支持播放本地视频和在线视频<br>
* 进度条等遮罩view点击显示隐藏、定时自动隐藏<br>
* 该播放器经过项目实战检验安全可靠<br>

---

### 使用
##### 创建播放器
```Swift
playerManager = PlayerManager(playerFrame: frame, contentView: view)
playerManager.delegate = self
view.addSubview(playerManager.playerView)
```
##### 初始化播放地址
```Swift
playerManager.playUrlStr = "http://..." // 在线视频或者本地视频的路径
playerManager.seekToTime(18) // 跳转至第18秒的进度位置，从头播放则是0
playerManager.play()
```

##### 切换播放视频
```Swift
// 传入要切换的播放地址和定位的时间(秒)
playerManager.changePlayUrl("http://...", startTime: 30)
```

##### 获取播放视频的当前进度时间和总时间
```Swift
let currentTime = playerManager.getCurrentTime()
let totalTime = playerManager.getTotalTime()
```

##### 回调方法
```Swift
// 返回
func playerViewBack() {
    navigationController?.popViewController(animated: true)
}

// 播放完成(可选)
func playFinished() {
    print("播放完了😁")
}

// 分享(可选) 不需要分享需求的可以把分享按钮hidden掉
func playerViewShare() {
    print("处理分享逻辑")
}
```

