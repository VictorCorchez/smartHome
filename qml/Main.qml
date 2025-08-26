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
    }

    Storage {
        id: deviceStorage
        databaseName: "deviceList"
    }

    onInitTheme:
    {
        Theme.colors.backgroundColor = "#191919"
        Theme.colors.secondaryBackgroundColor = "#191919"
        Theme.tabBar.backgroundColor = "#191919"
        Theme.tabBar.showIcon = true
        Theme.dialog.backgroundColor = "#191919"
        Theme.dialog.titleColor = "lightgrey"
        Theme.listItem.backgroundColor = "#191919"
        Theme.listItem.textColor = "white"
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
            }
            close()
        }
        onCanceled: close()
    }

    TabControl
    {
        id: tabBar
        tabPosition: QQC.TabBar.Footer
        NavigationItem {
            iconType: IconType.home
            title: "Home"

            Rectangle {
                id: homeView
                color: "black"

                AppText {
                    anchors.centerIn: parent
                    visible: devices.count === 0
                    text: "No devices added yet"
                    color: "#888"
                }

                Flickable {
                    id: flicky
                    anchors.fill: parent
                    contentWidth: parent.width
                    contentHeight: flow.implicitHeight

                    Flow {
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
                                drag.target: icon
                                onPressAndHold: {
                                    removeDialog.deviceIndex = index
                                    removeDialog.open()
                                }

                                Rectangle {
                                    id: icon
                                    width: delegateRoot.width
                                    height: delegateRoot.height
                                    anchors {
                                        horizontalCenter: delegateRoot.horizontalCenter;
                                        verticalCenter: delegateRoot.verticalCenter
                                    }
                                    radius: dp(15)
                                    color: "#f0f0f0"
                                    border.color: "#aaa"

                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: dp(4)
                                        AppIcon {
                                            Layout.alignment: Qt.AlignHCenter
                                            iconType: model.icon
                                            size: dp(32)
                                            color: "black"
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
                                            when: icon.Drag.active
                                            ParentChange {
                                                target: icon
                                                parent: flicky
                                            }

                                            AnchorChanges {
                                                target: icon;
                                                anchors.horizontalCenter: undefined;
                                                anchors.verticalCenter: undefined
                                            }
                                        }
                                    ]
                                }

                                DropArea {
                                    anchors { fill: parent; margins: 15 }

                                    onEntered:
                                    {
                                        devices.move(drag.source.visualIndex, delegateRoot.visualIndex, 1)
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
                        { name: qsTr("Plug"),       icon: IconType.plug },
                        { name: qsTr("Bulb"),       icon: IconType.lightbulbo },
                        { name: qsTr("Thermostat"), icon: "\uf2c9" },
                        { name: qsTr("Camera"),     icon: IconType.videocamera }
                    ]

                    delegate: SimpleRow {
                        text: modelData.name
                        iconSource: modelData.icon
                        onSelected: {
                            devices.append({ name: modelData.name, icon: modelData.icon })
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
