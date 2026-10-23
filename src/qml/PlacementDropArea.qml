/*
    SPDX-FileCopyrightText: 2026 Patrick Innecco

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick

import org.kde.kirigami as Kirigami

// Accepts items dragged from the panel or the drawer and stores their
// placement in the native System Tray configuration.
DropArea {
    id: dropArea

    // "panel" or "drawer"
    required property string placement

    keys: [root.drawerItemMimeType]
    enabled: root.canMoveItems

    onDropped: drop => {
        const itemId = drop.getDataAsString(root.drawerItemMimeType);
        if (!itemId) {
            return;
        }
        root.setPlacement(itemId, dropArea.placement);
        drop.accept(Qt.MoveAction);
    }

    Rectangle {
        anchors.fill: parent
        radius: Kirigami.Units.cornerRadius
        color: Kirigami.Theme.highlightColor
        opacity: dropArea.containsDrag ? 0.3 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Kirigami.Units.shortDuration
            }
        }
    }
}
