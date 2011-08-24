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
		public abstract void enable_authentication_method(string authentication_method) throws IOError;
		public abstract void connect_server(string host, int16 port) throws IOError;
		public abstract void connect_cancel() throws IOError;
		public abstract void disconnect() throws IOError;
		public abstract void authenticate_user_password(UserPasswordAuthentication authentication) throws IOError;
		public abstract void authenticate_cancel() throws IOError;
		public abstract ConnectionStatus get_status() throws IOError;
		public signal void status_changed(string host, ConnectionStatus status, string message);
		public signal void user_password_authentication_request();
		
		public abstract HostConfiguration[] get_recently_used_hosts() throws IOError;
	
		public abstract int get_file_id_for_uri(string uri) throws IOError;
		public abstract int search(string search_query) throws IOError;
		
		public abstract int create_local_copy_for_id(int64 file_id, string uri) throws IOError;
		public abstract int download(string uri, int64 version_id) throws IOError;
	}
}
