import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Window 2.3

Window
{
    visible: true
    title: qsTr("LetiHome")

    // this is set to native resolution on android
    width: 1920
    height: 1080

    // slightly transparent background
    color: "#aa000000"

    // load apps when component ready
    Component.onCompleted: all.model = __platform.applicationList()

    // when packages are changed (installed/removed) update list
    Connections
    {
        target: __platform
        onPackagesChanged: all.model = __platform.applicationList()
    }

    // wrapper item used for padding
    ColumnLayout
    {
        anchors.fill: parent
        anchors.margins: 20

        Text
        {
            id: clock
            anchors.right: parent.right
            font.pixelSize: 20
            font.italic: true
            color: "#ffffff"

            Timer
            {
                running: true
                repeat: true
                triggeredOnStart: true
                interval: 1000
                onTriggered: parent.text = __platform.time()
            }
        }

        // main application grid
        GridView
        {
           id: all

           boundsBehavior: GridView.StopAtBounds

           focus: true

           Layout.fillHeight: true
           Layout.preferredWidth: Math.min(model.length, Math.floor(parent.width/cellWidth)) * cellWidth
           anchors.horizontalCenter: parent.horizontalCenter

           cellWidth: Math.max(Math.min(160, Math.min(parent.width, parent.height) / 5), 80)
           cellHeight: cellWidth + 80

           highlight: Rectangle
           {
               color: "#cc000000"
               border.width: 2
               border.color: "#ccffffff"
               radius: 3
               scale: 1.1
           }

           highlightMoveDuration: 50

           // additional keys handling, default navigation is handled by gridview
           Keys.onPressed:
           {
               switch(event.key)
               {
                   case Qt.Key_Enter:
                   case Qt.Key_Return:
                       __platform.launchApplication(model[currentIndex].packageName)
                       event.accepted = true
                   break

                   case Qt.Key_Menu:
                       __platform.pickWallpaper()
                       event.accepted = true
                   break

                   // ignore back key as we do not want to minimize or exit launcher
                   case Qt.Key_Back:
                       event.accepted = true
                   break
               }
           }

           // enable click support
           delegate: MouseArea
           {
               property bool isCurrent: GridView.isCurrentItem
               acceptedButtons: Qt.LeftButton | Qt.RightButton

               width: GridView.view.cellWidth
               height: childrenRect.height

               // on left click open app, on right click open wallpaper picker
               onClicked: mouse.button === Qt.LeftButton
                          && __platform.launchApplication(modelData.packageName)
                          || __platform.pickWallpaper()

               Image
               {
                   id: icon
                   source: "image://icon/" + modelData.packageName
                   width: parent.width - x * 2
                   height: width
                   asynchronous: true
                   fillMode: Image.PreserveAspectFit
                   x: 15
               }

               Text
               {
                   id: applicationName
                   text: modelData.applicationName
                   color: "#ffffff"
                   style: Text.Outline
                   width: parent.width
                   wrapMode: Label.WordWrap
                   elide: Label.ElideRight
                   horizontalAlignment: Label.AlignHCenter
                   font.bold: isCurrent
                   anchors.top: icon.bottom
                   anchors.topMargin: 5
               }
           }
        }
    }
}
