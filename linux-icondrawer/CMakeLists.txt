# SPDX-FileCopyrightText: 2026 Patrick Innecco
# SPDX-License-Identifier: GPL-2.0-or-later

cmake_minimum_required(VERSION 3.22)

project(linux-icondrawer VERSION 1.0)

set(QT_MIN_VERSION "6.8.0")
set(KF6_MIN_VERSION "6.18.0")
set(PLASMA_MIN_VERSION "6.7.0")

find_package(ECM ${KF6_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMQtDeclareLoggingCategory)
include(ECMQmlModule)
include(FeatureSummary)

find_package(Qt6 ${QT_MIN_VERSION} CONFIG REQUIRED COMPONENTS DBus Gui Quick Widgets)
find_package(Qt6GuiPrivate ${QT_MIN_VERSION} CONFIG REQUIRED)
find_package(KF6 ${KF6_MIN_VERSION} REQUIRED COMPONENTS
    Config
    IconThemes
    I18n
    KIO
    JobWidgets
    Service
    ItemModels
    WindowSystem
    XmlGui
    StatusNotifierItem
)
find_package(Plasma ${PLASMA_MIN_VERSION} REQUIRED)
find_package(PlasmaQuick ${PLASMA_MIN_VERSION} REQUIRED)

find_package(X11)
set(HAVE_X11 ${X11_FOUND})
configure_file(config-X11.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config-X11.h)

add_subdirectory(third_party/libdbusmenuqt)
add_subdirectory(src)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)
