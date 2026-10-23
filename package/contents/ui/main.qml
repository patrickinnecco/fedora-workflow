import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import org.kde.kirigami as Kirigami
import org.kde.kwindowsystem as KWindowSystem
import org.kde.layershell as LayerShell
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    readonly property int bottomInset: root.Window.window
        ? Math.max(0, Math.round((root.Window.window.height - root.height) / 2))
        : 0

    // A fixed logical width keeps the button narrow even on a tall panel.
    implicitWidth: 8
    Layout.minimumWidth: 8
    Layout.preferredWidth: 8
    Layout.maximumWidth: 8

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    Rectangle {
        anchors.fill: parent
        visible: !edgeWindow.visible
        color: Kirigami.Theme.highlightColor
        opacity: pointer.containsMouse ? (pointer.pressed ? 0.24 : 0.12) : 0

        Behavior on opacity {
            NumberAnimation { duration: 120 }
        }
    }

    Rectangle {
        width: 1
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        visible: !edgeWindow.visible
        color: Kirigami.Theme.textColor
        opacity: pointer.containsMouse ? 0.42 : 0.25
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        Accessible.role: Accessible.Button
        Accessible.name: qsTr("Show Desktop")
        Accessible.description: qsTr("Show the desktop or restore the windows")

        onClicked: KWindowSystem.KWindowSystem.showingDesktop = !KWindowSystem.KWindowSystem.showingDesktop
    }

    // A layer surface keeps the physical edge clickable on Wayland. Plasma's
    // own panel input region excludes its outer padding, so drawing outside
    // the applet alone cannot provide a working button there.
    Window {
        id: edgeWindow
        width: 8
        height: Math.max(1, root.height)
        visible: !!root.Window.window && root.Window.window.visible && root.height > 0
        color: "transparent"
        flags: Qt.FramelessWindowHint | Qt.WindowDoesNotAcceptFocus

        LayerShell.Window.anchors: LayerShell.Window.AnchorBottom | LayerShell.Window.AnchorRight
        LayerShell.Window.layer: LayerShell.Window.LayerOverlay
        LayerShell.Window.scope: "scadutree-showdesktop"
        LayerShell.Window.exclusionZone: -1
        LayerShell.Window.keyboardInteractivity: LayerShell.Window.KeyboardInteractivityNone
        LayerShell.Window.margins.bottom: root.bottomInset
        LayerShell.Window.margins.right: KWindowSystem.KWindowSystem.showingDesktop ? 8 : 0

        Rectangle {
            anchors.fill: parent
            color: Kirigami.Theme.highlightColor
            opacity: edgePointer.containsMouse ? (edgePointer.pressed ? 0.24 : 0.12) : 0

            Behavior on opacity {
                NumberAnimation { duration: 120 }
            }
        }

        Rectangle {
            width: 1
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            color: Kirigami.Theme.textColor
            opacity: edgePointer.containsMouse ? 0.42 : 0.25
        }

        MouseArea {
            id: edgePointer
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            Accessible.role: Accessible.Button
            Accessible.name: qsTr("Show Desktop")
            Accessible.description: qsTr("Show the desktop or restore the windows")

            onClicked: KWindowSystem.KWindowSystem.showingDesktop = !KWindowSystem.KWindowSystem.showingDesktop
        }
    }
}
