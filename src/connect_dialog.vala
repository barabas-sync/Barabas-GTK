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
	public class ConnectDialog
	{
		private const int CANCEL = 0;
		private const int CONNECT = 1;
		private const int RETRY = 2;
	
		private Client.Barabas barabas;
	
		private Gtk.Dialog connect_dialog;
		private Gtk.Grid main_grid;
		private Gtk.ComboBoxText servername_combo_box_text;
		private Gtk.Entry servername_entry;
		private Gtk.Label servername_label;
		private Gtk.SpinButton server_port_spin_button;
		private Gtk.Button connect_button;
		
		private Gtk.InfoBar info_bar;
		
		private bool needs_pulse;
	
		public bool is_running { get; private set; }
	
		public ConnectDialog(Gtk.Builder builder)
		{
			connect_dialog = builder.get_object("connectDialog") as Gtk.Dialog;
			main_grid = builder.get_object("mainConnectDialogGrid") as Gtk.Grid;
			servername_combo_box_text = builder.get_object("servernameComboBoxText") as Gtk.ComboBoxText;
			servername_label = builder.get_object("servernameLabel") as Gtk.Label;
			servername_entry = builder.get_object("servernameEntry") as Gtk.Entry;
			server_port_spin_button = builder.get_object("serverPortSpinButton") as Gtk.SpinButton;
			connect_button = builder.get_object("connectButton") as Gtk.Button;
			
			builder.connect_signals(this);
			
			barabas = DBus.Client.Connection.get_barabas();
			barabas.status_changed.connect(on_server_status_changed);
			is_running = false;
			info_bar = null;
		}
		
		public void run()
		{
			is_running = true;
			if (info_bar != null)
			{
				main_grid.remove(info_bar);
			}
			connect_dialog.run();
		}
		
		public void hide()
		{
			is_running = false;
			connect_dialog.hide();
		}
		
		[CCode (instance_pos = -1)]
		public void on_response(Gtk.Dialog dialog, int response)
		{
			if (response != CONNECT)
			{
				barabas.connect_cancel();
				hide();
				return;
			}
			connect_button.set_sensitive(false);
			servername_combo_box_text.set_sensitive(false);
			server_port_spin_button.set_sensitive(false);
			try
			{
				barabas.connect_server(servername_combo_box_text.get_active_text(),
				                       (int16)server_port_spin_button.get_value_as_int());
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
			needs_pulse = false;
			servername_entry.set_progress_fraction(0.0);
			if (info_bar != null)
			{
				main_grid.remove(info_bar);
			}
			info_bar = new Gtk.InfoBar();
			info_bar.response.connect(on_info_bar_response);
			info_bar.set_message_type(Gtk.MessageType.INFO);
			
			Gtk.Container container = info_bar.get_content_area() as Gtk.Container;
			Gtk.Box box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
		
			Gtk.Label label = new Gtk.Label("");
			container.add(box);
		
			switch (status)
			{
				case DBus.Client.ConnectionStatus.NOT_CONNECTED:
					info_bar = null;
					connect_button.set_sensitive(true);
					servername_combo_box_text.set_sensitive(true);
					server_port_spin_button.set_sensitive(true);
					return;
				case DBus.Client.ConnectionStatus.CONNECTING:
				case DBus.Client.ConnectionStatus.AUTHENTICATING:
					needs_pulse = true;
					Gtk.Spinner spinner = new Gtk.Spinner();
					spinner.start();
					box.add(spinner);
					label.set_text("Connecting to '" + host + "'.");
					info_bar.add_button(Gtk.Stock.CANCEL, CANCEL);
					GLib.Timeout.add(100, () => {
						if (needs_pulse)
							servername_entry.progress_pulse();
						return needs_pulse;
					});
					break;
				case DBus.Client.ConnectionStatus.AUTHENTICATION_FAILED:
					info_bar.set_message_type(Gtk.MessageType.ERROR);
					label.set_text("Failed authentication on '" + host + "': \"" + msg + "\".");
					connect_button.set_sensitive(false);
					break;
				case DBus.Client.ConnectionStatus.DISCONNECTED:
					info_bar.set_message_type(Gtk.MessageType.ERROR);
					label.set_text("Could not connect to '" + host + "': \"" + msg + "\".");
					info_bar.add_button(Gtk.Stock.REFRESH, RETRY);
					connect_button.set_sensitive(true);
					servername_combo_box_text.set_sensitive(true);
					server_port_spin_button.set_sensitive(true);
					break;
			}
			box.add(label);
			
			info_bar.show_all();
			
			main_grid.attach_next_to(info_bar, servername_label,
			                         Gtk.PositionType.TOP, 2, 1);
		}
		
		private void on_info_bar_response(Gtk.InfoBar bar, int response)
		{
			if (response == CANCEL)
			{
				barabas.connect_cancel();
			}
			else if (response == RETRY)
			{
				barabas.connect_server(servername_combo_box_text.get_active_text(),
				                       (int16)server_port_spin_button.get_value_as_int());
			}
		}
	}
}
