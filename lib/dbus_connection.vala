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
	public class Connection
	{
		private class Connection () {}
	
		private static Barabas barabas;
	
		public static Barabas get_barabas() throws IOError
		{
			if (barabas == null)
			{
				barabas = Bus.get_proxy_sync(BusType.SESSION,
			                                 "be.ac.ua.comp.Barabas",
			                                 "/be/ac/ua/comp/Barabas");
			}
			return barabas;
		}
		
		public static LocalFile get_local_file(int id) throws IOError
		{
			return Bus.get_proxy_sync(BusType.SESSION,
			                          "be.ac.ua.comp.Barabas",
			                          "/be/ac/ua/comp/Barabas/local_files/" + id.to_string());
		}
		
		public static SyncedFile get_synced_file(int local_id)
		{
			return Bus.get_proxy_sync(BusType.SESSION,
			                          "be.ac.ua.comp.Barabas",
			                          "/be/ac/ua/comp/Barabas/local_files/" +
			                              local_id.to_string() +
			                              "/synced_file");
		}
		
		public static SyncedFileVersion get_file_version(int local_id, int64 version_id)
		{
			return Bus.get_proxy_sync(BusType.SESSION,
			                          "be.ac.ua.comp.Barabas",
			                          "/be/ac/ua/comp/Barabas/local_files/" +
			                              local_id.to_string() +
			                              "/synced_file/versions/" +
			                              version_id.to_string());
		}
		
		public static LocalFile copy_for_synced_file(SyncedFile synced_file,
		                                             string uri,
		                                             out int id)
		    throws IOError
		{
			Barabas barabas = get_barabas();
			
			id = barabas.create_local_copy_for_id(synced_file.get_id(), uri);
			return get_local_file(id);
		}
		
		public static Download get_download(int id) throws IOError
		{
			return Bus.get_proxy_sync(BusType.SESSION,
			                          "be.ac.ua.comp.Barabas",
			                          "/be/ac/ua/comp/Barabas/downloads/" + id.to_string());
		}
		
		public static Search get_search(int id) throws IOError
		{
			return Bus.get_proxy_sync(BusType.SESSION,
			                          "be.ac.ua.comp.Barabas",
			                          "/be/ac/ua/comp/Barabas/searches/" + id.to_string());
		}
		
		public static SyncedFile get_search_result(int search_id, int64 file_id) throws IOError
		{
			return Bus.get_proxy_sync(BusType.SESSION,
			                          "be.ac.ua.comp.Barabas",
			                          "/be/ac/ua/comp/Barabas/searches/" + 
			                                       search_id.to_string() + 
			                                       "/"                   +
			                                       file_id.to_string());
		}
	}
}
