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


Item {
    id: main

    // Internal
    property string timeFormat
    property int longestLine


    // Settings (placehodlers)
    property bool showSeconds: true
    property bool show24hs: true
    property bool showDate: true
    property bool showTimezone: false
    property bool showTZCode: true
    property double fontScale: 1
    property var formatType: Locale.ShortFormat
    property string fontFamily: theme.defaultFont.family


    // Testing stuff
    //property var formatType: Locale.LongFormat
    //property string fontFamily: "Open Sans"
    //property string fontFamily: "SMD"
    //property string fontFamily: "Hexa"
    //property string fontFamily: "Inconsolata"
    //property string fontFamily: "Amaranth"
    //property string fontFamily: "Hack"
    //property string fontFamily: "Meslo LG S DZ"
    //property string fontFamily: "Fira Code"
    //color: "red"


    states: [
        State {
            name: "planar"
            when: plasmoid.formFactor == PlasmaCore.Types.Planar

            PropertyChanges {
                target: main

                Layout.minimumHeight: clock.minimumPixelSize
                Layout.minimumWidth: clock.paintedWidth
            }

            /**
             * No fancy formula here, the user can just resize the widget
             */
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

            /**
             * The formula for the font size here is h * (s/l)
             *
             * h -> the parent's height
             * s -> font scale (1..0)
             * l -> line count
             *
             * The line count change just looks good
             */
            PropertyChanges {
                target: clock

                font.pixelSize: parent.height * (fontScale / lineCount)
                lineHeight: lineCount > 1 ? 1: 0.75
            }
        },

        State {
            name: "vertical"
            when: plasmoid.formFactor == PlasmaCore.Types.Vertical

            PropertyChanges {
                target: main
            }

            /**
             * The formula for the font size here is (p / (c/2)) * s
             *
             * p -> the parent's width
             * c -> character count of the longest line
             * s -> font scale (1..0)
             */
            PropertyChanges {
                target: clock

                font.pixelSize: (parent.width / (longestLine / 2)) * fontScale
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

        anchors.fill: parent
        font.family: fontFamily
        minimumPixelSize: theme.smallestFont.pixelSize
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
            timeFormat += '\n' + Qt.locale().dateFormat(formatType)
        }
    }


    /**
     * This function updates the longest line for vertical layouts. It's
     * called everytime the format is changed (maybe when the date
     * changes too?).
     */
    function refreshLongestLineLength() {
        var lines = clock.text.split('\n');
        var diff = lines.sort(function (a, b) { return b.length - a.length; })
        var longest = diff[0];

        longestLine = longest.length;
    }


    Component.onCompleted: {
        refreshFormat();
        refreshClock();
        refreshLongestLineLength();
        dataSource.onDataChanged.connect(refreshClock);
    }
}
