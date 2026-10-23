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
    // Follow the panel's actual animation value instead of starting another animation.
    readonly property var panelRoot: {
        let item = root.parent
        while (item) {
            if (typeof item.floatingness === "number"
                    && typeof item.floatingnessTarget === "number"
                    && typeof item.floatingnessAnimationDuration === "number") {
                return item
            }
            item = item.parent
        }
        return null
    }
    readonly property real floatingProgress: panelRoot ? panelRoot.floatingness : (desktopVisible ? 1 : 0)

    // A fixed logical width keeps the button narrow even on a tall panel.
    implicitWidth: 8
    Layout.minimumWidth: 8
    Layout.preferredWidth: 8
    Layout.maximumWidth: 8

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    Rectangle {
        width: 1
        // Plasma can draw in the right margin but cannot route clicks there.
        // Keep pointer inside the applet, to the left of this divider.
        // Keep the separator near the hit area, with one pixel of breathing room.
        x: Math.round(root.width + 1 - 2 * root.floatingProgress)
        y: Math.round(-root.panelPadding * (1 - root.floatingProgress))
        height: Math.round(root.height + 2 * root.panelPadding * (1 - root.floatingProgress))
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
