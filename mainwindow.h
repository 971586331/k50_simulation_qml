#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QObject>
#include <QtSerialPort/QSerialPort>
#include <QQueue>

#define EOT (0xA5)

#define PACK_NUM_INDEX      (1)
#define PACK_TYPE_INDEX     (2)
#define PACK_CONTROL_INDEX  (3)
#define PACK_LEN_INDEX      (4)
#define PACK_DATA_INDEX     (5)
#define PACK_TOTAL_LEN      (7)

// 包类型
enum e_pack_type
{
    PACK_UNKNOWN        = 0x0,
    PACK_TYPE_WEIGHT    = 0x10,
    PACK_TYPE_TIMESTAMP = 0x11,
    PACK_TYPE_HR        = 0x12,
    PACK_TYPE_OSC       = 0x13,
    PACK_TYPE_FZC       = 0x14,
    PACK_TYPE_CZC       = 0x15,
    PACK_TYPE_CSC       = 0x16,
    PACK_TYPE_START     = 0x17,
    PACK_TYPE_STOP      = 0x18,
    PACK_TYPE_STATE     = 0x20,
    PACK_TYPE_PREHEAT   = 0x21,
    PACK_TYPE_DATA      = 0x22,
    PACK_TYPE_RESPONSE  = 0x80,
};

// 控制位
enum e_control_bit
{
    CONTROL_RESPONSE = 0x01,
    CONTROL_VERIFY = 0x01,
};

// 错误代码
enum e_error_code
{
    PACK_NO_ERROR       = 0x00,
    PACK_SUM_ERROR      = 0x01,
    PACK_DATA_LEN_ERROR = 0x02,
    PACK_TYPE_ERROR= 0x03,
};

// 校准对象
enum e_calibrat_obj
{
    CALIBRAT_NULL,
    CALIBRAT_OS,
    CALIBRAT_FZ,
    CALIBRAT_CZ,
    CALIBRAT_CS,
};

// 校准状态
enum e_calibrat_state
{
    NO_CALIBRAT     = 0x00,
    CALIBRATING     = 0x01,
    COMPLETE_CALIBRAT  = 0x02,
};

#pragma pack(push)  //保存对齐状态
#pragma pack(1)     //设定为1字节对齐
struct k50_state_t
{
    uint8_t run_status;
    uint8_t osc:2;
    uint8_t fzc:2;
    uint8_t czc:2;
    uint8_t csc:2;
};
#pragma pack(pop)   //恢复对齐状态

// 运行状态
enum e_run_status
{
    OFFLINE_STATUS = 0x00,      // 离线状态
    INITIAL_STATUS = 0x01,      // 初始状态
    PREHEATING_STATUS = 0x02,   // 预热中
    PREHEAT_OK_STATUS = 0x03,   // 预热完成
    READY_STATUS = 0x04,        // 准备就绪
    UPLOAD_STATUS = 0x05,       // 正在上传状态
    STOP_STATUS = 0x06,         // 停止上传状态
};

//传感器数据包
#pragma pack(push)  //保存对齐状态
#pragma pack(2)     //设定为1字节对齐
struct sensor_data_t
{
    unsigned int time;
    unsigned short vo2;
    unsigned short br;
    float o2;
    float tvl;
    float tcb;
    float flow;
    float ve;
    float co2;
    float vco2;
    float rer;
    float eto2;
    float etco2;
    float pressure;
    unsigned short temp;
    unsigned short rh;
};
#pragma pack(pop)   //恢复对齐状态

//队列数据
struct queue_t
{
    uint8_t *data;
    int len;
};

//串口信息
struct Serial_Info
{
    QSerialPort *serialport;    //串口对象
    uint8_t buff[256];             //串口数据
    int len;                    //串口数据的长度
    bool onoff;                 //串口是否打开
    QQueue<struct queue_t> q_msg;
};

class mainwindow : public QObject
{
    Q_OBJECT

public:
    explicit mainwindow(QObject *parent = nullptr);

    bool open_com(QString com_str);
    void close_com();

    Q_INVOKABLE bool power_on(QString com_str);
    Q_INVOKABLE void power_off();
    Q_INVOKABLE void refresh_com();

    QList<QString> m_devices;
    Q_INVOKABLE QList<QString> get_devices();

signals:

};

#endif // MAINWINDOW_H
