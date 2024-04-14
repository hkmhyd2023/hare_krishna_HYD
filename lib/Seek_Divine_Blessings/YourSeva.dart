import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:harekrishnagoldentemple/Home/Ekadashi.dart';
import 'package:harekrishnagoldentemple/Home/widgets/app_drawer_component.dart';
import 'package:harekrishnagoldentemple/NoInternet.dart';
import 'package:harekrishnagoldentemple/RoutePages/JapaPage.dart';
import 'package:harekrishnagoldentemple/Seek_Divine_Blessings/Seva_Detail.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YourSevaList extends StatefulWidget {
  const YourSevaList({super.key});

  @override
  State<YourSevaList> createState() => _YourSevaListState();
}

class _YourSevaListState extends State<YourSevaList> {
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
        title: Text("Your Offerings", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.orange.shade300,
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          10.height,
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('Seva-Donation').doc("${FirebaseAuth.instance.currentUser!.uid}").collection("${FirebaseAuth.instance.currentUser!.uid}").snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = snapshot.data!.docs[index];
                      return Card(
                        elevation: 5,
                        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: ListTile(
                          title: Text(
                            'Seva: ${document['Seva']}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Date of Seva: ${document['DateOfSeva']}',
                            style: TextStyle(fontSize: 16),
                          ),
                          // You can access other fields in your document as well
                          // Example: document['field_name']
                        ),
                      );
                    },
                  );
                }}),
          ),
        ],
      ),
    );
}}