import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:harekrishnagoldentemple/Books/Cart/backend.dart';
import 'package:harekrishnagoldentemple/Bottom_Navigation/Bottom_Navigation.dart';
import 'package:harekrishnagoldentemple/Home/Ekadashi.dart';
import 'package:harekrishnagoldentemple/Home/controller/carousel_controller.dart';
import 'package:harekrishnagoldentemple/Login/Login.dart';
import 'package:harekrishnagoldentemple/Notifications.dart';
import 'package:harekrishnagoldentemple/Prabhupada/prabhupada_feeds.dart';
import 'package:harekrishnagoldentemple/Prabhupada/prabhupada_quotes.dart';
import 'package:harekrishnagoldentemple/RoutePages/Darshans.dart';
import 'package:harekrishnagoldentemple/RoutePages/JapaPage.dart';
import 'package:harekrishnagoldentemple/Seek_Divine_Blessings/Seek_Divine_Blessings_LIS.dart';
import 'package:harekrishnagoldentemple/Seek_Divine_Blessings/Seva_Detail.dart';
import 'package:harekrishnagoldentemple/message.dart';
import 'package:harekrishnagoldentemple/notification_service.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future _firebaseMessagingBackgroundMessage(RemoteMessage message) async {
  _MyAppState()
      .redirectToPageTwo(message.data['Route'], message.data['Dropdown_Item']);
}

Future<YoutubePlayerController> _loadLiveLink1() async {
  late YoutubePlayerController _controller;
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('LDL').doc('LDL').get();

      if (userSnapshot.exists) {
        String link = userSnapshot['Link'];
          _controller = YoutubePlayerController(
            initialVideoId: link,
          );
          return _controller;
      } else {
        print("not found");
      }
    } catch (e) {
      // Handle errors
      print('Error loading user data: $e');
    }
              return _controller;

}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.put(CarouselController());

  
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundMessage);

  await PushNotification.init();

  await PushNotification.localNotInit();

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    _MyAppState().redirectToPageTwo(
        message.data['Route'], message.data['Dropdown_Item']);
  });
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    _MyAppState().redirectToPageTwo(
        message.data['Route'], message.data['Dropdown_Item']);
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundMessage);
  handleFirebaseMessaging();
  //  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
  // if (message!.data['Route'] == "Live") {
  //    showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //             contentPadding: EdgeInsets.zero,
  //             content: YoutubePlayer(
  //               controller: _controller,
  //               showVideoProgressIndicator: true,
  //               progressIndicatorColor: Colors.orangeAccent,
  //             ));
  //       },
  //     );
  //   } else {
  //     navigatorKey.currentState!.pushNamed("/${message.data['Route']}");
  //   }    
  //                     print("App Launched from sleeping mode");

  //   });
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(FirebaseAuth.instance.currentUser!.uid),
      child: MyApp(),
    ),
  );
}

Future<void> handleFirebaseMessaging() async {
  late YoutubePlayerController _controller;
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('LDL').doc('LDL').get();

      if (userSnapshot.exists) {
        String link = userSnapshot['Link'];
          _controller = YoutubePlayerController(
            initialVideoId: link,
          );

          RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null && initialMessage.data['Route'] == "Live") {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      // Show dialog after the build is complete
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.orangeAccent,
            ),
          );
        },
      );
    });
  } else if (initialMessage != null) {
    navigatorKey.currentState!.pushNamed("/${initialMessage.data['Route']}");
  }
  print("App Launched from sleeping mode");
      } else {
        print("not found");
        RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null && initialMessage.data['Route'] == "Live") {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      // Show dialog after the build is complete
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.orangeAccent,
            ),
          );
        },
      );
    });
  } else if (initialMessage != null) {
    navigatorKey.currentState!.pushNamed("/${initialMessage.data['Route']}");
  }
  print("App Launched from sleeping mode");
      }
    } catch (e) {
      // Handle errors
      print('Error loading user data: $e');
    }
  
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late YoutubePlayerController _controller;
  late String imagelive;
  DocumentSnapshot? document;

  @override
  void initState() {
    super.initState();
    loadLiveLink();
    loaddocdata();
  }

  @override
  void dispose() {
    super.dispose();
        navigatorKey.currentState!.dispose();

  }

  Future<void> loaddocdata() async {
    document = await FirebaseFirestore.instance
        .collection('Upcoming-Event')
        .doc('mP1nsNtfs4wDbLIcaATu')
        .get();
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

  Future<void> redirectToPageTwo(String route, String dropdown_item) async {
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
    } else if (route == "Prabhupada_Feeda") {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const PrabhupadaFeeds()));
    } else if (route == "Darshan") {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const Darshans()));
    } else if (route == "Prabhupada_Quotes") {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const PrabhupadaQuotes()));
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
      redirectToPageTwo(message.data['Route'], message.data['Dropdown_Item']);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      redirectToPageTwo(message.data['Route'], message.data['Dropdown_Item']);
    });
FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
                      Navigator.pushNamed(context, '/Japa');


    });
    if (FirebaseAuth.instance.currentUser == null) {
      return MaterialApp(
        title: 'Hare Krishna Golden Temple',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        routes: {
          '/Seva': (context) => SDBLIS(),
          '/Japa': (context) => JapaPage(),
          '/Prabhupada_Feeds': (context) => PrabhupadaFeeds(),
          '/Prabhupada_Quotes': (context) => PrabhupadaQuotes(),
          '/Darshan': (context) => Darshans(),
          '/Ekadashi': (context) => EkadashiDetail(
                image_url: document!['Main-Image'],
                title: document!['Title'],
                date: document!['Date'],
                description: document!['Description'],
              ),
          '/Message': (context) => Message()
        },
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case '/notifications':
              return MaterialPageRoute(builder: (_) => const Notifications());
            case '/SDBLIS':
              return MaterialPageRoute(builder: (_) => SDBLIS());
            default:
              return null;
          }
        },
        theme: ThemeData(
            primarySwatch: Colors.orange,
            textTheme: GoogleFonts.robotoCondensedTextTheme(
              Theme.of(context).textTheme,
            )),
        home: LogIn(),
      );
    } else {
      return MaterialApp(
        title: 'Hare Krishna Golden Temple',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        routes: {
          '/Seva': (context) => SDBLIS(),
          '/Japa': (context) => JapaPage(),
          '/Prabhupada_Feeds': (context) => PrabhupadaFeeds(),
          '/Prabhupada_Quotes': (context) => PrabhupadaQuotes(),
          '/Darshan': (context) => Darshans(),
          '/Ekadashi': (context) => EkadashiDetail(
                image_url: document!['Main-Image'],
                title: document!['Title'],
                date: document!['Date'],
                description: document!['Description'],
              ),
          '/Message': (context) => Message()
        },
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case '/notifications':
              return MaterialPageRoute(builder: (_) => const Notifications());
            case '/SDBLIS':
              return MaterialPageRoute(builder: (_) => SDBLIS());
            default:
              return null;
          }
        },
        theme: ThemeData(
            primarySwatch: Colors.orange,
            textTheme: GoogleFonts.robotoCondensedTextTheme(
              Theme.of(context).textTheme,
            )),
        home: NaviBottomNavBar(),
      );
    }
  }
}
