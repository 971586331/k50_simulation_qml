import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.2
import QtQuick.Extras 1.4

Page {

    ScrollView
    {
        width: parent.width
        height: parent.height*2
        clip: true
        // 预热
        Rectangle {
            id: warm_rect
            color: "darkgray"
            height: parent.height / 20
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
                text: qsTr("预热状态：")
            }
            Label {
                id: warm_state
                text: qsTr("x")
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
                    id: warm_textinput
                    anchors.fill: parent
                    text: qsTr("x")
                    cursorVisible: false
                }
            }
        }

        // 校准
        Rectangle {
            id: calibra_rect
            color: "darkgray"
            height: parent.height / 20
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
                text: qsTr("x")
            }
            Button {
                id: calibra_button1
                text: qsTr("校准")
            }
            Label {
                text: qsTr("Flow Zero cal：")
            }
            Label {
                id: calibra_label2
                text: qsTr("x")
            }
            Button {
                id: calibra_button2
                text: qsTr("校准")
            }
            Label {
                text: qsTr("OC2 Zero cal：")
                x: 20
            }
            Label {
                id: calibra_label3
                text: qsTr("x")
            }
            Button {
                id: calibra_button3
                text: qsTr("校准")
            }
            Label {
                text: qsTr("CO2 Span cal：")
                x: 20
            }
            Label {
                id: calibra_label4
                text: qsTr("x")
            }
            Button {
                id: calibra_button4
                text: qsTr("校准")
            }
        }

        // 接收数据
        Rectangle {
            id: recv_rect
            color: "darkgray"
            height: parent.height / 20
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
            height: parent.height / 20
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
            rowSpacing: 5
            columns: 10
            rows: 2
            Label {
                Layout.row: 0
                Layout.column: 0
                Layout.columnSpan: 3
                text: qsTr("开始采集：")
            }
            StatusIndicator{
                Layout.row: 0
                Layout.column: 1
                color: "darkgray"  //green
            }
            Label {
                Layout.row: 1
                Layout.column: 0
                Layout.columnSpan: 3
                text: qsTr("Relative time stamp in seconds:")
            }
            Rectangle {
                color: "lightgrey"
                border.color: "grey"
                Layout.fillHeight: true
                Layout.fillWidth: true
                width: parent.width / 2
                Layout.row: 1
                Layout.column: 3
                Layout.columnSpan: 3
                TextInput {
                    id: data_1_textinput
                    anchors.fill: parent
                    text: qsTr("x")
                    cursorVisible: false
                }
            }
            Label {
                Layout.row: 2
                Layout.column: 0
                Layout.columnSpan: 3
                text: qsTr("VO2 in ml/min/kg:")
            }
            ProgressBar{
                Layout.row: 2
                Layout.column: 3
                Layout.columnSpan: 5
            }
            Rectangle {
                color: "lightgrey"
                border.color: "grey"
                Layout.fillHeight: true
                Layout.fillWidth: true
                width: parent.width / 2
                Layout.row: 2
                Layout.column: 8
                Layout.columnSpan: 2
                TextInput {
                    id: data_2_textinput
                    anchors.fill: parent
                    text: qsTr("x")
                    cursorVisible: false
                }
            }
        }
    }
}
