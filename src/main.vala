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
	
	
		private SearchWindow search_window;
		private ConnectDialog connect_dialog;
		private SystemTrayIcon tray_icon;
		private UserPasswordAuthenticationDialog authentication_dialog;
		
		private DBus.Client.Barabas barabas;
	
		public Main()
		{
			tray_icon = new SystemTrayIcon();
			tray_icon.activate_search_window.connect(on_search_window);
			
			// TODO: make the path installable.
			Gtk.Builder builder = new Gtk.Builder();
			builder.add_from_file("../share/barabas-gtk.ui");
			
			barabas = DBus.Client.Connection.get_barabas();
			barabas.user_password_authentication_request.connect(on_user_password_authentication_request);
			barabas.enable_authentication_method("user-password");
			
			connect_dialog = new ConnectDialog(builder);
			GLib.Idle.add(() => { connect_dialog.run(); return false; });
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
				builder.add_from_file("../share/barabas-gtk.ui");
			
				search_window = new SearchWindow(builder);
			}
			search_window.toggle_show();
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
			
			// TODO: make the path installable.
			Gtk.Builder builder = new Gtk.Builder();
			builder.add_from_file("../share/barabas-gtk.ui");
			authentication_dialog = new UserPasswordAuthenticationDialog(builder);
			authentication_dialog.run();
		}
	}
}
