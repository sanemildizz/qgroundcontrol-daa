import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import QtLocation
import QtPositioning
import QtQuick.Window
import QtQml.Models

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlyView
import QGroundControl.FlightMap

Item {
    id: _root

    property var parentToolInsets
    property var totalToolInsets: _toolInsets
    property var mapControl

    property var _activeVehicle:
        QGroundControl.multiVehicleManager.activeVehicle

    property var _protectedVolumeCircle: null

    QGCToolInsets {
        id: _toolInsets

        leftEdgeTopInset: parentToolInsets.leftEdgeTopInset
        leftEdgeCenterInset: parentToolInsets.leftEdgeCenterInset
        leftEdgeBottomInset: parentToolInsets.leftEdgeBottomInset

        rightEdgeTopInset: parentToolInsets.rightEdgeTopInset
        rightEdgeCenterInset: parentToolInsets.rightEdgeCenterInset
        rightEdgeBottomInset: parentToolInsets.rightEdgeBottomInset

        topEdgeLeftInset: parentToolInsets.topEdgeLeftInset
        topEdgeCenterInset: parentToolInsets.topEdgeCenterInset
        topEdgeRightInset: parentToolInsets.topEdgeRightInset

        bottomEdgeLeftInset: parentToolInsets.bottomEdgeLeftInset
        bottomEdgeCenterInset: parentToolInsets.bottomEdgeCenterInset
        bottomEdgeRightInset: parentToolInsets.bottomEdgeRightInset
    }

    Component {
        id: protectedVolumeCircleComponent

        MapCircle {
            center: _activeVehicle
                    ? _activeVehicle.coordinate
                    : QtPositioning.coordinate()

            radius: 152.4

            visible:
                _activeVehicle &&
                _activeVehicle.coordinate.isValid

            color: Qt.rgba(0.15, 0.45, 0.85, 0.10)
            border.color: Qt.rgba(0.15, 0.45, 0.85, 0.90)
            border.width: 2
        }
    }

    function installProtectedVolumeCircle() {
        if (!mapControl || _protectedVolumeCircle) {
            return
        }

        _protectedVolumeCircle =
            protectedVolumeCircleComponent.createObject(mapControl)

        if (_protectedVolumeCircle) {
            mapControl.addMapItem(_protectedVolumeCircle)
        }
    }

    Component.onCompleted: {
        installProtectedVolumeCircle()
    }

    onMapControlChanged: {
        installProtectedVolumeCircle()
    }

    Component.onDestruction: {
        if (_protectedVolumeCircle && mapControl) {
            mapControl.removeMapItem(_protectedVolumeCircle)
            _protectedVolumeCircle.destroy()
            _protectedVolumeCircle = null
        }
    }
}
