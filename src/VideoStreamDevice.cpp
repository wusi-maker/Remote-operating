#include "VideoStreamDevice.h"

VideoStreamDevice *VideoStreamDevice::m_instance = nullptr;

VideoStreamDevice::VideoStreamDevice(QObject *parent)
    : QIODevice(parent)
{
    m_instance = this;
    open(QIODevice::ReadWrite);
}

VideoStreamDevice::~VideoStreamDevice()
{
    if (m_instance == this) {
        m_instance = nullptr;
    }
    close();
}

VideoStreamDevice *VideoStreamDevice::instance()
{
    return m_instance;
}

bool VideoStreamDevice::isSequential() const
{
    return true;
}

bool VideoStreamDevice::atEnd() const
{
    // 对于实时流，只要设备是打开的，就不应该认为结束
    // 只有当缓冲区为空且设备已关闭（或明确标记结束）时才返回 true
    return !isOpen() && m_buffer.isEmpty();
}

qint64 VideoStreamDevice::bytesAvailable() const
{
    if (!m_isReadyToRead) {
        return 0;
    }
    return m_buffer.size() + QIODevice::bytesAvailable();
}

void VideoStreamDevice::resetBuffer()
{
    QMutexLocker locker(&m_mutex);
    m_buffer.clear();
    m_isReadyToRead = false;
    qDebug() << "VideoStreamDevice: Reset state. Waiting for sync byte and buffering...";
}

void VideoStreamDevice::appendData(const QByteArray &data)
{
    QMutexLocker locker(&m_mutex);

    // 缓冲区限制逻辑：防止延时累积
    const int MAX_BUFFER_SIZE = 512 * 1024; 
    
    if (m_buffer.size() > MAX_BUFFER_SIZE) {
        static int dropCount = 0;
        if (++dropCount % 30 == 0 || dropCount == 1) {
            qDebug() << "VideoStreamDevice: Buffer full (" << m_buffer.size() << "bytes), clearing to reduce latency.";
        }
        m_buffer.clear();
        // Clearing buffer also resets the read readiness to ensure we realign
        m_isReadyToRead = false;
    }

    m_buffer.append(data);
    
    // Alignment and Pre-buffering Logic
    if (!m_isReadyToRead) {
        // 1. Align to MPEG-TS sync byte (0x47)
        while (!m_buffer.isEmpty() && (unsigned char)m_buffer.at(0) != 0x47) {
            m_buffer.remove(0, 1);
        }
        
        // 2. Check if we have enough data for probing
        if (m_buffer.size() >= MIN_PROBE_SIZE) {
            m_isReadyToRead = true;
            qDebug() << "VideoStreamDevice: Buffer aligned and ready. Size:" << m_buffer.size();
            emit readyRead();
        } else {
            // Not ready yet, don't emit readyRead
            // Debug occasionally
            static int waitCount = 0;
            if (++waitCount % 50 == 0) {
                qDebug() << "VideoStreamDevice: Buffering..." << m_buffer.size() << "/" << MIN_PROBE_SIZE;
            }
        }
    } else {
        // Already ready, just emit signal
        emit readyRead();
    }
    
    // 添加调试日志，每写入一定次数或字节打印一次
    static int appendCount = 0;
    if (data.size() > 0 && (++appendCount % 100 == 0 || appendCount == 1)) {
        // qDebug() << "VideoStreamDevice: Appended" << data.size() << "bytes. Total buffer:" << m_buffer.size();
    }
}

void VideoStreamDevice::attachPlayer(QObject *player)
{
    QMediaPlayer *mediaPlayer = qobject_cast<QMediaPlayer *>(player);
    if (mediaPlayer) {
        qDebug() << "VideoStreamDevice: Attaching to MediaPlayer with stream.ts hint";
        
        // Reset before attaching to ensure clean state
        resetBuffer();
        
        mediaPlayer->setSourceDevice(this, QUrl("stream.ts")); 
        mediaPlayer->play();
    } else {
        qDebug() << "VideoStreamDevice: Failed to cast object to QMediaPlayer";
    }
}

qint64 VideoStreamDevice::readData(char *data, qint64 maxlen)
{
    QMutexLocker locker(&m_mutex);
    
    if (!m_isReadyToRead) {
        return 0;
    }
    
    qint64 len = qMin((qint64)m_buffer.size(), maxlen);
    
    if (len > 0) {
        memcpy(data, m_buffer.constData(), len);
        m_buffer.remove(0, len);
    }
    
    return len;
}

qint64 VideoStreamDevice::writeData(const char *data, qint64 len)
{
    // QIODevice::write calls this. We can use it as an alternative to appendData
    appendData(QByteArray(data, len));
    return len;
}












