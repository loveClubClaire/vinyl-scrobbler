#!/usr/bin/env python
# coding: utf-8

from __future__ import print_function
import os
import pylast
import sys

# You have to have your own unique two values for API_KEY and API_SECRET
# Obtain yours from http://www.last.fm/api/account for Last.fm

try:
    API_KEY = os.environ['xxxxxxxxxxxxxxxxxxxxxxxxx']
    API_SECRET = os.environ['xxxxxxxxxxxxxxxxxxxxxxxx']
except KeyError:
    API_KEY = "xxxxxxxxxxxxxxxxxxxxxxxxx"
    API_SECRET = "xxxxxxxxxxxxxxxxxxxxxxxxxx"

try:
    lastfm_username = os.environ['undefined']
    lastfm_password_hash = os.environ['xxxxxxxxxxxxxxxxxxxxxxxxxxx']
except KeyError:
    # In order to perform a write operation you need to authenticate yourself
    lastfm_username = "undefined"
    # You can use either use the password, or find the hash once and use that
    lastfm_password_hash = "xxxxxxxxxxxxxxxxxxxxxxxxxxx"
    print(lastfm_password_hash)
    # lastfm_password_hash = "my_password_hash"

print(lastfm_password_hash)

lastfm_network = pylast.LastFMNetwork(
    api_key=API_KEY, api_secret=API_SECRET,
    username=lastfm_username, password_hash=lastfm_password_hash)

TRACK_SEPARATOR = " - "

def split_artist_track(artist_track):
    artist_track = artist_track.replace(u" – ", " - ")
    artist_track = artist_track.replace(u"“", "\"")
    artist_track = artist_track.replace(u"”", "\"")
    (artist, track) = artist_track.split(TRACK_SEPARATOR)
    artist = artist.strip()
    track = track.strip()
    print("Artist:\t\t'" + artist + "'")
    print("Track:\t\t'" + track + "'")

    # Validate
    if len(artist) == 0 and len(track) == 0:
        sys.exit("Error: Artist and track are blank")
    if len(artist) == 0:
        sys.exit("Error: Artist is blank")
    if len(track) == 0:
        sys.exit("Error: Track is blank")

    return (artist, track)

