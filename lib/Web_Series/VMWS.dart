import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:harekrishnagoldentemple/Home/Ekadashi.dart';
import 'package:harekrishnagoldentemple/RoutePages/JapaPage.dart';
import 'package:harekrishnagoldentemple/Seek_Divine_Blessings/Seva_Detail.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VMWS extends StatefulWidget {
  const VMWS({super.key});

  @override
  State<VMWS> createState() => _VMWSState();
}

class _VMWSState extends State<VMWS> {
            Map likes = {};
  int likeCount = 0;
  bool isLiked = false;
  late YoutubePlayerController _controller;
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
        print("not found");
      }
    } catch (e) {
      // Handle errors
      print('Error loading user data: $e');
    }
  }
  List docID = [];_redirectToPageTwo(String route, String dropdown_item) async {
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Vrindavan Mathura"),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(9.0),
          child: Column(children: [
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection("VMWS").snapshots(),
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
                  itemCount: snapshot.data!.size,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    final DocumentSnapshot document =
                        snapshot.data!.docs[index];
                    String url = document["Video"];
                    YoutubePlayerController _controller =
                        YoutubePlayerController(
                            initialVideoId: url,
                            flags: YoutubePlayerFlags(
                                autoPlay: false, mute: false));
                    return Card(
                      color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                      child: InkWell(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        onTap: () {},
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16)),
                                child: YoutubePlayer(controller: _controller),
                              ),
                              10.height,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 16, right: 16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: 300,
                                          child: Text(
                                            document["Title"],
                                            style: boldTextStyle(
                                                size: 16, color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    child: Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                    ),
                                    onTap: () {
                                                                                                                                                                                  bool _isLiked = likes[FirebaseAuth.instance.currentUser!.uid] == true;

                                          if (_isLiked) {
      FirebaseFirestore.instance.collection('VMWS').doc(document.id).update({"Likes": FieldValue.increment(-1)});
      setState(() {
        likeCount -= 1;
        isLiked = false;
        docID.add( document.id);
        likes[FirebaseAuth.instance.currentUser!.uid] = false;
      });
    } else if (!_isLiked) {
      FirebaseFirestore.instance.collection('VMWS').doc(document.id).update({"Likes": FieldValue.increment(1)});
      setState(() {
        likeCount += 1;
        docID.add( document.id);
        isLiked = true;
        likes[FirebaseAuth.instance.currentUser!.uid] = true;
      });
    }
                                    },
                                  ),
                                  10.width,
                                ],
                              ),
                              10.height,
                              Padding(
                                padding: EdgeInsets.only(left: 16, right: 16),
                                child: ReadMoreText(
                                  document["Description"],
                                  style: secondaryTextStyle(
                                      size: 16, color: Colors.black),
                                  trimLines: 2,
                                  trimMode: TrimMode.Line,
                                  trimCollapsedText: '... Read More',
                                  trimExpandedText: ' Read Less',
                                ),
                              ),
                              10.height,
                              Padding(
                                padding:        EdgeInsets.only(left: 16, right: 16),
                                child: Text("${document["Likes"]} Likes"),
                              ),
                              SizedBox(
                                height: 20,
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
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ]),
        ),
      ),
    );;
  }
}