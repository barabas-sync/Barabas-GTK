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

namespace Barabas.GtkFace
{
	class Main
	{
		public static void main(string[] args)
		{
			Gtk.init(ref args);
			Main app = new Main();
			app.start();
		}
	
		private SearchWindow search_window;
		private SystemTrayIcon tray_icon;
	
		public Main()
		{
			tray_icon = new SystemTrayIcon();
			tray_icon.activate_search_window.connect(on_search_window);
		}
		
		public void start()
		{
			Gtk.main();
		}
		
		public void on_search_window()
		{
			if (search_window == null)
			{
				// TODO: make the path installable.
				Gtk.Builder builder = new Gtk.Builder();
				builder.add_from_file("../share/barabas-gtk.ui");
			
				search_window = new SearchWindow(builder);
			}
			search_window.toggle_show();
		}
	}
}
