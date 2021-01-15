import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Extras 1.4

Page {

    ToggleButton {
        id: onoff
        text: checked ? qsTr("关机") : qsTr("开机")
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height / 4
        onClicked: {

            //            console.log("checked = ", checked)
            //            if (checked == true) {
            //                cpp_interface.power_on(combobox1.textAt(combobox1.currentIndex))
            //            } else {
            //                cpp_interface.power_off()
            //            }
        }
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
                model.append({
                                 "text": list[i]
                             })
            }
        }
    }

    InfoBanner {
        id: messages
    }

    Button {
        text: qsTr("test")
        anchors.top: combobox1.bottom
        anchors.leftMargin: 10
        onClicked: {
            cpp_interface.button_test()
            //            messages.displayMessage("Hello World")
        }
    }
}
