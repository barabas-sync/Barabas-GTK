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

using Barabas.DBus;

namespace Barabas.GtkFace
{
	public class UserPasswordAuthenticationDialog
	{
		private const int CANCEL = 0;
		private const int OK = 1;
	
		private Client.Barabas barabas;
	
		private Gtk.Dialog user_password_dialog;
		private Gtk.Grid main_grid;
		private Gtk.Button login_button;
		private Gtk.Label username_label;
		private Gtk.Entry username_entry;
		private Gtk.Entry password_entry;
		
		private Gtk.InfoBar info_bar;
	
		public UserPasswordAuthenticationDialog(Gtk.Builder builder)
		{
			user_password_dialog = builder.get_object("userPasswordAuthenticationDialog") as Gtk.Dialog;
			login_button = builder.get_object("okUserPasswordAuthenticateButton") as Gtk.Button;
			main_grid = builder.get_object("usernamePasswordLoginGrid") as Gtk.Grid;
			username_label = builder.get_object("usernameLabel") as Gtk.Label;
			username_entry = builder.get_object("usernameEntry") as Gtk.Entry;
			password_entry = builder.get_object("passwordEntry") as Gtk.Entry;
			
			builder.connect_signals(this);
			
			barabas = DBus.Client.Connection.get_barabas();
			barabas.status_changed.connect(on_server_status_changed);
		}
		
		public void run()
		{
			user_password_dialog.run();
		}
		
		public void hide()
		{
			user_password_dialog.hide();
		}
		
		[CCode (instance_pos = -1)]
		public void on_response(Gtk.Dialog dialog, int response)
		{
			if (response != OK)
			{
				user_password_dialog.hide();
				barabas.authenticate_cancel();
			}
			login_button.set_sensitive(false);
			var authentication = DBus.Client.UserPasswordAuthentication();
			
			authentication.username = username_entry.get_text();
			authentication.password = password_entry.get_text();
			
			try
			{
				barabas.authenticate_user_password(authentication);
			}
			catch (IOError error)
			{
				//dbus_error(error);
			}
		}
		
		private void on_server_status_changed(string host,
		                                      DBus.Client.ConnectionStatus status,
		                                      string msg)
		{
			if (info_bar != null)
			{
				main_grid.remove(info_bar);
			}
			info_bar = new Gtk.InfoBar();
			//info_bar.response.connect(on_info_bar_response);
			info_bar.set_message_type(Gtk.MessageType.INFO);
			
			Gtk.Container container = info_bar.get_content_area() as Gtk.Container;
			Gtk.Box box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
		
			Gtk.Label label = new Gtk.Label("");
			container.add(box);
		
			switch (status)
			{
				case DBus.Client.ConnectionStatus.NOT_CONNECTED:
					info_bar = null;
					login_button.set_sensitive(false);
					return;
				case DBus.Client.ConnectionStatus.CONNECTING:
				case DBus.Client.ConnectionStatus.AUTHENTICATING:
					Gtk.Spinner spinner = new Gtk.Spinner();
					spinner.start();
					box.add(spinner);
					label.set_text("Connecting to '" + host + "'.");
					break;
				case DBus.Client.ConnectionStatus.AUTHENTICATION_FAILED:
					info_bar.set_message_type(Gtk.MessageType.ERROR);
					label.set_text("Failed authentication on '" + host + "': \"" + msg + "\".");
					login_button.set_sensitive(true);
					break;
				case DBus.Client.ConnectionStatus.CONNECTED:
					info_bar = null;
					hide();
					break;
				case DBus.Client.ConnectionStatus.DISCONNECTED:
					info_bar.set_message_type(Gtk.MessageType.ERROR);
					label.set_text("Could not connect to '" + host + "': \"" + msg + "\".");
					//info_bar.add_button(Gtk.Stock.REFRESH, RETRY);
					login_button.set_sensitive(false);
					break;
			}
			box.add(label);
			
			info_bar.show_all();
			
			main_grid.attach_next_to(info_bar, username_label,
			                         Gtk.PositionType.TOP, 2, 1);
		}
	}
}
