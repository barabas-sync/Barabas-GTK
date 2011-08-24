/**
    This file is part of Barabas GTK.

	Copyright (C) 2011 Nathan Samson
 
    Barabas GTK is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Barabas GTK is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Barabas GTK.  If not, see <http://www.gnu.org/licenses/>.
*/

namespace Barabas.GtkFace
{
	class Main
	{
		public static void main(string[] args)
		{
			Gtk.init(ref args);
			Main app = new Main();
			app.start();
		}
	
		private static string ui_file = null;
	
		private SearchWindow search_window;
		private ConnectDialog connect_dialog;
		private SystemTrayIcon tray_icon;
		private UserPasswordAuthenticationDialog authentication_dialog;
		
		private DBus.Client.Barabas barabas;
	
		public Main()
		{
			barabas = DBus.Client.Connection.get_barabas();
		
			tray_icon = new SystemTrayIcon(barabas, find_ui_file());
			tray_icon.activate_search_window.connect(on_search_window);
			tray_icon.activate_connect.connect(on_connect);
			tray_icon.activate_disconnect.connect(on_disconnect);
			tray_icon.activate_quit.connect(on_quit);
			
			Gtk.Builder builder = new Gtk.Builder();
			builder.add_from_file(find_ui_file());
			
			barabas.user_password_authentication_request.connect(on_user_password_authentication_request);
			barabas.enable_authentication_method("user-password");
			barabas.status_changed.connect(on_server_status_changed);
			
			connect_dialog = new ConnectDialog(builder);
			
			if (barabas.get_status() == DBus.Client.ConnectionStatus.NOT_CONNECTED ||
			    barabas.get_status() == DBus.Client.ConnectionStatus.DISCONNECTED)
			{
				GLib.Idle.add(() => { connect_dialog.run(); return false; });
			}
		}
		
		public void start()
		{
			Gtk.main();
		}
		
		public void on_search_window()
		{
			if (search_window == null)
			{
				// TODO: make the path installable.
				Gtk.Builder builder = new Gtk.Builder();
				builder.add_from_file(find_ui_file());
			
				search_window = new SearchWindow(builder);
			}
			search_window.toggle_show();
		}
		
		private void on_connect()
		{
			if (!connect_dialog.is_running)
			{
				connect_dialog.run();
			}
		}
		
		private void on_disconnect()
		{
			barabas.disconnect();
		}
		
		private void on_quit()
		{
			Gtk.main_quit();
		}
		
		private void on_server_status_changed(string hostname,
		                                      DBus.Client.ConnectionStatus status)
		{
			if (status == DBus.Client.ConnectionStatus.CONNECTED)
			{
				stdout.printf("Connected to %s\n", hostname);
			}
			else if (status == DBus.Client.ConnectionStatus.CONNECTING)
			{
				stdout.printf("Connecting to %s\n", hostname);
			}
			else if (status == DBus.Client.ConnectionStatus.AUTHENTICATING)
			{
				stdout.printf("Authenticating to %s\n", hostname);
			}
			else if (status == DBus.Client.ConnectionStatus.DISCONNECTED)
			{
				stdout.printf("Disconnected from %s\n", hostname);
			}
		}
		
		private void on_user_password_authentication_request()
		{
			connect_dialog.hide();
			
			Gtk.Builder builder = new Gtk.Builder();
			builder.add_from_file(Main.find_ui_file());
			authentication_dialog = new UserPasswordAuthenticationDialog(builder);
			authentication_dialog.run();
		}
		
		private static string find_ui_file()
		{
			if (ui_file != null)
			{
				return ui_file;
			}
			string[] dirs = {"../share/", "/usr/share/barabas-gtk/"};
			
			foreach (string dir in dirs)
			{
				GLib.File test = GLib.File.new_for_path(dir + "barabas-gtk.ui");
				if (test.query_exists())
				{
					ui_file = dir + "barabas-gtk.ui";
					break;
				}
			}
			return ui_file;
		}
	}
}
