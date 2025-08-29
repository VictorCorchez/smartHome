import Felgo 4.0
import QtQuick
import QtQuick.Controls as QQC
import QtQuick.Layouts


App {
    // You get free licenseKeys from https://felgo.com/licenseKey
    // With a licenseKey you can:
    //  * Publish your games & apps for the app stores
    //  * Remove the Felgo Splash Screen or set a custom one (available with the Pro Licenses)
    //  * Add plugins to monetize, analyze & improve your apps (available with the Pro Licenses)
    //licenseKey: "<generate one from https://felgo.com/licenseKey>"

    id: app
    ListModel {
        id: devices
        Component.onCompleted:
        {
            dynamicRoles = true
        }
    }

    Storage {
        id: deviceStorage
        databaseName: "deviceList"

    }

    Component.onCompleted:
    {
        for(let i = 0; i < deviceStorage.getValue("count"); i++)
        {
            devices.append(deviceStorage.getValue(i))
        }
    }

    onInitTheme:
    {
        Theme.colors.backgroundColor = "#191919"
        Theme.colors.secondaryBackgroundColor = "#191919"
        Theme.colors.textColor = "white"
        Theme.tabBar.backgroundColor = "#191919"
        Theme.tabBar.showIcon = true
        Theme.dialog.backgroundColor = "#191919"
        Theme.dialog.titleColor = "lightgrey"
        Theme.listItem.backgroundColor = "#191919"
        Theme.listItem.textColor = "white"
        Theme.navigationBar.backgroundColor = "black"
        Theme.navigationBar.titleColor = "white"
    }

    Dialog {
        id: removeDialog
        property int deviceIndex: -1
        anchors.centerIn: parent
        autoSize: true
        title: "Remove Device"
        titleItem.horizontalAlignment: Qt.AlignHCenter

        onAccepted: {
            if (deviceIndex >= 0) {
                devices.remove(deviceIndex, 1)
                deviceStorage.setValue("count", devices.count)
                deviceStorage.clearValue(deviceIndex)
                for(let i = deviceIndex; i < devices.count; i++)
                {
                    deviceStorage.setValue(i, devices.get(i))
                }
                deviceIndex = -1
            }
            close()
        }
        onCanceled: close()
    }

    Component {
        id: deviceDetailPage

        AppPage {
            property int deviceIndex
            property var device

            title: device.name

            Loader {
                id: loader
                anchors.centerIn: parent
                sourceComponent: (device.name === "Bulb" ? bulbSettings :
                                   device.name === "Thermostat" ? thermoSettings :
                                   device.name === "Plug" ? plugSettings :
                                   device.name === "Camera" ? cameraSettings : null)
                onLoaded:
                {
                    item.device = device
                }
            }
        }
    }

    // ---------- Per-type settings components ----------
    Component {
        id: bulbSettings
        ColumnLayout {
            property var device
            property int deviceIndex
            property int brightness: device.settings.brightness
            spacing: dp(8)
            AppText { text: "Brightness: " + brightness }
            AppSlider {
                from: 0; to: 100
                value: brightness
                onValueChanged:
                {
                    device.settings.brightness = value
                    brightness = value
                }
            }
        }
    }

    Component {
        id: thermoSettings
        ColumnLayout
        {
            property var device
            property int deviceIndex
            property int targetTemp: device.settings.targetTemp
            spacing: dp(8)
            AppText
            {
                Layout.alignment: Qt.AlignHCenter
                text: "Current temperature: " + device.settings.currentTemp + "°C"
            }
            AppText
            {
                id: targetT
                Layout.alignment: Qt.AlignHCenter
                text: "Target temperature: " + targetTemp + "°C"
            }
            AppSlider
            {
                Layout.alignment: Qt.AlignHCenter
                from: 18; to: 30; stepSize: 1
                value: targetTemp
                onValueChanged:
                {
                    device.settings.targetTemp = value
                    targetTemp = value
                }
            }
        }
    }

    Component {
        id: plugSettings
        ColumnLayout
        {
            property var device
            property int deviceIndex
            spacing: dp(8)
            AppSwitch
            {
                id: switchX
                Layout.alignment: Qt.AlignHCenter
                checked: device.settings.status
                onCheckedChanged:
                {
                    device.settings.status = checked
                }
            }
            AppText
            {
                Layout.alignment: Qt.AlignHCenter
                text: switchX.checked ? "On" : "Off"
            }
        }
    }

    Component
    {
        id: cameraSettings
        ColumnLayout
        {
            property var device
            property int deviceIndex
            spacing: dp(8)
            AppSwitch
            {
                id: switchX
                Layout.alignment: Qt.AlignHCenter
                checked: device.settings.status
                onCheckedChanged:
                {
                    device.settings.status = checked
                }
            }
            AppText
            {
                Layout.alignment: Qt.AlignHCenter
                text: switchX.checked ? "Recording" : "Idle"
            }
        }
    }

    TabControl
    {
        id: tabBar
        tabPosition: TabBar.Footer
        NavigationItem
        {
            iconType: IconType.home
            title: "Home"

            NavigationStack
            {
                id: stack
                navigationBar.visible: depth > 1
                initialPage: homeView
                onDepthChanged:
                {
                    if (depth > 1)
                    {
                        tabBar.barHeight = 0
                    }
                    else
                    {
                        tabBar.barHeight = Theme.tabBar.height
                    }
                }

                AppPage
                {
                    id: homeView
                    backgroundColor: "black"
                    navigationBarHidden: true

                    AppText
                    {
                        anchors.centerIn: parent
                        visible: devices.count === 0
                        text: "No devices added yet"
                        color: "#888"
                    }

                    Flickable
                    {
                        id: flicky
                        anchors.fill: parent
                        contentWidth: parent.width
                        contentHeight: flow.implicitHeight

                        Flow
                        {
                            id: flow
                            width: parent.width
                            spacing: dp(8)
                            anchors.centerIn: parent

                            Repeater {
                                id: deviceRepeater
                                model: devices
                                delegate: MouseArea {
                                    id: delegateRoot

                                    property int visualIndex: index

                                    width: (app.screenWidth / 2) - (flow.spacing / 2)
                                    height: width / 2
                                    drag.target: deviceItem
                                    onPressAndHold: {
                                        removeDialog.deviceIndex = index
                                        removeDialog.open()
                                    }
                                    onClicked: {
                                        stack.push(deviceDetailPage, { deviceIndex: index, device: devices.get(index) })
                                    }

                                    Rectangle {
                                        id: deviceItem
                                        width: delegateRoot.width
                                        height: delegateRoot.height
                                        anchors {
                                            horizontalCenter: delegateRoot.horizontalCenter;
                                            verticalCenter: delegateRoot.verticalCenter
                                        }
                                        radius: dp(15)
                                        color: "#151515"
                                        border.color: "#aaa"

                                        ColumnLayout {
                                            anchors.centerIn: parent
                                            spacing: dp(4)
                                            AppIcon {
                                                Layout.alignment: Qt.AlignHCenter
                                                iconType: model.icon
                                                size: dp(32)
                                            }
                                            AppText {
                                                Layout.alignment: Qt.AlignHCenter
                                                text: model.name
                                                font.pixelSize: sp(14)
                                            }
                                        }

                                        Drag.active: delegateRoot.drag.active
                                        Drag.source: delegateRoot
                                        Drag.hotSpot.x: width / 2
                                        Drag.hotSpot.y: height / 2

                                        states: [
                                            State {
                                                when: deviceItem.Drag.active
                                                ParentChange {
                                                    target: deviceItem
                                                    parent: flicky
                                                }

                                                AnchorChanges {
                                                    target: deviceItem;
                                                    anchors.horizontalCenter: undefined;
                                                    anchors.verticalCenter: undefined
                                                }
                                            }
                                        ]
                                    }

                                    DropArea {
                                        anchors { fill: parent; margins: 15 }

                                        onEntered: function(drag)
                                        {
                                            let from = drag.source.visualIndex
                                            let to = delegateRoot.visualIndex
                                            devices.move(from, to, 1)
                                            for(let i = 0; i < devices.count; i++)
                                            {
                                                deviceStorage.setValue(i, devices.get(i))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        NavigationItem {
            iconType: IconType.pluscircle
            title: "Add"

            Rectangle {
                id: addView
                color: "black"
                AppListView {
                    anchors.fill: parent
                    model: [
                        { name: qsTr("Plug"),       icon: IconType.plug,        settings:{status: false} },
                        { name: qsTr("Bulb"),       icon: IconType.lightbulbo,  settings:{status: false, brightness: 100} },
                        { name: qsTr("Thermostat"), icon: "\uf2c9",             settings:{status: false, currentTemp: 25, targetTemp: 20} },
                        { name: qsTr("Camera"),     icon: IconType.videocamera, settings:{status: false} }
                    ]

                    delegate: SimpleRow {
                        text: modelData.name
                        iconSource: modelData.icon
                        onSelected: {
                            let item = { name: modelData.name, icon: modelData.icon, settings: modelData.settings }
                            devices.append(item)
                            deviceStorage.setValue("count", devices.count)
                            deviceStorage.setValue(devices.count - 1, item)
                            tabBar.currentIndex = 0
                        }
                    }
                }
            }
        }
        NavigationItem {
            iconType: IconType.user
            title: "Account"

            Rectangle {
                id: accountView
                color: "black"
                AppListView {
                    anchors.fill: parent
                    model: [
                        { text: "Username: johndoe" },
                        { text: "Email: john@example.com" },
                        { text: "Subscription: Premium" }
                    ]

                    delegate: SimpleRow {
                        text: modelData.text
                    }
                }
            }
        }
    }
}
