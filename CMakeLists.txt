cmake_minimum_required(VERSION 2.6)
project(barabas-gtk)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/vala)

find_package(Vala REQUIRED)

find_package(PkgConfig)
pkg_check_modules(GTK REQUIRED gtk+-3.0 glib-2.0>=2.28 gio-2.0>=2.28 gmodule-2.0 gee-1.0)
add_definitions(${GTK_CFLAGS} ${GTK_CFLAGS_OTHER} -g)
link_libraries(${GTK_LIBRARIES})
link_directories(${GTK_LIBRARY_DIRS})

include(ValaPrecompile)
vala_precompile(BARABAS_GTK_C
                         src/main.vala
                         src/system_tray.vala
                         src/search_window.vala
                         
                         lib/dbus_connection.vala
                         lib/barabas.vala
                         lib/file_info.vala
                         lib/synced_file.vala
                PACKAGES gtk+-3.0 glib-2.0 gio-2.0 gmodule-2.0 gee-1.0)

add_executable("barabas-gtk" ${BARABAS_GTK_C})
