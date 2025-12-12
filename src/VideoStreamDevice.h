#ifndef VIDEOSTREAMDEVICE_H
#define VIDEOSTREAMDEVICE_H

#include <QIODevice>
#include <QByteArray>
#include <QMutex>
#include <QMediaPlayer>
#include <QDebug>

class VideoStreamDevice : public QIODevice
{
    Q_OBJECT

public:
    explicit VideoStreamDevice(QObject *parent = nullptr);
    ~VideoStreamDevice();

    // QIODevice interface
    bool isSequential() const override;
    bool atEnd() const override;
    qint64 bytesAvailable() const override;

    // Static access for C++
    static VideoStreamDevice *instance();
    
    // Reset the device state (clears buffer and readiness)
    Q_INVOKABLE void resetBuffer();

    // Q_INVOKABLE methods for QML
    Q_INVOKABLE void appendData(const QByteArray &data);
    Q_INVOKABLE void attachPlayer(QObject *player);

protected:
    qint64 readData(char *data, qint64 maxlen) override;
    qint64 writeData(const char *data, qint64 len) override;

private:
    QByteArray m_buffer;
    QMutex m_mutex;
    static VideoStreamDevice *m_instance;
    
    // Buffering control
    bool m_isReadyToRead = false;
    // 128KB should be enough for FFmpeg to probe the format (MPEG-TS packets are small)
    const int MIN_PROBE_SIZE = 128 * 1024; 
};

#endif // VIDEOSTREAMDEVICE_H


