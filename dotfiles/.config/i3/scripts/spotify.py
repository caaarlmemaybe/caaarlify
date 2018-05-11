#!/usr/bin/python

import dbus
try:
    bus = dbus.SessionBus()
    spotify = bus.get_object("org.mpris.MediaPlayer2.spotify", "/org/mpris/MediaPlayer2")
    spotify_iface = dbus.Interface(spotify, 'org.freedesktop.DBus.Properties')
    props = spotify_iface.Get('org.mpris.MediaPlayer2.Player', 'Metadata')
    artist_name = props['xesam:artist'][0]
    song_title = props['xesam:title']
    print(artist_name + " - " + song_title).encode('utf-8')
    exit
except dbus.exceptions.DBusException:
    exit
