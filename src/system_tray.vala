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

	class SystemTrayIcon
	{
		private string gtk_ui_file;	

		private Gtk.StatusIcon status_icon;
		private Gtk.Menu status_menu;
		
		private DBus.Client.Barabas barabas;
	
		public SystemTrayIcon(DBus.Client.Barabas barabas,
		                      string ui_file)
		{
			gtk_ui_file = ui_file;
			this.barabas = barabas;
		
			status_icon = new Gtk.StatusIcon.from_icon_name("folder-remote");
			status_icon.title = "Barabas";
			status_icon.visible = true;
			status_icon.activate.connect(on_clicked);
			status_icon.popup_menu.connect(on_menu);
			
			barabas.status_changed.connect(change_status);
			change_status("", barabas.get_status(), "");
		}
		
		private void change_status(string hostname,
		                           DBus.Client.ConnectionStatus status,
		                           string msg)
		{
			switch (status)
			{
				case DBus.Client.ConnectionStatus.NOT_CONNECTED:
					status_icon.tooltip_text = "Not connected";
					break;
				case DBus.Client.ConnectionStatus.CONNECTING:
					status_icon.tooltip_text = "Connecting...";
					break;
				case DBus.Client.ConnectionStatus.AUTHENTICATION_REQUEST:
				case DBus.Client.ConnectionStatus.AUTHENTICATING:
					status_icon.tooltip_text = "Authenticating";
					break;
				case DBus.Client.ConnectionStatus.AUTHENTICATION_FAILED:
					status_icon.tooltip_text = "Authentication failed";
					break;
				case DBus.Client.ConnectionStatus.CONNECTED:
					status_icon.tooltip_text = "Connected";
					break;
				case DBus.Client.ConnectionStatus.DISCONNECTED:
					status_icon.tooltip_text = "Disconnected";
					break;
			}
		}
		
		private void on_clicked(Gtk.StatusIcon src)
		{
			activate_search_window();
		}
		
		private void on_menu(uint button, uint time)
		{
			Gtk.Builder builder = new Gtk.Builder();
			builder.add_from_file(gtk_ui_file);
			builder.connect_signals(this);
			
			status_menu = builder.get_object("status_icon_menu") as Gtk.Menu;
			Gtk.MenuItem connect = builder.get_object("status_icon_menu_connect_menuitem") as Gtk.MenuItem;
			Gtk.MenuItem disconnect = builder.get_object("status_icon_menu_disconnect_menuitem") as Gtk.MenuItem;

			status_menu.show_all();
			if (barabas.get_status() == DBus.Client.ConnectionStatus.CONNECTED)
			{
				connect.hide();
			}
			else
			{
				disconnect.hide();
			}
			
			status_menu.popup(null, null, status_icon.position_menu, button, time);
		}
		
		[CCode (instance_pos = -1)]
		public void on_activate_search_menuitem(Gtk.MenuItem menu_item)
		{
			activate_search_window();
		}
		
		[CCode (instance_pos = -1)]
		public void on_activate_connect_menuitem(Gtk.MenuItem menu_item)
		{
			activate_connect();
		}
		
		[CCode (instance_pos = -1)]
		public void on_activate_disconnect_menuitem(Gtk.MenuItem menu_item)
		{
			activate_disconnect();
		}
		
		[CCode (instance_pos = -1)]
		public void on_activate_quit_menuitem(Gtk.MenuItem menu_item)
		{
			activate_quit();
		}
		
		public signal void activate_search_window();
		public signal void activate_connect();
		public signal void activate_disconnect();
		public signal void activate_quit();
	}
}
