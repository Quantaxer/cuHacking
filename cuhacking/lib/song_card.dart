import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotify_sdk/spotify_sdk.dart';


class SongCard extends StatelessWidget {
   SongCard(
      {Key key,
      this.color = Colors.indigo,
      this.trackTitle = "Card Example",
      this.imageUrl = "none",
      this.URI = "",
      this.artist = ""})
      : super(key: key);
  final Color color;
  final String trackTitle;
  final String imageUrl;
  final String URI;
  final String artist;
  var PAUSED = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      width: 320,

      // Warning: hard-coding values like this is a bad practice
      padding: EdgeInsets.all(38.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
          width: 7.0,
          color: Colors.transparent.withOpacity(1),
        ),
      ),

      child: new Column(children: [
        Text(
          trackTitle,
          style: TextStyle(
            fontSize: 18.0,
            // color: Colors.white,
            color: Colors.black12.withOpacity(0.8),
            fontWeight: FontWeight.w900,
          ),
        ),
        new Image.network(imageUrl),
        Text(
          artist,
          style: TextStyle(
            fontSize: 18.0,
            // color: Colors.white,
            color: Colors.black12.withOpacity(0.8),
            fontWeight: FontWeight.w900,
          ),
        ),
        Center(
          child: ElevatedButton(
            child: Text("Pause", style: TextStyle(height: 1.25, fontSize: 25, color: Color(0xff191414),),),
            onPressed: () {
              PAUSED ? resume():pause();
              PAUSED = !PAUSED;
            },
            style: ElevatedButton.styleFrom(
              primary: Color(0xff1DB954), // background
              onPrimary: Color(0xff191414), // foreground
            ),
          ),
        )
      ]),
    );
  }
  Future<void> pause() async {
    try {
      await SpotifySdk.pause();
    } on PlatformException catch (e) {
      print("FUCK: " + e.code + " " + e.message);
    } on MissingPluginException {
      print('not implemented');
    }
  }

  Future<void> resume() async {
    await SpotifySdk.resume();
  }
  Future<void> play() async {
    var _uri = "spotify:track:" + this.URI;
    await SpotifySdk.play(spotifyUri: _uri);
  }
}

