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
		
		private string current_search_query;
		private Gee.Set<int> current_search_results;
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
				remote_files_list_store.clear();
				current_search_query = search_entry.text;
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
		
		[CCode (instance_pos = -1)]
		public void on_search_item_activated(Gtk.IconView source,
		                                     Gtk.TreePath path)
		{
			Gtk.TreeIter iter;
			if (!remote_files_list_store.get_iter(out iter, path))
				return;
			
			FileInfo? file_info;
			remote_files_list_store.get(iter, 1, out file_info);
			
			try
			{
				string file_path = barabas.get_file_path_for_remote(file_info.remote_id);
				if (file_path == "")
				{
					Gtk.FileChooserDialog save_dialog =
					    new Gtk.FileChooserDialog("Save file", search_window,
					                              Gtk.FileChooserAction.SAVE,
					                              Gtk.Stock.CANCEL,
					                              Gtk.ResponseType.CANCEL,
					                              Gtk.Stock.OK,
					                              Gtk.ResponseType.OK);
					save_dialog.do_overwrite_confirmation = true;
					save_dialog.local_only = true; // Saving from remote to network disk seems not sensible.
					save_dialog.set_current_name(file_info.name);
					int response = save_dialog.run();
					
					if (response == Gtk.ResponseType.OK)
					{
						stdout.printf("Accepted %s\n", save_dialog.get_uri());
						
						file_path = barabas.download_remote_to_uri(file_info.remote_id, save_dialog.get_uri());
						Client.SyncedFile file = Client.Connection.get_file(file_path);
						file.sync_started.connect((download) => {
							stdout.printf("Downloading\n");
						});
						
						file.sync_progress.connect((current, total) => {
							stdout.printf("Downloading %d / %d\n", (int)current, (int)total);
						});
						
						file.sync_stopped.connect((success) => {
							stdout.printf("Downloaded \n");
						});
						
						// TODO: show a app chooser
						GLib.AppInfo app = GLib.AppInfo.get_default_for_type(file_info.mimetype, true);
						try
						{
							GLib.List<GLib.File> uris = new GLib.List<GLib.File>();
							uris.append (GLib.File.new_for_uri(file.get_uri()));
							app.launch(uris, null);
						}
						catch (Error error)
						{
							// TODO: Show error bar
						}
					}
					else
					{
						stdout.printf("Canceled\n");
					}
					save_dialog.destroy();
				}
				else
				{
					Client.SyncedFile file = Client.Connection.get_file(file_path);
				
					// TODO: show a app chooser
					GLib.AppInfo app = GLib.AppInfo.get_default_for_type(file_info.mimetype, true);
					try
					{
						GLib.List<GLib.File> uris = new GLib.List<GLib.File>();
						uris.append (GLib.File.new_for_uri(file.get_uri()));
						app.launch(uris, null);
					}
					catch (Error error)
					{
						// TODO: Show error bar
					}
				}
			}
			catch (IOError error)
			{
				dbus_error(error);
			}
		}
		
		private void dbus_error(IOError error)
		{
			//TODO: implement this
		}
		
		private void on_search_completes(string search, int[] remotes)
		{
			// Only list the results if the search query result was the
			// last executed search query.
			if (current_search_query == search)
			{
				current_search_query = "";
				current_search_results = new Gee.HashSet<int>();
				foreach (int remote_id in remotes)
				{
					current_search_results.add(remote_id);
					try
					{
						barabas.request_file_info(remote_id);
					}
					catch (IOError error)
					{
						dbus_error(error);
					}
				}
			}
		}
		
		private void on_file_info_received(FileInfo info)
		{
			// This is hack to prevent same results appearing more than once.
			// It seems we get the signal multiple times (sometimes).
			if (!(info.remote_id in current_search_results))
				return;
			
			current_search_results.remove(info.remote_id);
		
			Gtk.TreeIter iter;
			remote_files_list_store.append(out iter);
			GLib.Icon icon = GLib.ContentType.get_icon(info.mimetype);
			string icon_name = "text-x-generic";
			if (icon is GLib.ThemedIcon)
			{
				GLib.ThemedIcon themed_icon = icon as GLib.ThemedIcon;
				string[] names = themed_icon.get_names();
				icon_name = names[names.length - 1];
			}
			remote_files_list_store.set(iter, 0, info.name,
			                                  1, info,
			                                  2, info.remote_id, 
			                                  3, icon_name,
			                                  -1);
		}
	}
}
