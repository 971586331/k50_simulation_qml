import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.2

Page {

    Rectangle{
        id: warm_rect
        color:"darkgray"
        height: parent.height / 20
        width: parent.width

        Label {
            text: qsTr("预热")
            font.pixelSize: 16
            color: "darkcyan"
            x:10
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    GridLayout {
        id: warm_grid
        anchors.top: warm_rect.bottom
        anchors.topMargin: 5
        x: 20
        width: parent.width-40
        rowSpacing: 5
        columns: 2
        rows: 2
        Label {
            text: qsTr("预热状态：")
            x:20
        }
        Label {
            id:warm_state
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
            width: parent.width/2
            TextInput{
                id:warm_textinput
                anchors.fill: parent
                text: qsTr("x")
                cursorVisible: false
            }
        }
    }

    Rectangle{
        id: calibra_rect
        color:"darkgray"
        height: parent.height / 20
        width: parent.width
        anchors.top:warm_grid.bottom
        anchors.topMargin: 5

        Label {
            text: qsTr("校准")
            font.pixelSize: 16
            color: "darkcyan"
            x:10
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    GridLayout {
        id : calibra_grid
        anchors.top: calibra_rect.bottom
        x: 20
        width: parent.width-40
        anchors.topMargin: 5
        rowSpacing: 5
        columns: 3
        rows: 4

        Label {
            text: qsTr("O2 Span cal：")
            x:20
        }
        Label {
            id: calibra_label1
            text: qsTr("x")
            x:20
        }
        Button {
            id: calibra_button1
            text: qsTr("校准")
        }
        Label {
            text: qsTr("Flow Zero cal：")
            x:20
        }
        Label {
            id: calibra_label2
            text: qsTr("x")
            x:20
        }
        Button {
            id: calibra_button2
            text: qsTr("校准")
        }
        Label {
            text: qsTr("OC2 Zero cal：")
            x:20
        }
        Label {
            id: calibra_label3
            text: qsTr("x")
            x:20
        }
        Button {
            id: calibra_button3
            text: qsTr("校准")
        }
        Label {
            text: qsTr("CO2 Span cal：")
            x:20
        }
        Label {
            id: calibra_label4
            text: qsTr("x")
            x:20
        }
        Button {
            id: calibra_button4
            text: qsTr("校准")
        }
    }
}
