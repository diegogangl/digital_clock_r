/***************************************************************************
 *   Copyright (C) %{CURRENT_YEAR} by %{AUTHOR} <%{EMAIL}>                            *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents


Rectangle {
    id: main

    // Internal
    property string timeFormat


    // Settings (placehodlers)
    property bool showSeconds: false
    property bool show24hs: true
    property bool showDate: true
    property bool showTimezone: true
    property bool showTZCode: true
    property double fontScale: 1


    color: "red"

    states: [
        State {
            name: "planar"
            when: plasmoid.formFactor == PlasmaCore.Types.Planar

            PropertyChanges {
                target: main

                Layout.minimumHeight: clock.minimumPixelSize
                Layout.minimumWidth: clock.paintedWidth
            }

            PropertyChanges {
                target: clock

                fontSizeMode: Text.Fit
                font.pixelSize: 1024
            }

        },

        State {
            name: "horizontal"
            when: plasmoid.formFactor == PlasmaCore.Types.Horizontal

            PropertyChanges {
                target: main

                Layout.fillHeight: true
                Layout.minimumWidth: clock.paintedWidth
            }

            PropertyChanges {
                target: clock

                font.pixelSize: parent.height * (fontScale / lineCount)
                lineHeight: 1 / Math.max(1, lineCount)
            }
        }
    ]


    PlasmaCore.DataSource {
        id: dataSource
        engine: "time"
        connectedSources: ["Local"]
        interval: showSeconds ? 1000 : 60000
        intervalAlignment: PlasmaCore.Types.NoAlignment
    }


    PlasmaComponents.Label {
        id: clock
        text: '--:--'
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        minimumPixelSize: theme.smallestFont.pixelSize
        font.family: theme.defaultFont.family

        anchors.fill: parent
    }

    /**
     * This function updates the label's text. It's called when time
     * (dataSource) is updated, every minute or second (according to settings)
     */
    function refreshClock() {
        clock.text = new Date().toLocaleString(Qt.locale(), timeFormat);
    }


    /**
     * This function updates the time and date format strings. It's called
     * anytime settings change
     */
    function refreshFormat() {
        timeFormat = "hh:mm"

        if (showSeconds) timeFormat += ':ss';
        if (!show24hs) timeFormat += ' ap';

        if (showTimezone) {
            var tz = showTZCode ? '-00' : 'timezone'
            timeFormat += showDate ? " '(" + tz +")'" : "\n'" + tz + "'"
        }

        if (showDate) {
            timeFormat += '\n' + Qt.locale().dateFormat(Locale.LongFormat)
        }
    }

    Component.onCompleted: {
        refreshFormat();
        refreshClock();
        dataSource.onDataChanged.connect(refreshClock);
    }
}
