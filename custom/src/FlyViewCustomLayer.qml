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

    // Project DAA visualization parameters
    readonly property real _protectedVolumeRadiusM: 152.4
    readonly property real _projectionHorizonS: 45.0

    property var _protectedVolumeCircle: null
    property var _projectedCircleSegments: []

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

    // ---------------------------------------------------------------------
    // Current protected-volume footprint
    // ---------------------------------------------------------------------

    Component {
        id: protectedVolumeCircleComponent

        MapCircle {
            center: _activeVehicle
                    ? _activeVehicle.coordinate
                    : QtPositioning.coordinate()

            radius: _protectedVolumeRadiusM

            visible:
                _activeVehicle &&
                _activeVehicle.coordinate.isValid

            color: Qt.rgba(0.15, 0.45, 0.85, 0.10)
            border.color: Qt.rgba(0.15, 0.45, 0.85, 0.90)
            border.width: 2
        }
    }

    // ---------------------------------------------------------------------
    // Segment used to construct the dashed projected footprint
    // ---------------------------------------------------------------------

    Component {
        id: projectedCircleSegmentComponent

        MapPolyline {
            line.width: 2
            line.color: Qt.rgba(0.15, 0.45, 0.85, 0.75)
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

    function installProjectedCircle() {
        if (!mapControl || _projectedCircleSegments.length > 0) {
            return
        }

        // 24 dash segments around the circumference.
        for (var i = 0; i < 24; ++i) {
            var segment =
                projectedCircleSegmentComponent.createObject(mapControl)

            if (segment) {
                mapControl.addMapItem(segment)
                _projectedCircleSegments.push(segment)
            }
        }

        updateProjectedCircle()
    }

    function updateProjectedCircle() {
        if (!_activeVehicle ||
            !_activeVehicle.coordinate.isValid ||
            _projectedCircleSegments.length === 0) {

            for (var j = 0; j < _projectedCircleSegments.length; ++j) {
                _projectedCircleSegments[j].visible = false
            }

            return
        }

        var groundSpeed =
            Number(_activeVehicle.groundSpeed.rawValue)

        var heading =
            Number(_activeVehicle.heading.value)

        if (!isFinite(groundSpeed) || !isFinite(heading)) {
            for (var k = 0; k < _projectedCircleSegments.length; ++k) {
                _projectedCircleSegments[k].visible = false
            }

            return
        }

        var projectionDistance =
            groundSpeed * _projectionHorizonS

        var projectedCenter =
            _activeVehicle.coordinate.atDistanceAndAzimuth(
                projectionDistance,
                heading
            )

        // Each 15-degree sector contains a 9-degree visible dash
        // followed by a 6-degree gap.
        var sectorAngle = 15.0
        var dashAngle = 9.0
        var pointsPerDash = 4

        for (var i = 0; i < _projectedCircleSegments.length; ++i) {
            var startAngle = i * sectorAngle
            var pathPoints = []

            for (var p = 0; p <= pointsPerDash; ++p) {
                var azimuth =
                    startAngle +
                    dashAngle * p / pointsPerDash

                pathPoints.push(
                    projectedCenter.atDistanceAndAzimuth(
                        _protectedVolumeRadiusM,
                        azimuth
                    )
                )
            }

            _projectedCircleSegments[i].path = pathPoints
            _projectedCircleSegments[i].visible = true
        }
    }

    function installMapItems() {
        installProtectedVolumeCircle()
        installProjectedCircle()
    }

    Timer {
        interval: 200
        running: true
        repeat: true

        onTriggered: {
            updateProjectedCircle()
        }
    }

    Component.onCompleted: {
        installMapItems()
    }

    onMapControlChanged: {
        installMapItems()
    }

    Component.onDestruction: {
        if (_protectedVolumeCircle && mapControl) {
            mapControl.removeMapItem(_protectedVolumeCircle)
            _protectedVolumeCircle.destroy()
            _protectedVolumeCircle = null
        }

        if (mapControl) {
            for (var i = 0; i < _projectedCircleSegments.length; ++i) {
                mapControl.removeMapItem(
                    _projectedCircleSegments[i]
                )

                _projectedCircleSegments[i].destroy()
            }
        }

        _projectedCircleSegments = []
    }
}
