#include "mainwindow.h"
#include <QtSerialPort/QSerialPortInfo>
#include <QDebug>

struct Serial_Info gSerial_Info;
uint8_t gpack_num = 0;  // 包序号
int gtimestamp = 0;     // 时间戳
int calibration_time_value = 0; // 校准时间
int upload_time_value = 0;  //数据上传间隔
enum e_calibrat_obj gcalibrat_obj = CALIBRAT_NULL;    // 标准对象
struct k50_state_t gk50_state =
{
    .run_status = 0,
    .osc = NO_CALIBRAT,
    .fzc = NO_CALIBRAT,
    .czc = NO_CALIBRAT,
    .csc = NO_CALIBRAT,
};
short preheat_timeing = 10;  // 剩预热时间


bool weight_recv_flag = false;
bool timestamp_recv_flag = false;
bool preheat_flag = false;

mainwindow::mainwindow(QObject *parent) : QObject(parent)
{

    gSerial_Info.serialport = new QSerialPort(this);

    // 预热计时
    preheat_time = new QTimer(this);
    connect(preheat_time, SIGNAL(timeout()), this, SLOT(slot_preheat_time_timeout()));

    //串口发送数据
    send_time = new QTimer(this);
    connect(send_time, SIGNAL(timeout()), this, SLOT(slot_send_time_timeout()));
}

uint8_t sum_verify(uint8_t *data, int len)
{
    int sum = 0;

    for(int i=0; i<len; i++)
    {
        sum += data[i];
    }
    return sum&0xff;
}

/**
 * @brief send_data
 * @param port
 * @param pack_num
 * @param pack_type
 * @param control
 * @param data_len
 * @param data
 */
void send_pack(QQueue<struct queue_t> *msg, enum e_pack_type pack_type,
               uint8_t control, uint8_t data_len, uint8_t *data)
{
    uint8_t *pack_data = (uint8_t *)malloc( PACK_TOTAL_LEN + data_len );

    pack_data[0] = 0x5A;
    pack_data[PACK_NUM_INDEX] = gpack_num;
    pack_data[PACK_TYPE_INDEX] = pack_type;
    pack_data[PACK_CONTROL_INDEX] = control;
    pack_data[PACK_LEN_INDEX] = data_len;

//    qDebug() << "data[0]" << data[0] << "data[1]" << data[1];
    memcpy(pack_data + PACK_DATA_INDEX, data, data_len);

    pack_data[PACK_DATA_INDEX + data_len] = sum_verify(pack_data+PACK_NUM_INDEX, PACK_LEN_INDEX+data_len);
    pack_data[PACK_TOTAL_LEN + data_len - 1] = 0xA5;

    struct queue_t node;
    node.data = pack_data;
    node.len = PACK_TOTAL_LEN + data_len;
    msg->enqueue(node);
//    port->write((char *)pack_data, PACK_TOTAL_LEN + data_len);
    gpack_num ++;
}

/**
 * @brief MainWindow::slot_send_time_timeout
 */
void mainwindow::slot_send_time_timeout()
{
    if( !gSerial_Info.q_msg.isEmpty() )
    {
        struct queue_t data = gSerial_Info.q_msg.dequeue();
        gSerial_Info.serialport->write((char *)data.data, data.len);
        // qml显示
//        add_debug_info(textedit, true, data.data, data.len);
        free(data.data);

    }
}

/**
 * @brief MainWindow::open_com 打开com口
 * @param onoff: true打开串口，false关闭串口
 */
bool mainwindow::open_com(QString com_str)
{
    //设置串口号
    gSerial_Info.serialport->setPortName(com_str);
    //以读写方式打开串口
    if(gSerial_Info.serialport->open(QIODevice::ReadWrite))
    {
        //设置波特率
        QString baud = "115200";
        if( baud.isEmpty() == true )
        {
            gSerial_Info.serialport->setBaudRate(115200);
        }
        else
        {
            gSerial_Info.serialport->setBaudRate(baud.toInt());
        }
        //设置数据位
        gSerial_Info.serialport->setDataBits(QSerialPort::Data8);
        //设置校验位
        gSerial_Info.serialport->setParity(QSerialPort::NoParity);
        //设置流控制
        gSerial_Info.serialport->setFlowControl(QSerialPort::NoFlowControl);
        //设置停止位
        gSerial_Info.serialport->setStopBits(QSerialPort::OneStop);

        connect(gSerial_Info.serialport,SIGNAL(readyRead()),this,SLOT(slots_serial_receive()));
        qDebug("com open!");
    }
    else
    {
        return false;
    }
    return true;
}

/**
 * @brief mainwindow::close_com 关闭com口
 */
void mainwindow::close_com()
{
    gSerial_Info.serialport->close();
}

/**
 * @brief MainWindow::slots_product_serial_receive  接收串口的数据
 */
void mainwindow::slots_serial_receive()
{
    QByteArray info = gSerial_Info.serialport->readAll();
    if( info.size() > 256 )
        gSerial_Info.len = 256;
    else
        gSerial_Info.len = info.size();
    memcpy(gSerial_Info.buff, info, gSerial_Info.len);

    uart_data_handle(gSerial_Info.buff, gSerial_Info.len);
}

/**
 * @brief MainWindow::uart_data_handle
 * @param data
 * @param len
 */
void mainwindow::uart_data_handle(uint8_t *buff, int len)
{
    int pack_num = 0;
    bool is_reply = false;
    enum e_pack_type pack_type = PACK_UNKNOWN;
    uint8_t *data;

//    add_debug_info(textedit, false, buff, len);
    qDebug("uart_data_handle!");

    // 验证包头和包尾
    if( (buff[0] != STX) || (buff[len - 1] != EOT) )
    {
        qDebug() << "recv STX or EOT error!";
        return;
    }

    // 取出包序号
    pack_num = buff[PACK_NUM_INDEX];
    pack_type = (enum e_pack_type)buff[PACK_TYPE_INDEX];

    // 是否要回复
    if( buff[PACK_CONTROL_INDEX] & 0x01 )
    {
        is_reply = true;
    }

    // 是否要验证检验
    if( buff[PACK_CONTROL_INDEX] & 0x02 )
    {
        uint8_t sum = sum_verify(buff+PACK_NUM_INDEX, PACK_LEN_INDEX+buff[PACK_LEN_INDEX]);
        if( sum != buff[PACK_LEN_INDEX + buff[PACK_LEN_INDEX]] )
        {
            // 如果验证失败
            uint8_t send_data[2];
            send_data[0] = pack_num;
            send_data[1] = PACK_SUM_ERROR;
            send_pack(&gSerial_Info.q_msg, PACK_TYPE_RESPONSE, 0, 2, send_data);
            return;
        }
    }

    // 验证数据长度
    if( (len-PACK_TOTAL_LEN) != buff[PACK_LEN_INDEX] )
    {
        uint8_t send_data[2];
        send_data[0] = pack_num;
        send_data[1] = PACK_DATA_LEN_ERROR;
        send_pack(&gSerial_Info.q_msg, PACK_TYPE_RESPONSE, 0, 2, send_data);
        return;
    }

    data = buff + PACK_DATA_INDEX;

    // 处理包类型
    switch(pack_type)
    {
        case PACK_TYPE_WEIGHT:      // 处理体重数据
        {
            weight_recv_flag = true;
            float weight = *((float *)data);
            // qml显示
//            weight_label->setText(QString(tr("体重: %1")).arg(weight));
            qDebug() << "recv PACK_TYPE_WEIGHT = " << weight;
            if( is_reply == true )
            {
                send_response_pack(pack_num, PACK_NO_ERROR);
            }

            if( timestamp_recv_flag == true )
            {
                gk50_state.run_status = READY_STATUS;
                send_pack(&gSerial_Info.q_msg, PACK_TYPE_STATE, 0, sizeof(struct k50_state_t), (uint8_t *)&gk50_state);
            }
        }
        break;
        case PACK_TYPE_TIMESTAMP:   // 处理时间戳
        {
            timestamp_recv_flag = true;
            gtimestamp = *((int *)data);
            // qml显示
//            timestamp_label->setText(tr("时间戳：") + QString::number(gtimestamp));
            qDebug() << "recv PACK_TYPE_TIMESTAMP = " << gtimestamp;
            if( is_reply == true )
            {
                send_response_pack(pack_num, PACK_NO_ERROR);
            }

            if( weight_recv_flag == true )
            {
                gk50_state.run_status = READY_STATUS;
                send_pack(&gSerial_Info.q_msg, PACK_TYPE_STATE, 0, sizeof(struct k50_state_t), (uint8_t *)&gk50_state);
            }
        }
        break;
        case PACK_TYPE_HR:          // 处理心率数据
        {
            uint16_t heart_rate = *((uint16_t *)data);
            // qml显示
//            heart_rate_label->setText(tr("心率: ") + QString::number(heart_rate));
            qDebug() << "recv PACK_TYPE_HR = " << heart_rate;
            if( is_reply == true )
            {
                send_response_pack(pack_num, PACK_NO_ERROR);
            }
        }
        break;
        case PACK_TYPE_OSC:         // 校准
        {
            qDebug() << "recv PACK_TYPE_OSC ";
//            slots_OS_calibrate_button_clicked();
        }
        break;
        case PACK_TYPE_FZC:         // 校准
        {
            qDebug() << "recv PACK_TYPE_FZC ";
//            slots_FZ_calibrate_button_clicked();
        }
        break;
        case PACK_TYPE_CZC:         // 校准
        {
            qDebug() << "recv PACK_TYPE_CZC ";
//            slots_CZ_calibrate_button_clicked();
        }
        break;
        case PACK_TYPE_CSC:         // 校准
        {
            qDebug() << "recv PACK_TYPE_CSC ";
//            slots_CS_calibrate_button_clicked();
        }
        break;
        case PACK_TYPE_START:       // 开始采集
        {
            qDebug() << "recv PACK_TYPE_START ";
            qDebug() << weight_recv_flag << timestamp_recv_flag << preheat_flag;
            if( (weight_recv_flag == true) && (timestamp_recv_flag == true) && (preheat_flag == true) )
            {
                qDebug() << "开始采集 : " << upload_time_value;
                // qml显示，开定时器
//                upload_time->start(upload_time_value);
//                capture_state_led_label->setStyleSheet("background-color:green;");
            }
        }
        break;
        case PACK_TYPE_STOP:        // 停止采集
        {
            qDebug() << "recv PACK_TYPE_STOP ";
            // qml显示，关定时器
//            upload_time->stop();
//            capture_state_led_label->setStyleSheet("background-color:black;");
        }
        break;
        default : break;
    }
}

/**
 * @brief MainWindow::send_response_pack    发送响应包
 * @param pack_num
 * @param pack_num_1
 * @param code
 */
void mainwindow::send_response_pack(uint8_t pack_num_1, enum e_error_code code)
{
    uint8_t send_data[2];
    send_data[0] = pack_num_1;
    send_data[1] = code;
    send_pack(&gSerial_Info.q_msg, PACK_TYPE_RESPONSE, 0, 2, send_data);
}

/**
 * @brief mainwindow::power_on  开机
 * @return
 */
bool mainwindow::power_on(QString com_str)
{
    qDebug() << "com_str = " << com_str;
    // 执行开机流程
    if( open_com(com_str) == true )
    {
        memset(&gk50_state, 0x00, sizeof(struct k50_state_t));
        weight_recv_flag = false;
        timestamp_recv_flag = false;
        preheat_flag = false;
        gSerial_Info.q_msg.clear();
        send_time->start(500);

        gk50_state.run_status = INITIAL_STATUS;
        send_pack(&gSerial_Info.q_msg, PACK_TYPE_STATE, 0, sizeof(struct k50_state_t), (uint8_t *)&gk50_state);
        gk50_state.run_status = PREHEATING_STATUS;
        send_pack(&gSerial_Info.q_msg, PACK_TYPE_STATE, 0, sizeof(struct k50_state_t), (uint8_t *)&gk50_state);

        preheat_time->start(1000);

        return true;
    }
    return false;
}

/**
 * @brief mainwindow::power_off 关机
 * @return
 */
void mainwindow::power_off()
{
    // 执行关机流程
    close_com();
    send_time->stop();
}

/**
 * @brief MainWindow::slot_preheat_time_timeout 预热剩余时间
 */
void mainwindow::slot_preheat_time_timeout()
{
    preheat_timeing --;
//    time_remain_lineedit->setText(QString::number(preheat_timeing));
    qDebug() << "preheat_timeing = " << preheat_timeing;
    if( preheat_timeing < 0 )  // 预热完成
    {
//        time_remain_label->setText(tr("预热状态：预热完成"));
        preheat_flag = true;
        preheat_time->stop();
        if( (weight_recv_flag == true) && (timestamp_recv_flag == true) )
        {
            // 准备就绪
            gk50_state.run_status = READY_STATUS;
            send_pack(&gSerial_Info.q_msg, PACK_TYPE_STATE, 0, sizeof(struct k50_state_t), (uint8_t *)&gk50_state);
        }
        else
        {
            // 预热完成
            gk50_state.run_status = PREHEAT_OK_STATUS;
            send_pack(&gSerial_Info.q_msg, PACK_TYPE_STATE, 0, sizeof(struct k50_state_t), (uint8_t *)&gk50_state);
        }
    }
    else  // 正在预热
    {
        // 发送预热剩余时间
        send_pack(&gSerial_Info.q_msg, PACK_TYPE_PREHEAT, 0, 2, (uint8_t *)&preheat_timeing);
    }
}


void mainwindow::refresh_com()
{
    m_devices.clear();
    foreach (const QSerialPortInfo &qspinfo, QSerialPortInfo::availablePorts())
    {
        qDebug() << "portname = " << qspinfo.portName();
        m_devices.append(qspinfo.portName());
    }
}

QList<QString> mainwindow::get_devices()
{
    return m_devices;
}


