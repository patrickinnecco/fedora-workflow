import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import org.kde.kirigami as Kirigami
import org.kde.kwindowsystem as KWindowSystem
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    // A fixed logical width keeps the button narrow even on a tall panel.
    implicitWidth: 8
    Layout.minimumWidth: 8
    Layout.preferredWidth: 8
    Layout.maximumWidth: 8

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    // Plasma reserves a small margin after the last applet. When this applet
    // is next to the window edge, place its eight-pixel hit target in that
    // margin. In any other position it stays inside its normal layout cell.
    readonly property real edgeExtension: {
        const window = Window.window
        if (!window || !root.parent) {
            return 0
        }
        // Keep the binding updated when the panel layout moves the applet.
        const layoutPosition = root.x + root.parent.x + window.width
        const gap = window.width - root.mapToItem(null, root.width, 0).x
        return layoutPosition >= 0 && gap >= 0 && gap <= 20 ? gap : 0
    }

    Rectangle {
        x: root.edgeExtension
        width: root.width
        height: root.height
        color: Kirigami.Theme.highlightColor
        opacity: pointer.containsMouse ? (pointer.pressed ? 0.24 : 0.12) : 0

        Behavior on opacity {
            NumberAnimation { duration: 120 }
        }
    }

    Rectangle {
        width: 1
        x: root.edgeExtension
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: Kirigami.Theme.textColor
        opacity: pointer.containsMouse ? 0.42 : 0.25
    }

    MouseArea {
        id: pointer
        x: root.edgeExtension
        width: root.width
        height: root.height
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        Accessible.role: Accessible.Button
        Accessible.name: qsTr("Show Desktop")
        Accessible.description: qsTr("Show the desktop or restore the windows")

        onClicked: KWindowSystem.KWindowSystem.showingDesktop = !KWindowSystem.KWindowSystem.showingDesktop
    }
}
