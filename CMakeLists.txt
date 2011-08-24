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
                         src/connect_dialog.vala
                         src/download.vala
                         src/main.vala
                         src/system_tray.vala
                         src/search_window.vala
                         src/user_password_authentication_dialog.vala

                         lib/barabas.vala
                         lib/connection_status.vala
                         lib/dbus_connection.vala
                         lib/download.vala
                         lib/file_info.vala
                         lib/host_configuration.vala
                         lib/local_file.vala
                         lib/search.vala
                         lib/synced_file.vala
                         lib/synced_file_version.vala
                         lib/user_password_authentication.vala
                PACKAGES gtk+-3.0 glib-2.0 gio-2.0 gmodule-2.0 gee-1.0)

add_executable("barabas-gtk" ${BARABAS_GTK_C})

install(TARGETS barabas-gtk
                RUNTIME DESTINATION bin)
install(FILES share/barabas-gtk.ui
              DESTINATION ${CMAKE_INSTALL_PREFIX}/share/barabas-gtk)

INCLUDE(CPack)
# Package generic stuff
SET(CPACK_GENERATOR "RPM")
SET(CPACK_PACKAGE_NAME "barabas-gtk")
SET(CPACK_PACKAGE_VERSION "0.0.1")
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "The Barabas GTK Search program.")

# RPM / Fedora specific stuff
SET(CPACK_RPM_PACKAGE_REQUIRES "gtk3 >= 3.0, glib2 >= 2.28, libgee >= 0.6.1")
