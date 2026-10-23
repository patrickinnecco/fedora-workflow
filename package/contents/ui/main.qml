import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kwindowsystem as KWindowSystem
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    readonly property bool desktopVisible: KWindowSystem.KWindowSystem.showingDesktop
    // The current panel has eight pixels above and below its applet row.
    readonly property int panelPadding: 8

    // A fixed logical width keeps the button narrow even on a tall panel.
    implicitWidth: 8
    Layout.minimumWidth: 8
    Layout.preferredWidth: 8
    Layout.maximumWidth: 8

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    Rectangle {
        anchors.fill: parent
        color: Kirigami.Theme.highlightColor
        opacity: pointer.containsMouse ? (pointer.pressed ? 0.24 : 0.12) : 0

        Behavior on opacity {
            NumberAnimation { duration: 120 }
        }
    }

    Rectangle {
        width: 1
        // Plasma can draw in the right margin but cannot route clicks there.
        // Keep pointer inside the applet, to the left of this divider.
        x: root.desktopVisible ? root.width - 1 : root.width + 8
        y: root.desktopVisible ? 0 : -root.panelPadding
        height: root.desktopVisible ? root.height : root.height + 2 * root.panelPadding
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
}
