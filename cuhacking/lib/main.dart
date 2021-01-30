import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'example_route.dart';
import 'example_slide_route.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/models/crossfade_state.dart';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_context.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:http/http.dart' as http;
import "dart:math";

var CLIENT_STRING = "ed2803e840844844b3120ab2cc82dcd5";
var REDIRECT_URL = "http://localhost:8888/callback";
var authToken = "";
var headers;

void main() {
  runApp(MaterialApp(
    title: 'Named Routes Demo',
    // Start the app with the "/" named route. In this case, the app starts
    // on the FirstScreen widget.
    initialRoute: '/',
    routes: {
      // When navigating to the "/" route, build the FirstScreen widget.
      '/': (context) => FirstScreen(),
      // When navigating to the "/second" route, build the SecondScreen widget.
      '/second': (context) => ExampleRouteSlide(),
    },
  ));
}

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('First Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Launch screen'),
          onPressed: () {
            connectToSpotifyRemote(context);
          },
        ),
      ),
    );
  }

  Future<void> connectToSpotifyRemote(BuildContext context) async {
    await SpotifySdk.connectToSpotifyRemote(
        clientId: "ed2803e840844844b3120ab2cc82dcd5",
        redirectUrl: "http://localhost:8888/callback");
    authToken = await SpotifySdk.getAuthenticationToken(
        clientId: CLIENT_STRING,
        redirectUrl: REDIRECT_URL,
        scope: 'app-remote-control, '
            'user-modify-playback-state, '
            'playlist-read-private, '
            'user-top-read, '
            'playlist-modify-public,user-read-currently-playing');

    var res = getUsersTracks();
    Navigator.pushNamed(context, '/second');
  }

  Future<void> getUsersTracks() async {
    headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $authToken'
    };
    var getTopSongs = await http.get(
        'https://api.spotify.com/v1/me/top/tracks?limit=10',
        headers: headers);
    var topSongs = jsonDecode(getTopSongs.body);
    var random = new Random();
    var seedTracks =
        topSongs["items"][random.nextInt(topSongs["items"].length)]["id"];

    var getTopArtists = await http.get(
        'https://api.spotify.com/v1/me/top/artists?time_range=medium_term&limit=10',
        headers: headers);

    var topArtists = jsonDecode(getTopArtists.body);

    var seedArtists =
        topArtists["items"][random.nextInt(topSongs["items"].length)]["id"];

    var genreString = "";

    for (var i = 0; i < 3; i++) {
      var genreArray = topArtists["items"]
          [random.nextInt(topSongs["items"].length)]["genres"];
      genreString = genreString + genreArray[random.nextInt(genreArray.length)];
      if (i != 2) {
        genreString = genreString + ",";
      }
    }

    var getRecommendations = await http.get(
        'https://api.spotify.com/v1/recommendations?limit=25&seed_artists=$seedArtists&seed_genres=$genreString&seed_tracks=$seedTracks',
        headers: headers);

    var results = jsonDecode(getRecommendations.body);

    return results["tracks"];
  }
}
