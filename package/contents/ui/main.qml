import QtQuick 2.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents


Item {
    id: root


    Plasmoid.compactRepresentation: ClockLabel { }
    Plasmoid.fullRepresentation: ClockLabel { }
}
