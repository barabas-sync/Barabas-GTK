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
		
		private DBus.Client.Barabas barabas;
		private Gtk.Menu status_menu;
		private Gtk.MenuItem connect_menuitem;
		private Gtk.MenuItem disconnect_menuitem;

		#if ENABLE_APPINDICATOR
			private AppIndicator.Indicator indicator;
		#else
			private Gtk.StatusIcon status_icon;
		#endif
	
		public SystemTrayIcon(DBus.Client.Barabas barabas,
		                      string ui_file)
		{
			gtk_ui_file = ui_file;
			this.barabas = barabas;
		
			#if ENABLE_APPINDICATOR
				stdout.printf("Using Ubuntu's stupid shit...\n");
				indicator = new AppIndicator.Indicator("be.ac.ua.comp.Barabas",
				                                       "barabas-search",
				                                       AppIndicator.IndicatorCategory.APPLICATION_STATUS);
				indicator.set_menu(create_menu());
				indicator.set_status(AppIndicator.IndicatorStatus.ACTIVE);
			#else
				stdout.printf("Alternative code path\n");
				status_icon = new Gtk.StatusIcon.from_icon_name("barabas-search");
				status_icon.title = "Barabas";
				status_icon.visible = true;
				status_icon.activate.connect(on_clicked);
				status_icon.popup_menu.connect(on_menu);
			#endif

			barabas.status_changed.connect(change_status);
			change_status("", barabas.get_status(), "");
		}
		
		private void change_status(string hostname,
		                           DBus.Client.ConnectionStatus status,
		                           string msg)
		{
			string label = "";
			switch (status)
			{
				case DBus.Client.ConnectionStatus.NOT_CONNECTED:
					label = "Not connected";
					break;
				case DBus.Client.ConnectionStatus.CONNECTING:
					label = "Connecting...";
					break;
				case DBus.Client.ConnectionStatus.AUTHENTICATION_REQUEST:
				case DBus.Client.ConnectionStatus.AUTHENTICATING:
					label = "Authenticating";
					break;
				case DBus.Client.ConnectionStatus.AUTHENTICATION_FAILED:
					label = "Authentication failed";
					break;
				case DBus.Client.ConnectionStatus.CONNECTED:
					label = "Connected";
					break;
				case DBus.Client.ConnectionStatus.DISCONNECTED:
					label = "Disconnected";
					break;
			}
			if (status_menu != null)
			{
				if (status == DBus.Client.ConnectionStatus.CONNECTED)
				{
					connect_menuitem.hide();
					disconnect_menuitem.show();
				}
				else
				{
					connect_menuitem.show();
					disconnect_menuitem.hide();
				}
			}
			
			#if ENABLE_APPINDICATOR
				//indicator.set_label(label, "Test");
			#else
				status_icon.tooltip_text = label;
			#endif
		}
		
		private void on_clicked(Gtk.StatusIcon src)
		{
			activate_search_window();
		}
		
		#if !ENABLE_APPINDICATOR
			private void on_menu(uint button, uint time)
			{
				if (status_menu == null)
				{
					status_menu = create_menu();
				}
				status_menu.popup(null, null, status_icon.position_menu, button, time);			
			}
		#endif
		
		private Gtk.Menu create_menu()
		{
			Gtk.Builder builder = new Gtk.Builder();
			builder.add_from_file(gtk_ui_file);
			builder.connect_signals(this);
			
			status_menu = builder.get_object("status_icon_menu") as Gtk.Menu;
			connect_menuitem = builder.get_object("status_icon_menu_connect_menuitem") as Gtk.MenuItem;
			disconnect_menuitem = builder.get_object("status_icon_menu_disconnect_menuitem") as Gtk.MenuItem;

			status_menu.show_all();
			if (barabas.get_status() == DBus.Client.ConnectionStatus.CONNECTED)
			{
				connect_menuitem.hide();
			}
			else
			{
				disconnect_menuitem.hide();
			}
			return status_menu;
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
