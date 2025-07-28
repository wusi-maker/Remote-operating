#include "ffmpegdecoder.h"
#include <QDebug>

FFmpegDecoder::FFmpegDecoder(int port, QObject *parent)
    : QObject(parent), m_port(port)
{
    m_process = new QProcess(this);
    connect(m_process, &QProcess::readyReadStandardOutput,
            this, &FFmpegDecoder::onProcessOutput);
}

FFmpegDecoder::~FFmpegDecoder()
{
    stop();
}

void FFmpegDecoder::start()
{
    QStringList args = {
        "-flags", "low_delay",        // 低延迟模式
        "-fflags", "nobuffer",        // 禁用缓冲
        "-i", QString("udp://0.0.0.0:%1").arg(m_port),
        "-f", "rawvideo",
        "-pix_fmt", "bgr24",
        "-"
    };
    m_process->start("ffmpeg", args);
}

void FFmpegDecoder::stop()
{
    if(m_process->state() == QProcess::Running){
        m_process->terminate();
        m_process->waitForFinished(3000);
    }
}

void FFmpegDecoder::onProcessOutput()
{
    QMutexLocker locker(&m_mutex);

    // 追加新数据
    m_buffer.append(m_process->readAllStandardOutput());

    // 自动检测分辨率（示例值，需根据实际情况调整）
    if (m_frameSize.isEmpty()) {
        m_frameSize = QSize(1280, 720);
    }

    const int frameBytes = m_frameSize.width() * m_frameSize.height() * 3;
    const int maxBufferSize = MAX_FRAMES * frameBytes;

    // 关键修改：丢弃旧数据，只保留最新30帧的原始数据
    if (m_buffer.size() > maxBufferSize) {
        m_buffer = m_buffer.right(maxBufferSize);
    }

    // 处理所有完整帧
    while (m_buffer.size() >= frameBytes) {
        QByteArray frameData = m_buffer.left(frameBytes);
        m_buffer.remove(0, frameBytes);

        QImage image(
            (const uchar*)frameData.constData(),
            m_frameSize.width(),
            m_frameSize.height(),
            QImage::Format_RGB888
            );
        // 4. 发射信号通知有新帧
        emit frameReceived(image.rgbSwapped());
    }
}
