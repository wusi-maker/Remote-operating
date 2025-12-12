import QtQuick
import QtMultimedia
import "../style" // Assuming Theme is here or globally available? 
// In LayoutRight.qml it uses Theme.labledBackColor. 
// But Local_AreaVideo.qml is in commonUI. 
// LayoutRight.qml imports "../style".
// I should probably import "../style" as well if I use Theme.
// But the old code used hardcoded colors "#1a1a1a" and "#333".

Rectangle {
    id: root
    width: 400 // Default size, will be overridden by layout
    height: 300
    color: "#1a1a1a"
    border.color: "#333"
    border.width: 2
    radius: 8

    // 外部控制属性
    property bool isPlaying: true
    property bool isRecording: false
    property bool shouldShow: true // 控制是否显示视频内容（用于车辆ID判断）

    // 外部调用方法
    function playStream() {
        isPlaying = true
        // 强制重置 source 以清空底层 UDP/Socket 缓冲区
        var currentSource = mediaPlayer.source
        mediaPlayer.source = ""
        mediaPlayer.source = currentSource
        mediaPlayer.play()
    }

    function pauseStream() {
        isPlaying = false
        mediaPlayer.stop() // UDP流通常用stop代替pause
    }

    function toggleRecording() {
        isRecording = !isRecording
        // 这里后续可以添加实际的录制逻辑
        console.log("Recording toggled:", isRecording)
    }

    MediaPlayer {
        id: mediaPlayer
        // 使用 0.0.0.0 显式绑定所有网卡
        // === 关键优化参数 ===
        // heavy options:
        // fflags=nobuffer: 直接输出，不缓冲
        // flags=low_delay: 告诉解码器这是低延迟流
        // strict=experimental: 允许某些实验性优化
        // probesize=32: 减少探测流信息所需的数据量，加快首帧显示
        // analyzeduration=0: 不花时间分析流时长
        // overrun_nonfatal=1: 缓冲区满时不报错（继续播放新数据）
        // buffer_size=2000000: 增加UDP Socket接收缓冲区到2MB，减少系统级overrun报错
        // probesize=100000 & analyzeduration=100000: 限制探测数据量和时长(约100ms)，加快起播速度，同时避免因太小导致的I/O Error
        source: "udp://0.0.0.0:9999?fifo_size=256000&overrun_nonfatal=1&buffer_size=2000000&fflags=nobuffer&flags=low_delay&probesize=100000&analyzeduration=100000"
        // source: "udp://0.0.0.0:9999?fifo_size=256000&overrun_nonfatal=1"
        videoOutput: videoOutput
        
        // 当 shouldShow 为 false 时停止播放以节省资源，或者仅隐藏
        // 这里选择停止播放，避免后台持续解码
        onSourceChanged: {
             if (shouldShow && isPlaying) {
                 play()
             }
        }
        
        onPlaybackStateChanged: (playbackState) => {
            if (playbackState === MediaPlayer.PlayingState) {
                console.log("Local_AreaVideo: Playing")
                statusText.visible = false
            } else if (playbackState === MediaPlayer.StoppedState) {
                console.log("Local_AreaVideo: Stopped")
                statusText.text = "Stream Stopped"
                statusText.visible = true
            } else if (playbackState === MediaPlayer.PausedState) {
                 console.log("Local_AreaVideo: Paused")
            }
        }

        onErrorOccurred: (error, errorString) => {
            console.log("Local_AreaVideo Error:", errorString)
            statusText.text = "Error: " + errorString
            statusText.visible = true
            retryTimer.start()
        }

        Component.onCompleted: {
            console.log("Local_AreaVideo: Component loaded, starting playback...")
            if (shouldShow && isPlaying) {
                play()
            }
        }
    }

    // 监听 shouldShow 和 isPlaying 变化
    onShouldShowChanged: updatePlayback()
    onIsPlayingChanged: updatePlayback()

    function updatePlayback() {
        if (shouldShow && isPlaying) {
            mediaPlayer.play()
        } else {
            mediaPlayer.stop()
        }
    }

    VideoOutput {
        id: videoOutput
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectFit
        visible: root.shouldShow // 如果不显示，直接隐藏 VideoOutput，显示黑色背景
    }

    Text {
        id: statusText
        anchors.centerIn: parent
        text: root.shouldShow ? "Waiting for stream..." : "No Signal"
        color: "#888888"
        font.pixelSize: 14
        visible: (mediaPlayer.playbackState !== MediaPlayer.PlayingState) || !root.shouldShow
    }

    Timer {
        id: retryTimer
        interval: 2000
        repeat: false
        onTriggered: {
            console.log("Local_AreaVideo: Retrying connection...")
            mediaPlayer.stop()
            mediaPlayer.play()
        }
    }
    
    // Gradient background as in original
    gradient: Gradient {
        GradientStop { position: 0.0; color: "#1a1a1a" }
        GradientStop { position: 1.0; color: "#0d0d0d" }
    }
}

