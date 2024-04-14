import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:harekrishnagoldentemple/Books/Book_Category_Detail.dart';
import 'package:harekrishnagoldentemple/Home/Ekadashi.dart';
import 'package:harekrishnagoldentemple/RoutePages/JapaPage.dart';
import 'package:harekrishnagoldentemple/Seek_Divine_Blessings/Seva_Detail.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../NoInternet.dart';

class SPBCAT extends StatefulWidget {
  const SPBCAT({super.key});

  @override
  State<SPBCAT> createState() => _SPBCATState();
}

class _SPBCATState extends State<SPBCAT> {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
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
    super.dispose();
  }late YoutubePlayerController _controller;
  late String imagelive;

  Future<void> loadLiveLink() async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('LDL').doc('LDL').get();

      if (userSnapshot.exists) {
        String link = userSnapshot['Link'];
        setState(() {
          _controller = YoutubePlayerController(
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
              content: YoutubePlayer(
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
        title: Text("Seek Divine Blessings"),
        
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 10,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("Books-Category").snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData) {
                return const Text('No data found');
              }
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: (1 / 1.4),),
                physics: NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.size,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  
                  final DocumentSnapshot document = snapshot.data!.docs[index];
                  return GestureDetector(
                    onTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            InkWell(
                  onTap: () { Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SPBCD(category: document['Title'],)));},
                  child: Container(
                    height: 230,
                    width: 170,
                    decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        image: DecorationImage(
                            image: NetworkImage(
                              
                                document['Image']),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    child: Container(
                      alignment: Alignment.bottomRight,
                      height: 89.0,
                      width: MediaQuery.of(context).size.width / 1.7,
                      decoration: BoxDecoration(
                          color: Colors.black12.withOpacity(0.4),
                          borderRadius: BorderRadius.all(Radius.circular(10.0))),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 160.0, left: 15.0),
                        child: Text(
                          "${document['Title']}   \n",
                          style: TextStyle(
                              fontFamily: "Sofia",
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18.0),
                        ),
                      ),
                    ),
                  ),
                ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      )),
    );
  }
}