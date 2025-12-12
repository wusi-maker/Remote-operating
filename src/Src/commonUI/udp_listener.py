#!/usr/bin/env python
import rospy
import os
import cv2
import time
import subprocess
import numpy as np
import threading
from sensor_msgs.msg import Image
from cv_bridge import CvBridge

class ROSVideoStreamer:
    def __init__(self):
        # 初始化ROS节点
        rospy.init_node('camera_streamer', anonymous=True)
        
        # 从参数服务器获取配置
        self.device_index = rospy.get_param('~camera_index', default=2)
        # 直接往QT服务器端发送数据，无需经过服务器的中转站
        # self.server_ip = rospy.get_param('~server_ip', default='39.170.2.242')
        # 优先读取ROS参数，其次读取环境变量，最后使用默认值
        self.server_ip = rospy.get_param('~server_ip', os.environ.get('VIDEO_SERVER_IP', '120.26.31.3'))
        self.udp_port = rospy.get_param('~udp_port', int(os.environ.get('VIDEO_UDP_PORT', '9999')))
        self.target_fps = rospy.get_param('~fps', default=30)
        
        # 初始化摄像头
        self.cap = self._init_camera()
        self.bridge = CvBridge()
        
        # 初始化编码器
        self.encoder = FFmpegEncoder(
            width=int(self.cap.get(cv2.CAP_PROP_FRAME_WIDTH)),
            height=int(self.cap.get(cv2.CAP_PROP_FRAME_HEIGHT)),
            fps=self.target_fps,
            server_ip=self.server_ip,
            udp_port=self.udp_port
        )
        
        # 用于计算带宽统计信息
        self.last_frame_time = time.time()

        # 创建定时器
        self.timer = rospy.Timer(rospy.Duration(1.0/self.target_fps), self.capture_callback)

    def show_preview(self, frame, fps, pre_bw, post_bw, show_falg=True):
        """显示带统计信息的预览画面，并处理退出事件"""
        info_frame = frame.copy()
        # 叠加信息（与原main中的逻辑一致）
        cv2.putText(info_frame, f"FPS: {fps}", (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 1, (0,255,0), 2)
        cv2.putText(info_frame, f"Pre-BW: {pre_bw:.1f}Mbps", (10, 70), cv2.FONT_HERSHEY_SIMPLEX, 1, (0,255,0), 2)
        cv2.putText(info_frame, f"Post-BW: {post_bw:.1f}Mbps", (10, 110), cv2.FONT_HERSHEY_SIMPLEX, 1, (0,255,0), 2)
        # 显示并检测退出按键
        if show_falg:
            cv2.imshow('Preview', info_frame)
            cv2.waitKey(1) # 保持界面刷新

    def _init_camera(self):
        """初始化摄像头设备"""
        device_path = f"/dev/video{self.device_index}"
        if not os.path.exists(device_path):
            rospy.logwarn(f"Camera device {device_path} not found, trying available cameras...")
            # 尝试使用可用摄像头列表中的第一个
            available = ROSVideoStreamer.get_available_cameras()
            if available:
                fallback_path = available[0]
                rospy.loginfo(f"Fallback to camera {fallback_path}")
                self.device_index = int(fallback_path.replace('/dev/video', ''))
            else:
                rospy.logerr(f"No available camera devices found")
                raise RuntimeError("Camera device not available")
        
        cap = cv2.VideoCapture(device_path)
        if not cap.isOpened():
            rospy.logerr("Failed to open camera")
            raise RuntimeError("Camera open failed")
            
        return cap
    @staticmethod
    def get_available_cameras():
        available_cameras = []
        max_index = 10  # 最多尝试 10 个设备号
        for index in range(max_index):
            device_path = f"/dev/video{index}"
            if os.path.exists(device_path):
                cap = cv2.VideoCapture(device_path)
                if cap.isOpened():
                    ret, _ = cap.read()
                    if ret:
                        available_cameras.append(device_path)
                    cap.release()
        return available_cameras
    def capture_callback(self, event):
        """定时捕获回调函数"""
        ret, frame = self.cap.read()
        if not ret:
            rospy.logwarn("Failed to capture frame")
            return
            
        # 计算统计信息
        current_time = time.time()
        fps = int(1.0 / (current_time - self.last_frame_time)) if (current_time - self.last_frame_time) > 0 else self.target_fps
        self.last_frame_time = current_time
        
        h, w = frame.shape[:2]
        pre_bw = (h * w * fps * 3 * 8) / 1e6
        post_bw = (pre_bw / self.encoder.compression_ratio) * self.encoder.redundancy_factor
        if False:
            # 显示预览
            self.show_preview(frame, fps, pre_bw, post_bw)

        # 编码并发送帧
        self.encoder.encode_frame(frame)
        
        # 可选：发布ROS图像话题
        # img_msg = self.bridge.cv2_to_imgmsg(frame, "bgr8")
        # self.image_pub.publish(img_msg)

    def shutdown_hook(self):
        """节点关闭时的清理操作"""
        self.cap.release()
        self.encoder.close()
        cv2.destroyAllWindows()

class FFmpegEncoder:
    # 保持原有FFmpegEncoder类不变，增加server_ip参数
    def __init__(self, width, height, fps=30, server_ip='192.168.1.100', udp_port=9999,compression_ratio=100, redundancy_factor=1.1):
        self.server_ip = server_ip
        self.udp_port = udp_port
        self.width = width
        self.height = height
        self.fps = fps
        self.compression_ratio = compression_ratio  # 添加缺失的属性
        self.redundancy_factor = redundancy_factor  # 添加缺失的属性
        self.process = None
        self.error_thread = None

        self.restart_count = 0
        self._start_ffmpeg()

        
# ... 在 FFmpegEncoder 类中 ...

    def _start_ffmpeg(self):
        # 计算适合局域网的码率，例如 2Mbps
        bitrate = "2M" 
        
        command = [
            'ffmpeg',
            '-y', # 覆盖输出
            '-f', 'rawvideo',
            '-pix_fmt', 'bgr24',
            '-s', f'{self.width}x{self.height}',
            '-r', str(self.fps),
            '-i', '-',
            
            '-c:v', 'libx264',
            '-pix_fmt', 'yuv420p',
            '-preset', 'ultrafast',
            '-tune', 'zerolatency',
            
            # === 关键优化开始 ===
            '-g', '15',           # 【关键】GOP长度。设置为 FPS/2，即每0.5秒强制一个关键帧。丢包后0.5秒内恢复。
            '-keyint_min', '15',  # 最小关键帧间隔
            '-b:v', bitrate,      # 【关键】平均码率限制
            '-maxrate', '2.5M',   # 【关键】最大码率，防止突发流量堵塞网络
            '-bufsize', '1M',     # 编码器缓冲区
            # === 关键优化结束 ===

            '-f', 'mpegts',
            # mpegts 能够更好地从流中间恢复，但需要调整包大小以适应 MTU
            f'udp://{self.server_ip}:{self.udp_port}?pkt_size=1316' 
        ]
        
        # ... (后续代码保持不变
        if self.process and self.process.poll() is None:
            self.process.kill()
            
        self.process = subprocess.Popen(
            command,
            stdin=subprocess.PIPE,
            stderr=subprocess.PIPE,
            bufsize=0
        )
        
        # 启动错误监控线程
        self.error_thread = threading.Thread(target=self._monitor_stderr, daemon=True)
        self.error_thread.start()

    def _monitor_stderr(self):
        """监控FFmpeg错误输出"""
        while True:
            line = self.process.stderr.readline()
            if not line:
                if self.process.poll() is not None:
                    print("FFmpeg进程异常退出，尝试重启...")
                    self._handle_crash()
                time.sleep(0.1)
                continue
            # print(f"[FFmpeg] {line.decode().strip()}")
    def _handle_crash(self):
        """处理进程崩溃"""
        self.restart_count += 1
        if self.restart_count > 3:
            print("连续重启失败，终止程序")
            try:
                rospy.signal_shutdown("FFmpeg repeated crash")
            except Exception:
                os._exit(1)
        self._start_ffmpeg()


    def encode_frame(self, frame):
        try:
            if self.process.poll() is None:
                self.process.stdin.write(frame.tobytes())
                self.process.stdin.flush()
            else:
                print("FFmpeg进程已终止，尝试重启...")
                self._start_ffmpeg()
                self.process.stdin.write(frame.tobytes())
        except Exception as e:
            print(f"编码失败: {str(e)}")
            # self._start_ffmpeg()
            self._handle_crash()

    def close(self):
        if self.process and self.process.poll() is None:
            self.process.stdin.close()
            self.process.terminate()
            self.process.wait()


if __name__ == '__main__':
    try:
        streamer = ROSVideoStreamer()
        rospy.loginfo(f"Video target: udp://{streamer.server_ip}:{streamer.udp_port} at {streamer.target_fps} FPS")
        rospy.on_shutdown(streamer.shutdown_hook)
        rospy.spin()
    except rospy.ROSInterruptException:
        pass