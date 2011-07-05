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
	public class SearchWindow
	{
		private Gtk.Window search_window;
		private Gtk.Entry search_entry;
		private Gtk.ListStore remote_files_list_store;
		
		private Client.Barabas barabas;
	
		public SearchWindow(Gtk.Builder builder)
		{
			search_window = builder.get_object("searchWindow") as Gtk.Window;
			search_entry = builder.get_object("searchEntry") as Gtk.Entry;
			remote_files_list_store = builder.get_object("remoteFilesListStore") as Gtk.ListStore;
			builder.connect_signals(this);
			
			try
			{
				barabas = Client.Connection.get_barabas();
				barabas.search_completes.connect(on_search_completes);
				barabas.file_info_received.connect(on_file_info_received);
			}
			catch (IOError error)
			{
			}
		}
		
		public void toggle_show()
		{
			if (search_window.visible)
			{
				search_window.hide();
			}
			else
			{
				search_window.show();
			}
		}
		
		[CCode (instance_pos = -1)]
		public void on_search_activated(Gtk.Entry source)
		{
			try
			{
				barabas.search(search_entry.text);
			}
			catch (IOError error)
			{
				dbus_error(error);
			}
		}
		
		[CCode (instance_pos = -1)]
		public bool on_delete_window(Gtk.Window source, Gdk.Event event)
		{
			search_window.hide();
			return true;
		}
		
		[CCode (instance_pos = -1)]
		public void on_search_entry_press_icon(Gtk.Entry source,
		                                       Gtk.EntryIconPosition icon_pos,
		                                       Gdk.Event event)
		{
			if (icon_pos == Gtk.EntryIconPosition.SECONDARY)
			{
				search_entry.text = "";
			}
		}
		
		private void dbus_error(IOError error)
		{
			//TODO: implement this
		}
		
		private void on_search_completes(string search, int[] remotes)
		{
			foreach (int remote_id in remotes)
			{
				barabas.request_file_info(remote_id);
			}
		}
		
		private void on_file_info_received(FileInfo info)
		{
			Gtk.TreeIter iter;
			remote_files_list_store.append(out iter);
			remote_files_list_store.set(iter, 0, info.name, 1, info, 2, info.remote_id, -1);
		}
	}
}
