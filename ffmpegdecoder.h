#ifndef FFMPEGDECODER_H
#define FFMPEGDECODER_H

#include <QObject>
#include <QProcess>
#include <QMutex>
#include <QImage>
#include<QQueue>

class FFmpegDecoder : public QObject
{
    Q_OBJECT
public:
    explicit FFmpegDecoder(int port, QObject *parent = nullptr);
    ~FFmpegDecoder();

    void start();
    void stop();

signals:
    void frameReceived(QImage frame);

private slots:
    void onProcessOutput();


private:
    QProcess *m_process;
    QByteArray m_buffer;
    QSize m_frameSize = QSize(640, 480); // 默认分辨率
    QMutex m_mutex;
    int m_port;
    const int MAX_FRAMES = 30;  // 最大保留30帧
    QQueue<QImage> frameQueue;
};

#endif // FFMPEGDECODER_H
