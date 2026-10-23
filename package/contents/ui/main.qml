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
    readonly property var panelWindow: root.Window.window
    readonly property var panelScreen: {
        for (const candidate of Qt.application.screens) {
            if (candidate.name === root.Screen.name) {
                return candidate
            }
        }
        return Qt.application.screens.length ? Qt.application.screens[0] : null
    }
    readonly property rect screenGeometry: panelScreen
        ? Qt.rect(panelScreen.virtualX, panelScreen.virtualY,
            panelScreen.width, panelScreen.height) : Qt.rect(0, 0, 0, 0)
    readonly property point hitScenePosition: root.mapToItem(null, divider.x + divider.width, divider.y)
    readonly property int hitRightMargin: panelWindow
        ? Math.max(0, Math.round(screenGeometry.x + screenGeometry.width
            - panelWindow.x - hitScenePosition.x - 8)) : 0
    readonly property int hitBottomMargin: panelWindow
        ? Math.max(0, Math.round(screenGeometry.y + screenGeometry.height
            - panelWindow.y - hitScenePosition.y - divider.height)) : 0

    // A fixed logical width keeps the button narrow even on a tall panel.
    implicitWidth: 8
    Layout.minimumWidth: 8
    Layout.preferredWidth: 8
    Layout.maximumWidth: 8

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    Rectangle {
        id: divider
        width: 1
        // Preserve the separator's position and the panel's own animation.
        x: Math.round(root.width + 1 - 2 * root.floatingProgress)
        y: Math.round(-root.panelPadding * (1 - root.floatingProgress))
        height: Math.round(root.height + 2 * root.panelPadding * (1 - root.floatingProgress))
        color: Kirigami.Theme.textColor
        opacity: edgePointer.containsMouse ? 0.42 : 0.25
    }

    Window {
        id: hitWindow
        // The panel does not route input in its outer margin. This transparent
        // surface receives clicks to the right of the separator only.
        width: 8
        height: Math.max(1, divider.height)
        visible: !!root.panelWindow && !!root.panelScreen
            && root.panelWindow.visible && root.height > 0
        screen: root.panelScreen
        color: "transparent"
        flags: Qt.FramelessWindowHint | Qt.WindowDoesNotAcceptFocus

        LayerShell.Window.anchors: LayerShell.Window.AnchorBottom | LayerShell.Window.AnchorRight
        LayerShell.Window.layer: LayerShell.Window.LayerOverlay
        LayerShell.Window.scope: "linux-showdesktop-hit-area"
        LayerShell.Window.exclusionZone: -1
        LayerShell.Window.keyboardInteractivity: LayerShell.Window.KeyboardInteractivityNone
        LayerShell.Window.margins.right: root.hitRightMargin
        LayerShell.Window.margins.bottom: root.hitBottomMargin

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
