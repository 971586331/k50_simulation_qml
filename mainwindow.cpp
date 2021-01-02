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
short preheat_timeing = 0;  // 剩预热时间


bool weight_recv_flag = false;
bool timestamp_recv_flag = false;
bool preheat_flag = false;

mainwindow::mainwindow(QObject *parent) : QObject(parent)
{

    gSerial_Info.serialport = new QSerialPort(this);
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
 * @brief MainWindow::open_close_com 打开或关闭com口
 * @param onoff: true打开串口，false关闭串口
 */
bool mainwindow::open_close_com(bool onoff)
{
    //打开串口
    if(onoff == true)
    {
        //设置串口号
//        gSerial_Info.serialport->setPortName(com_combobox->currentText());
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
        }
        else
        {
            return false;
        }
    }
    else
    {
        gSerial_Info.serialport->close();
    }
    return true;
}

/**
 * @brief mainwindow::power_on  开机
 * @return
 */
bool mainwindow::power_on()
{
    // 执行开机流程
    if( open_close_com(true) == true )
    {
        memset(&gk50_state, 0x00, sizeof(struct k50_state_t));
        weight_recv_flag = false;
        timestamp_recv_flag = false;
        preheat_flag = false;
        gSerial_Info.q_msg.clear();

        gk50_state.run_status = INITIAL_STATUS;
        send_pack(&gSerial_Info.q_msg, PACK_TYPE_STATE, 0, sizeof(struct k50_state_t), (uint8_t *)&gk50_state);
        gk50_state.run_status = PREHEATING_STATUS;
        send_pack(&gSerial_Info.q_msg, PACK_TYPE_STATE, 0, sizeof(struct k50_state_t), (uint8_t *)&gk50_state);
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
    open_close_com(false);
}

void mainwindow::refresh_com()
{
    foreach (const QSerialPortInfo &qspinfo, QSerialPortInfo::availablePorts())
    {
        qDebug() << "portname = " << qspinfo.portName();
    }
}


