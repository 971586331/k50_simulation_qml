import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Extras 1.4
import QtQuick.Layouts 1.2

ApplicationWindow {
    visible: true
    width: 480
    height: 640
    title: qsTr("Tabs")
    id:root

    property int title_ratio: 40
    property int volume: slider1.value
    property int gv_name: 1

    signal signal_button_10_onClicked()

//            Timer {
//                interval: 1000
//                running: true
//                repeat: true
//                onTriggered: {
//                    gv_name ++
//                    console.log("gv_name = ", gv_name)
//                }
//            }

    SwipeView {
        id: swipeView
        anchors.fill: parent
        currentIndex: tabBar.currentIndex

        Page {
            ToggleButton {
                id: onoff
                text: checked ? qsTr("关机") : qsTr("开机")
                anchors.horizontalCenter: parent.horizontalCenter
                y: parent.height / 4
                onClicked: {
                    console.log("checked = ", checked)
                    if (checked == true) {
                        cpp_interface.power_on(combobox1.textAt(combobox1.currentIndex))
                    } else {
                        cpp_interface.power_off()
                    }
                }
            }
            Label {
                id: page1_label_1
                text: qsTr("uart端口号：")
                anchors.top: onoff.bottom
                anchors.topMargin: 20
                x: parent.width / 10
            }
            ComboBox {
                id: combobox1
                anchors.horizontalCenter: onoff.horizontalCenter
                anchors.left: page1_label_1.right
                anchors.leftMargin: 10
                anchors.verticalCenter: page1_label_1.verticalCenter
                model: ListModel {
                    id: model
                }
                currentIndex: 0
            }
            Button {
                text: qsTr("刷新端口")
                anchors.left: combobox1.right
                anchors.leftMargin: 10
                anchors.verticalCenter: combobox1.verticalCenter
                x: (parent.width / 10) * 9
                onClicked: {
                    console.log("刷新端口")
                    model.clear()
                    cpp_interface.refresh_com()
                    var list = cpp_interface.get_devices()
                    for (var i = 0; i < list.length; i++) {
                        model.append({"text": list[i]})
                    }
                }
            }
            Button {
                id:button_10
                text: qsTr("test")
                anchors.top: combobox1.bottom
                anchors.leftMargin: 10
                onClicked: {
                    cpp_interface.button_test()
//                  signal_button_10_onClicked();
                }
            }
        }

        Page {
            ScrollView {
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: ScrollBar.AlwaysOn
                height: parent.height
                width: parent.width
                contentWidth: parent.width
                contentHeight: parent.height * 2
                ScrollBar.horizontal.interactive: true
                ScrollBar.vertical.interactive: true
                // 预热
                Rectangle {
                    id: warm_rect
                    color: "darkgray"
                    height: parent.height / title_ratio
                    width: parent.width

                    Label {
                        text: qsTr("预热")
                        font.pixelSize: 16
                        color: "darkcyan"
                        x: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                GridLayout {
                    id: warm_grid
                    anchors.top: warm_rect.bottom
                    anchors.topMargin: 5
                    x: 20
                    width: parent.width - 40
                    rowSpacing: 5
                    columns: 2
                    rows: 2
                    Label {
                        id: lable1
                        text: qsTr("预热状态：")
                    }
                    Label {
                        id: warm_state
                        text: cpp_interface.warm_state
                    }
                    Label {
                        text: qsTr("剩余预热时间：")
                    }
                    Rectangle {
                        color: "lightgrey"
                        border.color: "grey"
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        width: parent.width / 2
                        TextInput {
                            id: warm_time
                            anchors.fill: parent
                            text: cpp_interface.preheat_timeing
                            cursorVisible: false
                        }
                    }
                }

                // 校准
                Rectangle {
                    id: calibra_rect
                    color: "darkgray"
                    height: parent.height / title_ratio
                    width: parent.width
                    anchors.top: warm_grid.bottom
                    anchors.topMargin: 5

                    Label {
                        text: qsTr("校准")
                        font.pixelSize: 16
                        color: "darkcyan"
                        x: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                GridLayout {
                    id: calibra_grid
                    anchors.top: calibra_rect.bottom
                    x: 20
                    width: parent.width - 40
                    anchors.topMargin: 5
                    rowSpacing: 5
                    columns: 3
                    rows: 4

                    Label {
                        text: qsTr("O2 Span cal：")
                    }
                    Label {
                        id: calibra_label1
                        text: cpp_interface.calibrate_state[0]
                    }
                    Button {
                        id: calibra_button1
                        text: qsTr("校准")
                        onClicked: cpp_interface.slots_OS_calibrate_button_clicked()
                    }
                    Label {
                        text: qsTr("Flow Zero cal：")
                    }
                    Label {
                        id: calibra_label2
                        text: cpp_interface.calibrate_state[1]
                    }
                    Button {
                        id: calibra_button2
                        text: qsTr("校准")
                        onClicked: cpp_interface.slots_FZ_calibrate_button_clicked()
                    }
                    Label {
                        text: qsTr("OC2 Zero cal：")
                        x: 20
                    }
                    Label {
                        id: calibra_label3
                        text: cpp_interface.calibrate_state[2]
                    }
                    Button {
                        id: calibra_button3
                        text: qsTr("校准")
                        onClicked: cpp_interface.slots_CZ_calibrate_button_clicked()
                    }
                    Label {
                        text: qsTr("CO2 Span cal：")
                        x: 20
                    }
                    Label {
                        id: calibra_label4
                        text: cpp_interface.calibrate_state[3]
                    }
                    Button {
                        id: calibra_button4
                        text: qsTr("校准")
                        onClicked: cpp_interface.slots_CS_calibrate_button_clicked()
                    }
                }

                // 接收数据
                Rectangle {
                    id: recv_rect
                    color: "darkgray"
                    height: parent.height / title_ratio
                    width: parent.width
                    anchors.top: calibra_grid.bottom
                    anchors.topMargin: 5

                    Label {
                        text: qsTr("接收数据")
                        font.pixelSize: 16
                        color: "darkcyan"
                        x: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                GridLayout {
                    id: recv_grid
                    anchors.top: recv_rect.bottom
                    anchors.topMargin: 5
                    x: 20
                    width: parent.width - 40
                    rowSpacing: 5
                    columns: 2
                    rows: 3
                    Label {
                        text: qsTr("体重：")
                    }
                    Label {
                        id: weight_label
                        text: qsTr("x")
                    }
                    Label {
                        text: qsTr("时间戳：")
                    }
                    Label {
                        id: timestamp_label
                        text: qsTr("x")
                    }
                    Label {
                        text: qsTr("心率：")
                    }
                    Label {
                        id: heart_rate_label
                        text: qsTr("x")
                    }
                }

                // 上传数据
                Rectangle {
                    id: upload_rect
                    color: "darkgray"
                    height: parent.height / title_ratio
                    width: parent.width
                    anchors.top: recv_grid.bottom
                    anchors.topMargin: 5

                    Label {
                        text: qsTr("上传数据")
                        font.pixelSize: 16
                        color: "darkcyan"
                        x: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                GridLayout {
                    id: upload_grid
                    anchors.top: upload_rect.bottom
                    anchors.topMargin: 5
                    x: 20
                    width: parent.width - 40
                    columnSpacing: 10
                    rowSpacing: 10
                    columns: 5
                    rows: 4
                    // 0
                    Label {
                        Layout.row: 0
                        Layout.column: 0
                        Layout.columnSpan: 3
                        text: qsTr("开始采集：")
                    }
                    StatusIndicator {
                        objectName: "led"
                        Layout.row: 0
                        Layout.column: 1
                        Layout.columnSpan: 1
                        color: "darkgray" //green
                    }
                    // 1
                    Label {
                        Layout.row: 1
                        Layout.column: 0
                        Layout.columnSpan: 1
                        text: qsTr("Relative time stamp in seconds:")
                    }
                    Rectangle {
                        Layout.row: 1
                        Layout.column: 1
                        Layout.columnSpan: 1
                        color: "lightgrey"
                        border.color: "grey"
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        TextInput {
                            id: data_1_textinput
                            anchors.fill: parent
                            text: qsTr("x")
                            cursorVisible: false
                        }
                    }
                    // 2
                    Label {
                        Layout.row: 2
                        Layout.column: 0
                        Layout.columnSpan: 1
                        text: qsTr("VO2 in ml/min/kg:")
                    }
                    Slider {
                        id: slider1
                        from: 1
                        to: 100
                        stepSize: 1
                        Layout.row: 2
                        Layout.column: 1
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                    }
                    Rectangle {
                        Layout.row: 2
                        Layout.column: 4
                        Layout.columnSpan: 1
                        color: "lightgrey"
                        border.color: "grey"
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        TextInput {
                            id: data_2_textinput
                            objectName: "data_2"
                            anchors.fill: parent
                            text: slider1.value
                            cursorVisible: false
                        }
                    }
                    // 3
                    Label {
                        Layout.row: 3
                        Layout.column: 0
                        Layout.columnSpan: 1
                        text: qsTr("Breath Rate in breaths/minute:")
                    }
                    Slider {
                        id: slider2
                        from: 1
                        to: 100
                        stepSize: 1
                        Layout.row: 3
                        Layout.column: 1
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                    }
                    Rectangle {
                        Layout.row: 3
                        Layout.column: 4
                        Layout.columnSpan: 1
                        color: "lightgrey"
                        border.color: "grey"
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        TextInput {
                            id: data_3_textinput
                            anchors.fill: parent
                            text: slider2.value
                            cursorVisible: false
                        }
                    }
                    // 4
                    Label {
                        Layout.row: 4
                        Layout.column: 0
                        Layout.columnSpan: 1
                        text: qsTr("O2%:")
                    }
                    Slider {
                        id: slider3
                        from: 1
                        to: 100
                        stepSize: 1
                        Layout.row: 4
                        Layout.column: 1
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                    }
                    Rectangle {
                        Layout.row: 4
                        Layout.column: 4
                        Layout.columnSpan: 1
                        color: "lightgrey"
                        border.color: "grey"
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        TextInput {
                            id: data_4_textinput
                            anchors.fill: parent
                            text: slider3.value
                            cursorVisible: false
                        }
                    }
                    // 5
                    Label {
                        Layout.row: 5
                        Layout.column: 0
                        Layout.columnSpan: 1
                        text: qsTr("Tidal Volume in Litre:")
                    }
                    Slider {
                        id: slider4
                        from: 1
                        to: 100
                        stepSize: 1
                        Layout.row: 5
                        Layout.column: 1
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                    }
                    Rectangle {
                        Layout.row: 5
                        Layout.column: 4
                        Layout.columnSpan: 1
                        color: "lightgrey"
                        border.color: "grey"
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        TextInput {
                            id: data_5_textinput
                            anchors.fill: parent
                            text: slider4.value
                            cursorVisible: false
                        }
                    }
                    // 6
                    Label {
                        Layout.row: 6
                        Layout.column: 0
                        Layout.columnSpan: 1
                        text: qsTr("Total Calories Burned:")
                    }
                    Slider {
                        id: slider5
                        from: 1
                        to: 100
                        stepSize: 1
                        Layout.row: 6
                        Layout.column: 1
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                    }
                    Rectangle {
                        Layout.row: 6
                        Layout.column: 4
                        Layout.columnSpan: 1
                        color: "lightgrey"
                        border.color: "grey"
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        TextInput {
                            id: data_6_textinput
                            anchors.fill: parent
                            text: slider5.value
                            cursorVisible: false
                        }
                    }
                    // 7
                    Label {
                        Layout.row: 7
                        Layout.column: 0
                        Layout.columnSpan: 1
                        text: qsTr("Flow in L/s:")
                    }
                    Slider {
                        id: slider6
                        from: 1
                        to: 100
                        stepSize: 1
                        Layout.row: 7
                        Layout.column: 1
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                    }
                    Rectangle {
                        Layout.row: 7
                        Layout.column: 4
                        Layout.columnSpan: 1
                        color: "lightgrey"
                        border.color: "grey"
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        TextInput {
                            id: data_7_textinput
                            anchors.fill: parent
                            text: slider6.value
                            cursorVisible: false
                        }
                    }
                    // 8
                    Label {
                        Layout.row: 8
                        Layout.column: 0
                        Layout.columnSpan: 1
                        text: qsTr("VE in L/min:")
                    }
                    Slider {
                        id: slider7
                        from: 1
                        to: 100
                        stepSize: 1
                        Layout.row: 8
                        Layout.column: 1
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                    }
                    Rectangle {
                        Layout.row: 8
                        Layout.column: 4
                        Layout.columnSpan: 1
                        color: "lightgrey"
                        border.color: "grey"
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        TextInput {
                            id: data_8_textinput
                            anchors.fill: parent
                            text: slider7.value
                            cursorVisible: false
                        }
                    }
                    // 9
                    Label {
                        Layout.row: 9
                        Layout.column: 0
                        Layout.columnSpan: 1
                        text: qsTr("CO2%:")
                    }
                    Slider {
                        id: slider8
                        from: 1
                        to: 100
                        stepSize: 1
                        Layout.row: 9
                        Layout.column: 1
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                    }
                    Rectangle {
                        Layout.row: 9
                        Layout.column: 4
                        Layout.columnSpan: 1
                        color: "lightgrey"
                        border.color: "grey"
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        TextInput {
                            id: data_9_textinput
                            anchors.fill: parent
                            text: slider8.value
                            cursorVisible: false
                        }
                    }
                    // 10
                    Label {
                        Layout.row: 10
                        Layout.column: 0
                        Layout.columnSpan: 1
                        text: qsTr("VCO2 in ml/min:")
                    }
                    Slider {
                        id: slider9
                        from: 1
                        to: 100
                        stepSize: 1
                        Layout.row: 10
                        Layout.column: 1
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                    }
                    Rectangle {
                        Layout.row: 10
                        Layout.column: 4
                        Layout.columnSpan: 1
                        color: "lightgrey"
                        border.color: "grey"
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        TextInput {
                            id: data_10_textinput
                            anchors.fill: parent
                            text: slider9.value
                            cursorVisible: false
                        }
                    }
                    // 11
                    Label {
                        Layout.row: 11
                        Layout.column: 0
                        Layout.columnSpan: 1
                        text: qsTr("RER:")
                    }
                    Slider {
                        id: slider10
                        from: 1
                        to: 100
                        stepSize: 1
                        Layout.row: 11
                        Layout.column: 1
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                    }
                    Rectangle {
                        Layout.row: 11
                        Layout.column: 4
                        Layout.columnSpan: 1
                        color: "lightgrey"
                        border.color: "grey"
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        TextInput {
                            id: data_11_textinput
                            anchors.fill: parent
                            text: slider10.value
                            cursorVisible: false
                        }
                    }
                    // 12
                    Label {
                        Layout.row: 12
                        Layout.column: 0
                        Layout.columnSpan: 1
                        text: qsTr("ETO2 in %:")
                    }
                    Slider {
                        id: slider11
                        from: 1
                        to: 100
                        stepSize: 1
                        Layout.row: 12
                        Layout.column: 1
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                    }
                    Rectangle {
                        Layout.row: 12
                        Layout.column: 4
                        Layout.columnSpan: 1
                        color: "lightgrey"
                        border.color: "grey"
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        TextInput {
                            id: data_12_textinput
                            anchors.fill: parent
                            text: slider11.value
                            cursorVisible: false
                        }
                    }
                    // 13
                    Label {
                        Layout.row: 13
                        Layout.column: 0
                        Layout.columnSpan: 1
                        text: qsTr("ETCO2 in %:")
                    }
                    Slider {
                        id: slider12
                        from: 1
                        to: 100
                        stepSize: 1
                        Layout.row: 13
                        Layout.column: 1
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                    }
                    Rectangle {
                        Layout.row: 13
                        Layout.column: 4
                        Layout.columnSpan: 1
                        color: "lightgrey"
                        border.color: "grey"
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        TextInput {
                            id: data_13_textinput
                            anchors.fill: parent
                            text: slider12.value
                            cursorVisible: false
                        }
                    }
                    // 14
                    Label {
                        Layout.row: 14
                        Layout.column: 0
                        Layout.columnSpan: 1
                        text: qsTr("Pressure in kPa:")
                    }
                    Slider {
                        id: slider13
                        from: 1
                        to: 100
                        stepSize: 1
                        Layout.row: 14
                        Layout.column: 1
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                    }
                    Rectangle {
                        Layout.row: 14
                        Layout.column: 4
                        Layout.columnSpan: 1
                        color: "lightgrey"
                        border.color: "grey"
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        TextInput {
                            id: data_14_textinput
                            anchors.fill: parent
                            text: slider13.value
                            cursorVisible: false
                        }
                    }
                    // 15
                    Label {
                        Layout.row: 15
                        Layout.column: 0
                        Layout.columnSpan: 1
                        text: qsTr("Temperature in °C:")
                    }
                    Slider {
                        id: slider14
                        from: 1
                        to: 100
                        stepSize: 1
                        Layout.row: 15
                        Layout.column: 1
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                    }
                    Rectangle {
                        Layout.row: 15
                        Layout.column: 4
                        Layout.columnSpan: 1
                        color: "lightgrey"
                        border.color: "grey"
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        TextInput {
                            id: data_15_textinput
                            anchors.fill: parent
                            text: slider14.value
                            cursorVisible: false
                        }
                    }
                    // 16
                    Label {
                        Layout.row: 16
                        Layout.column: 0
                        Layout.columnSpan: 1
                        text: qsTr("RH in %:")
                    }
                    Slider {
                        id: slider15
                        from: 1
                        to: 100
                        stepSize: 1
                        Layout.row: 16
                        Layout.column: 1
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                    }
                    Rectangle {
                        Layout.row: 16
                        Layout.column: 4
                        Layout.columnSpan: 1
                        color: "lightgrey"
                        border.color: "grey"
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        TextInput {
                            id: data_16_textinput
                            anchors.fill: parent
                            text: slider15.value
                            cursorVisible: false
                        }
                    }
                }
            }
        }

        Page {
            Label {
                id: debug_label
                text: qsTr("xxx")
                x: 20
            }
        }
    }

    footer: TabBar {
        id: tabBar
        currentIndex: swipeView.currentIndex


        TabButton {
            text: qsTr("开关")
        }
        TabButton {
            text: qsTr("运行")
        }
        TabButton {
            text: qsTr("调试")
        }
    }
}
