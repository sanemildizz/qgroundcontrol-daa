message(STATUS "QGC: Adding UAV DAA visualization overlay")

# ---------------------------------------------------------------------------
# QML override
# ---------------------------------------------------------------------------

set(CUSTOM_QML_OVERRIDES
    "${CMAKE_CURRENT_SOURCE_DIR}/src/FlyViewCustomLayer.qml"
)

set_source_files_properties(
    "${CMAKE_CURRENT_SOURCE_DIR}/src/FlyViewCustomLayer.qml"
    PROPERTIES
        QT_RESOURCE_ALIAS
        "QGroundControl/FlyView/FlyViewCustomLayer.qml"
)

qt_add_resources(
    ${CMAKE_PROJECT_NAME}
    daa_qml_overrides
    PREFIX "/Custom/qml"
    FILES ${CUSTOM_QML_OVERRIDES}
)

# ---------------------------------------------------------------------------
# Minimal core plugin used only to redirect standard QML resources to
# resources supplied by this custom overlay when an override exists.
# ---------------------------------------------------------------------------

set(
    CUSTOM_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/src/DAACorePlugin.cc"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/DAACorePlugin.h"
    PARENT_SCOPE
)

set(
    CUSTOM_INCLUDE_DIRECTORIES
    "${CMAKE_CURRENT_SOURCE_DIR}/src"
    PARENT_SCOPE
)

set(
    CUSTOM_DEFINITIONS
    QGC_CUSTOM_BUILD
    CUSTOMHEADER="DAACorePlugin.h"
    CUSTOMCLASS=DAACorePlugin
    PARENT_SCOPE
)
