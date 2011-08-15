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
	public class Download
	{
		private Client.SyncedFile synced_file;
		private Client.Download download;
		private string uri;
		
		public Download(Client.SyncedFile synced_file,
		                Client.Download download,
		                string uri)
		{
			this.synced_file = synced_file;
			this.download = download;
			this.uri = uri;
			download.started.connect(on_started);
			download.progress.connect(on_progress);
			download.stopped.connect(on_stopped);
		}
		
		public void start()
		{
			download.start_request();
		}
		
		public signal void stopped();
		
		private void on_started()
		{
		}
		
		private void on_progress()
		{
		}
		
		private void on_stopped()
		{
			stdout.printf("STARTING APP");
			// TODO: show a app chooser
			GLib.AppInfo app = GLib.AppInfo.get_default_for_type(synced_file.get_mimetype(), true);
			try
			{
				GLib.List<GLib.File> uris = new GLib.List<GLib.File>();
				uris.append (GLib.File.new_for_uri(uri));
				app.launch(uris, null);
			}
			catch (Error error)
			{
				// TODO: Show error bar
			}
			stopped();
		}
	}
}
