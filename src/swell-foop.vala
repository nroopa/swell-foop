/*
 * Copyright (C) 2010-2013 Robert Ancell
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 2 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

using Config;

public class SwellFoop : Gtk.Application
{
    /* Translators: name of the program, as seen in the headerbar, in GNOME Shell, or in the about dialog */
    private const string PROGRAM_NAME = _("Swell Foop");

    /* Main window */
    private SwellFoopWindow window;

    /* Command-line options */
    private static bool version = false;
    private const OptionEntry [] option_entries =
    {
        /* Translators: command-line option description, see 'swell-foop --help' */
        { "version", 'v', OptionFlags.NONE, OptionArg.NONE, ref version, N_("Print release version and exit"), null },

        {}
    };

    /* Actions */
    private const GLib.ActionEntry[] action_entries =
    {
        { "help",          help_cb        },
        { "about",         about_cb       },
        { "quit",          quit_cb        }
    };

    /* Constructor */
    public SwellFoop ()
    {
        Object (application_id: "org.gnome.SwellFoop", flags: ApplicationFlags.FLAGS_NONE);
    }

    protected override void startup ()
    {
        base.startup ();

        Gtk.Settings.get_default ().@set ("gtk-application-prefer-dark-theme", true);

        add_action_entries (action_entries, this);
        set_accels_for_action ("app.help",              {                 "F1"  });
        set_accels_for_action ("win.toggle-hamburger",  {                 "F10" });
        set_accels_for_action ("win.new-game",          {        "<Primary>n"   });
        set_accels_for_action ("app.quit",              {        "<Primary>q"   });
        set_accels_for_action ("win.undo",              {        "<Primary>z"   });
        set_accels_for_action ("win.redo",              { "<Shift><Primary>z"   });

        /* Create the main window */
        window = new SwellFoopWindow (this);
        add_window (window);
    }

    protected override void shutdown ()
    {
        window.destroy ();
        base.shutdown ();
    }

    protected override void activate ()
    {
        window.present ();
    }

    private inline void quit_cb (/* SimpleAction action, Variant? variant */)
    {
        window.destroy ();
    }

    private inline void help_cb (/* SimpleAction action, Variant? variant */)
    {
        try
        {
            Gtk.show_uri_on_window (window, "help:swell-foop", Gtk.get_current_event_time ());
        }
        catch (Error e)
        {
            warning ("Failed to show help: %s", e.message);
        }
    }

    private inline void about_cb (/* SimpleAction action, Variant? variant */)
    {
        string[] authors = {
            /* Translators: About dialog text, name of an author */
            _("Tim Horton"),


            /* Translators: About dialog text, name of an author */
            _("Sophia Yu")
        };
        string[] artists = {
            /* Translators: About dialog text, name of an artist */
            _("Tim Horton")
        };
        string[] documenters = {};

        Gtk.show_about_dialog (window,
                               "program-name", PROGRAM_NAME,
                               "version", Config.VERSION,
                               "comments",
                               /* Translators: About dialog text, small description of the application */
                               _("I want to play that game!\nYou know, they all light-up and you click on them and they vanish!"),
                               "license-type", Gtk.License.GPL_2_0,
                               "authors", authors,
                               /* Translators: About dialog text, copyright line */
                               "copyright", _("Copyright \xc2\xa9 2009 Tim Horton"),
                               "artists", artists,
                               "documenters", documenters,
                               /* Translators: About dialog text, should be replaced with a credit for you and your team; do not translate literally! */
                               "translator-credits", _("translator-credits"),
                               "logo-icon-name", "org.gnome.SwellFoop",
                               "website", Config.PACKAGE_URL);
    }

    public static int main (string[] args)
    {
        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
        Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (Config.GETTEXT_PACKAGE);

        if (GtkClutter.init (ref args) != Clutter.InitError.SUCCESS)
        {
            warning ("Failed to initialise Clutter");
            return Posix.EXIT_FAILURE;
        }

        var context = new OptionContext (null);
        context.set_translation_domain (Config.GETTEXT_PACKAGE);

        context.add_group (Gtk.get_option_group (true));
        context.add_group (Clutter.get_option_group_without_init ());

        context.add_main_entries (option_entries, Config.GETTEXT_PACKAGE);

        try
        {
            context.parse (ref args);
        }
        catch (Error e)
        {
            stderr.printf ("%s\n", e.message);
            return Posix.EXIT_FAILURE;
        }

        if (version)
        {
            /* NOTE: Is not translated so can be easily parsed */
            stderr.printf ("%1$s %2$s\n", "swell-foop", Config.VERSION);
            return Posix.EXIT_SUCCESS;
        }

        Environment.set_application_name (PROGRAM_NAME);
        Gtk.Window.set_default_icon_name ("org.gnome.SwellFoop");

        var app = new SwellFoop ();
        return app.run (args);
    }
}
