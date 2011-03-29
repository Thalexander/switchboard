/***
BEGIN LICENSE
Copyright (C) 2011 Avi Romanoff <aviromanoff@gmail.com>
This program is free software: you can redistribute it and/or modify it 
under the terms of the GNU Lesser General Public License version 2.1, as published 
by the Free Software Foundation.
 
This program is distributed in the hope that it will be useful, but 
WITHOUT ANY WARRANTY; without even the implied warranties of 
MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR 
PURPOSE.  See the GNU General Public License for more details.
 
You should have received a copy of the GNU General Public License along 
with this program.  If not, see <http://www.gnu.org/licenses/>.
END LICENSE
***/

using Gtk;

namespace SwitchBoard {

    public class CategoryView : Gtk.VBox {

        private string[] category_titles = {};
        private Gee.HashMap<string, ListStore> category_store = new Gee.HashMap<string, ListStore>();
        private Gtk.IconTheme theme = Gtk.IconTheme.get_default();
    
        public signal void plug_selected(IconView view, ListStore message);    

        public CategoryView (string[] titles) {
            this.category_titles = titles;
            foreach (string title in this.category_titles) {
                var store = new ListStore (3, typeof (string), typeof (Gdk.Pixbuf), typeof(string));
                var label = new Gtk.Label("<big><b>"+title+"</b></big>");
                var category_plugs = new Gtk.IconView.with_model (store);
                category_plugs.set_text_column (0);
                category_plugs.set_pixbuf_column (1);
                category_plugs.selection_changed.connect(() => this.plug_selected(category_plugs, store));
                var color = Gdk.Color ();
                Gdk.Color.parse ("#dedede", out color);
                category_plugs.modify_base (Gtk.StateType.NORMAL, color);
                label.xalign = (float) 0.02;
                var vbox = new Gtk.VBox(false, 0); // not homogeneous, 0 spacing
                label.use_markup = true;
                if (title != this.category_titles[0]) {
                    var hsep = new Gtk.HSeparator();
                    vbox.pack_start(hsep, false, false); // expand, fill, padding
                }
                vbox.pack_start(label, false, true);
                vbox.pack_end(category_plugs, true, true);
                this.category_store[title] = store;
                this.pack_start(vbox);
            }
        }
        
        public void add_plug (Gee.HashMap<string, string> plug) {
            Gtk.TreeIter root;
            this.category_store[plug["category"]].append (out root);
            try {
                var icon_pixbuf = this.theme.load_icon (plug["icon"], 48, Gtk.IconLookupFlags.GENERIC_FALLBACK);
                this.category_store[plug["category"]].set (root, 1, icon_pixbuf, -1);
            } catch {
                GLib.log(SwitchBoard.errdomain, LogLevelFlags.LEVEL_DEBUG, 
                "Unable to load plug %s's icon: %s", plug["title"], plug["icon"]);
            }
            this.category_store[plug["category"]].set (root, 0, plug["title"], -1);
            this.category_store[plug["category"]].set (root, 2, plug["exec"], -1);
        }
    }
}
