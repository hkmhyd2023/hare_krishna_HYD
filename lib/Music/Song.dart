import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:harekrishnagoldentemple/Home/Ekadashi.dart';
import 'package:harekrishnagoldentemple/NoInternet.dart';
import 'package:harekrishnagoldentemple/RoutePages/JapaPage.dart';
import 'package:harekrishnagoldentemple/Seek_Divine_Blessings/Seva_Detail.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as youtube;

class Song extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;
  Song({super.key, required this.documentSnapshot});
  @override
  State<Song> createState() => _SongState();
}

class _SongState extends State<Song> {

  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    audioPlayer.onPlayerStateChanged.listen((event) {
      setState(() {
        isPlaying = event == PlayerState.playing;
      });
    });
    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
    super.initState();
    initConnectivity();
loadLiveLink();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult connectivityResult;
    try {
      connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.mobile) {
        setState(() {});
      } else if (connectivityResult == ConnectivityResult.wifi) {
        setState(() {});
      } else if (connectivityResult == ConnectivityResult.none) {
        setState(() {});
      }
    } on PlatformException catch (e) {
      log('Couldn\'t check connectivity status', error: e);
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(connectivityResult);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    audioPlayer.dispose();
    super.dispose();
  }

  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return [
      if (duration.inHours > 0) hours,
      minutes,
      seconds,
    ].join(':');
  }
late youtube.YoutubePlayerController _controller;
  late String imagelive;

  Future<void> loadLiveLink() async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('LDL').doc('LDL').get();

      if (userSnapshot.exists) {
        String link = userSnapshot['Link'];
        setState(() {
          _controller = youtube.YoutubePlayerController(
            initialVideoId: link,
          );
          imagelive = userSnapshot['Image'];
        });
      } else {
        print("not found");
      }
    } catch (e) {
      // Handle errors
      print('Error loading user data: $e');
    }
  }

_redirectToPageTwo(String route, String dropdown_item) async {
    if (route == "Ekadashi") {
      DocumentSnapshot document = await FirebaseFirestore.instance
          .collection('Upcoming-Event')
          .doc('mP1nsNtfs4wDbLIcaATu')
          .get();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EkadashiDetail(
                    image_url: document['Main-Image'],
                    title: document['Title'],
                    date: document['Date'],
                    description: document['Description'],
                  )));
    } else if (route == "Japa") {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => JapaPage()));
    } else if (route == "Live") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: youtube.YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.blueAccent,
              ));
        },
      );
    } else if (route == "Seva") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SevaDetail(dropdown_title: dropdown_item)));
    }
  }
  @override
  Widget build(BuildContext context) {
    FirebaseMessaging.instance.getToken().then((token) {
      print(token);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      FirebaseFirestore.instance.collection('Notifications').doc().set({
    'Title': '${message.data['Title']}',
    'Description': '${message.data['Description']}',
    'Image': '${message.data['Image']}'
    // add more fields as needed
  });
      _redirectToPageTwo(message.data['Route'], message.data['Dropdown_Item']);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _redirectToPageTwo(message.data['Route'], message.data['Dropdown_Item']);
    });
    return _connectionStatus==ConnectivityResult.none ? NoInternet() : Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(widget.documentSnapshot["Title"]),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.passthrough,
        children: [
          Image.network(widget.documentSnapshot['Image']),
          const _BackgroundFilter(),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  widget.documentSnapshot["Title"],
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  widget.documentSnapshot["SubTitle"],
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: Colors.white),
                  maxLines: 2,
                ),
                SizedBox(height: 20,),
                Slider(
                  activeColor: Colors.orange,
                  thumbColor: Colors.white,
                  inactiveColor: Colors.white,
                  min: 0,
                  max: duration.inSeconds.toDouble(),
                  value: position.inSeconds.toDouble(),
                  onChanged: (value) async {
                    final position = Duration(seconds: value.toInt());
                    await audioPlayer.seek(position);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatTime(position),
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        formatTime(duration),
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: () async {
                                                    await audioPlayer.pause();
                          Duration targetPosition = position - const Duration(seconds: 5);
                          await audioPlayer.seek(targetPosition);
                          await audioPlayer.resume();
                        },
                        icon: Icon(Icons.fast_rewind),
                        iconSize: 40,
                        color: Colors.white),
                    IconButton(
                      onPressed: () async {
                        if(isPlaying) {
                          await audioPlayer.pause();
                        } else {
                          await audioPlayer.play(UrlSource(widget.documentSnapshot['Song']));
                        }
                      },
                      icon: Icon(
                          isPlaying ? Icons.pause_circle : Icons.play_circle),
                      iconSize: 60,
                      color: Colors.white,
                    ),
                    IconButton(
                        onPressed: () async {
                          await audioPlayer.pause();
                          Duration targetPosition = position + const Duration(seconds: 5);
                          await audioPlayer.seek(targetPosition);
                          await audioPlayer.resume();
                        },
                        icon: Icon(Icons.fast_forward),
                        iconSize: 40,
                        color: Colors.white),
                  ],
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [IconButton(onPressed: () {                  FirebaseFirestore.instance.collection("Music").doc(widget.documentSnapshot.id).update({"Likes": FieldValue.increment(1)});
}, icon: Icon(Icons.favorite, color: Colors.red), ), IconButton(onPressed: () {
                }, icon: Icon(Icons.library_add, color: Colors.white,), )],)
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundFilter extends StatelessWidget {
  const _BackgroundFilter({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.white.withOpacity(0.5),
              Colors.white.withOpacity(0.0)
            ],
            stops: const [
              0.0,
              0.4,
              0.6
            ]).createShader(bounds);
      },
      blendMode: BlendMode.dstOut,
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.orange.shade500, Colors.orange])),
      ),
    );
  }
}
