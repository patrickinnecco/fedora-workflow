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
    // The part of the drop area to highlight; the whole area by default.
    property Item highlightItem: dropArea

    // Only moves make sense: a panel item dropped on the panel (or a drawer
    // item on the drawer) keeps its current placement.
    readonly property bool applicable: root.draggedItemId !== ""
        && root.draggedFromDrawer === (placement === "panel")

    keys: [root.drawerItemMimeType]
    enabled: root.canMoveItems

    onDropped: drop => {
        if (!applicable) {
            drop.accepted = false;
            return;
        }
        root.setPlacement(root.draggedItemId, dropArea.placement);
        drop.accept(Qt.MoveAction);
    }

    Rectangle {
        readonly property point origin: {
            // Re-evaluated on every drag move, as the highlighted item can
            // move while the panel makes room for the dropped icon.
            void dropArea.drag.x;
            return dropArea.highlightItem === dropArea
                ? Qt.point(0, 0)
                : dropArea.mapFromItem(dropArea.highlightItem, 0, 0);
        }

        x: origin.x
        y: origin.y
        width: dropArea.highlightItem.width
        height: dropArea.highlightItem.height
        radius: Kirigami.Units.cornerRadius
        color: Kirigami.Theme.highlightColor
        opacity: dropArea.containsDrag && dropArea.applicable ? 0.3 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Kirigami.Units.shortDuration
            }
        }
    }
}
