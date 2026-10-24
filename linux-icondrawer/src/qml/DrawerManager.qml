/*
    SPDX-FileCopyrightText: 2026 Patrick Innecco

    SPDX-License-Identifier: GPL-2.0-or-later
*/
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kitemmodels as KItemModels
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

// Lists the items currently shown in the panel or in the drawer and moves
// them with one click. Only placement changes here: enabling or disabling an
// item stays in the System Tray settings, so nothing disappears by accident.
PlasmaComponents3.ScrollView {
    id: manager

    background: null

    ListView {
        id: itemsList

        clip: true
        spacing: Kirigami.Units.smallSpacing
        reuseItems: true

        model: KItemModels.KSortFilterProxyModel {
            filterRoleName: "effectiveStatus"
            filterRowCallback: (sourceRow, sourceParent) => {
                const value = sourceModel.data(sourceModel.index(sourceRow, 0, sourceParent), filterRole);
                return value === PlasmaCore.Types.ActiveStatus || value === PlasmaCore.Types.PassiveStatus;
            }
            Component.onCompleted: sourceModel = Plasmoid.systemTrayModel // avoid unnecessary binding, it causes loops
        }

        delegate: RowLayout {
            id: row

            required property var decoration
            required property string displayText
            required property string itemId

            readonly property string placement: root.placementOf(itemId)

            width: ListView.view.width
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                Layout.leftMargin: Kirigami.Units.smallSpacing
                implicitWidth: Kirigami.Units.iconSizes.smallMedium
                implicitHeight: Kirigami.Units.iconSizes.smallMedium
                source: row.decoration
            }

            PlasmaComponents3.Label {
                Layout.fillWidth: true
                text: row.displayText || row.itemId
                textFormat: Text.PlainText
                elide: Text.ElideRight
            }

            Repeater {
                model: [
                    { "value": "panel", "text": i18nc("@action:button place this item in the panel", "Panel"), "tip": i18nc("@info:tooltip", "Always show in the panel") },
                    { "value": "drawer", "text": i18nc("@action:button place this item in the drawer", "Drawer"), "tip": i18nc("@info:tooltip", "Show only in the drawer") },
                    { "value": "auto", "text": i18nc("@action:button let the app decide where this item is shown", "Auto"), "tip": i18nc("@info:tooltip", "Show in the panel when relevant") },
                ]

                delegate: PlasmaComponents3.ToolButton {
                    required property var modelData

                    text: modelData.text
                    checkable: true
                    checked: row.placement === modelData.value
                    enabled: root.canMoveItems
                    onClicked: {
                        root.setPlacement(row.itemId, modelData.value);
                        checked = Qt.binding(() => row.placement === modelData.value);
                    }

                    PlasmaComponents3.ToolTip {
                        text: parent.modelData.tip
                    }
                }
            }
        }

        footer: PlasmaComponents3.Label {
            width: ListView.view.width
            topPadding: Kirigami.Units.largeSpacing
            leftPadding: Kirigami.Units.smallSpacing
            rightPadding: Kirigami.Units.smallSpacing
            wrapMode: Text.Wrap
            opacity: 0.7
            text: root.canMoveItems
                ? i18n("You can also drag icons between the panel and the drawer. Inactive or disabled items are managed in the System Tray settings.")
                : i18n("\"Always show all\" is enabled in the settings, so items cannot be moved to the drawer.")
        }
    }
}
