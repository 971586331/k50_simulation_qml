import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Extras 1.4

Page {
    ToggleButton {
        id: onoff
        text: checked ? qsTr("关机") : qsTr("开机")
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height / 4
    }
    Label {
        id: label1
        text: qsTr("uart端口号：")
        anchors.top: onoff.bottom
        anchors.topMargin: 20
        x: parent.width / 10
    }
    ComboBox {
        id: combobox1
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.left: label1.right
        anchors.leftMargin: 10
        anchors.verticalCenter: label1.verticalCenter
    }
    Button {
        text: qsTr("刷新端口")
        anchors.left: combobox1.right
        anchors.leftMargin: 10
        anchors.verticalCenter: combobox1.verticalCenter
        x: (parent.width / 10) * 9
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

