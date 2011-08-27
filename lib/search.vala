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
	[DBus (name = "be.ac.ua.comp.Barabas.Search")]
	public interface Search : Object
	{
		public abstract int64[] get_results() throws IOError;
		public abstract void free() throws IOError;
	}
}
