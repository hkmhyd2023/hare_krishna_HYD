// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, prefer_const_literals_to_create_immutables, library_private_types_in_public_api, annotate_overrides


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:harekrishnagoldentemple/Home/Ekadashi.dart';
import 'package:harekrishnagoldentemple/RoutePages/JapaPage.dart';
import 'package:harekrishnagoldentemple/Seek_Divine_Blessings/Seva_Detail.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:restart_app/restart_app.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import './lipsum.dart' as lipsum;

class PrabhupadaQuotes extends StatefulWidget {
  const PrabhupadaQuotes({super.key});

  @override
  State<PrabhupadaQuotes> createState() => _PrabhupadaQuotesState();
}

class _PrabhupadaQuotesState extends State<PrabhupadaQuotes> {
  bool color = false;
  Map likes = {};
  int likeCount = 0;
  bool isLiked = false;
  List docID = [];late YoutubePlayerController _controller;
  late String imagelive;
    @override
  void initState() {
    super.initState();
loadLiveLink();
  }
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
        print("Not Found");
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
                progressIndicatorColor: Colors.orangeAccent,
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
    return Scaffold(
      appBar: AppBar(title: Text("Quotes", style: TextStyle(color: Colors.white),), backgroundColor: Colors.orange.shade300,),
      body: SingleChildScrollView(
        child: Column(
          children: [
            10.height,
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("Prabhupada-Quotes")
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }
                              if (!snapshot.hasData) {
                                return const Text('No data found');
                              }
                              return ListView.builder(
                                shrinkWrap: true,
                                reverse: true,
                                itemCount: snapshot.data!.size,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  
                                  final DocumentSnapshot document =
                                      snapshot.data!.docs[index];
                                        return Card(
                                color: white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16))),
                                child: InkWell(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16)),
                                  onTap: () {},
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        ClipRRect(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(16),
                                              topRight: Radius.circular(16)),
                                          child: Image.network(
                                              document["Image"],
                                              height: 360,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              fit: BoxFit.fill),
                                        ),
                                        10.height,
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 16, right: 16),
                                                    child: Text(
                                                      "${document["Flowers_Offered"]} Flowers Offered",
                                                      style: TextStyle(
                                                          fontSize: 15),
                                                    )),
                                              ],
                                            ),

                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 16, right: 16),
                                              child: Row(
                                                children: [
                                                  GestureDetector(
                                                    child: Image.network(
                                                      "https://static.thenounproject.com/png/14177-200.png",
                                                      height: 35,
                                                      width: 35,
                                                      color: Colors.pink,
                                                    ),
                                                    onTap: () {
                                                      bool _isLiked = likes[FirebaseAuth.instance.currentUser!.uid] == true;
    if (_isLiked) {
      FirebaseFirestore.instance.collection('Prabhupada-Quotes').doc(document.id).update({"Flowers_Offered": FieldValue.increment(-1)});
      setState(() {
        likeCount -= 1;
        isLiked = false;
        docID.add( document.id);
        likes[FirebaseAuth.instance.currentUser!.uid] = false;
      });
    } else if (!_isLiked) {
      FirebaseFirestore.instance.collection('Prabhupada-Quotes').doc(document.id).update({"Flowers_Offered": FieldValue.increment(1)});
      setState(() {
        likeCount += 1;
        docID.add( document.id);
        isLiked = true;
        likes[FirebaseAuth.instance.currentUser!.uid] = true;
      });
    }
                                                    },
                                                  ),
                                                  
                                                ],
                                              ),
                                            ),
                                            
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: Row(
                                            
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text (""),
                                                        Text(document['Date'], style: TextStyle(),)
                                                      ],
                                                    ),
                                        ),
                                        SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                                      },
                              );
                                },
                                    ),
            )]),
        ),
      );
  }
}