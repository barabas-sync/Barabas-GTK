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
		
		private Client.Search current_search;
		
		private Gee.List<Download> downloads;
	
		public SearchWindow(Gtk.Builder builder)
		{
			search_window = builder.get_object("searchWindow") as Gtk.Window;
			search_entry = builder.get_object("searchEntry") as Gtk.Entry;
			remote_files_list_store = builder.get_object("remoteFilesListStore") as Gtk.ListStore;
			builder.connect_signals(this);
			current_search = null;
			downloads = new Gee.ArrayList<Download>();
			
			try
			{
				barabas = Client.Connection.get_barabas();
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
				if (current_search != null)
				{
					current_search.free();
				}
				remote_files_list_store.clear();
				current_search_query = search_entry.text;
				int search_id = barabas.search(search_entry.text);
				current_search = Client.Connection.get_search(search_id);
				foreach (int64 result in current_search.get_results())
				{
					Client.SyncedFile file = Client.Connection.get_search_result(search_id, result);
					Gtk.TreeIter iter;
					remote_files_list_store.append(out iter);
					GLib.Icon icon = GLib.ContentType.get_icon(file.get_mimetype());
					string icon_name = "text-x-generic";
					if (icon is GLib.ThemedIcon)
					{
						GLib.ThemedIcon themed_icon = icon as GLib.ThemedIcon;
						string[] names = themed_icon.get_names();
						icon_name = names[names.length - 1];
					}
					remote_files_list_store.set(iter, 0, file.get_name(),
							                          1, file,
							                          2, file.get_id(), 
							                          3, icon_name,
							                          -1);
				}
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
			
			Client.SyncedFile? synced_file;
			remote_files_list_store.get(iter, 1, out synced_file);
			try
			{
				string local_uri = synced_file.get_local_uri();
				if (local_uri == "")
				{
					Gtk.FileChooserDialog save_dialog =
					    new Gtk.FileChooserDialog("Save file", search_window,
					                              Gtk.FileChooserAction.SAVE,
					                              Gtk.Stock.CANCEL,
					                              Gtk.ResponseType.CANCEL,
					                              Gtk.Stock.OK,
					                              Gtk.ResponseType.OK);
					save_dialog.do_overwrite_confirmation = true;
					save_dialog.local_only = true;
					// Saving from remote to network disk seems not sensible.
					save_dialog.set_current_name(synced_file.get_name());
					int response = save_dialog.run();
					
					if (response == Gtk.ResponseType.OK)
					{
						stdout.printf("Accepted %s\n", save_dialog.get_uri());
						
						int file_id;
						Client.LocalFile local_file =
						    Client.Connection.copy_for_synced_file (
                                synced_file,
                                save_dialog.get_uri(),
                                out file_id);
						int64 latest_version = synced_file.get_latest_version();
						Client.SyncedFileVersion sf_version =
						      Client.Connection.get_file_version(file_id,
						                                         latest_version);
						int download_id = barabas.download(save_dialog.get_uri(), latest_version);
						Download download = new Download(synced_file, Client.Connection.get_download(download_id), save_dialog.get_uri());
						download.stopped.connect((the_download) => {
							downloads.remove(the_download);
						});
						downloads.add(download);
						download.start();
						local_file.release();
					}
					else
					{
						stdout.printf("Canceled\n");
					}
					save_dialog.destroy();
				}
				else
				{
					// TODO: show a app chooser
					stdout.printf("Opening app for %s with type %s\n", local_uri, synced_file.get_mimetype());
					GLib.AppInfo? app = GLib.AppInfo.get_default_for_type(synced_file.get_mimetype(), true);
					
					if (app == null)
					{
						stdout.printf("No app found\n");
						return;
					}
					
					try
					{
						GLib.List<GLib.File> uris = new GLib.List<GLib.File>();
						uris.append (GLib.File.new_for_uri(local_uri));
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
		
		private void download_started()
		{
		}
		
		private void download_progress(int64 progress, int64 total)
		{
			stdout.printf("Progress..\n");
		}
		
		private void download_stopped()
		{
			stdout.printf("Stopped\n");
		}
		
		private void dbus_error(IOError error)
		{
			//TODO: implement this
		}
	}
}
