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
	
		public static Barabas get_barabas() throws IOError
		{
			return Bus.get_proxy_sync(BusType.SESSION,
			                          "be.ac.ua.comp.Barabas",
			                          "/be/ac/ua/comp/Barabas");
		}
		
		public static SyncedFile get_file(string path) throws IOError
		{
			return Bus.get_proxy_sync(BusType.SESSION,
			                          "be.ua.ac.cmi.comp.Barabas",
			                          "/be/ua/ac/cmi/comp/Barabas/files/" + path);
		}
	}
}
