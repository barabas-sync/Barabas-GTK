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

	class SystemTrayIcon
	{
		private Gtk.StatusIcon status_icon;
	
		public SystemTrayIcon()
		{
			status_icon = new Gtk.StatusIcon.from_icon_name("folder-remote");
			status_icon.title = "Barabas";
			status_icon.visible = true;
			status_icon.activate.connect(on_clicked);
			status_icon.popup_menu.connect(on_menu);
			stdout.printf(status_icon.visible ? "True\n" : "False\n");
		}
		
		private void on_clicked(Gtk.StatusIcon src)
		{
			activate_search_window();
		}
		
		private void on_menu(uint button, uint time)
		{
		}
		
		public signal void activate_search_window();	
	}
}
