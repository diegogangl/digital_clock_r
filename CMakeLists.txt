cmake_minimum_required(VERSION 2.8.12)

project(plasma-digital_clock_r)
 
find_package(ECM 1.4.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR})

find_package(KF5Plasma REQUIRED)

plasma_install_package(package org.kde.digital_clock_r)
