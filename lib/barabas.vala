/**
    This file is part of Barabas GTK DBus Library.

	Copyright (C) 2011 Nathan Samson
 
    Barabas GTK is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Barabas GTK is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with Barabas GTK.  If not, see <http://www.gnu.org/licenses/>.
*/

namespace Barabas.DBus.Client
{
	[DBus (name = "be.ac.ua.comp.Barabas")]
	public interface Barabas : Object
	{
		public abstract void connect_server(string host, int16 port) throws IOError;
		public abstract void connect_cancel() throws IOError;
		public signal void status_changed(string host, ConnectionStatus status, string message);
	
		public abstract string get_file_path(string uri) throws IOError;
		public abstract string get_version_path(int version_id) throws IOError;
		public abstract string get_file_path_for_remote(int remote_id) throws IOError;
		public abstract string download_remote_to_uri(int remote_id, string uri) throws IOError;
		
		public abstract void search(string search) throws IOError;
		public signal void search_completes(string search, int[] results);
		
		public abstract void request_file_info(int remote_id) throws IOError;
		public signal void file_info_received(FileInfo info);
	}
}
