import 'dart:async';

import 'package:boomarang/firebase_options.dart';
import 'package:boomarang/screens/add_request.dart';
import 'package:boomarang/screens/inbox.dart';
import 'package:boomarang/screens/profile.dart';
import 'package:boomarang/screens/sent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFunctions functions =
    FirebaseFunctions.instanceFor(region: 'us-central1');
FirebaseStorage storage = FirebaseStorage.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;

bool useEmulators = true;

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'GB'), // English, UK
      ],
      routes: {
        '/': (context) => const InitApp(),
        '/add-request': (context) => const AddRequestScreen(),
      },
      initialRoute: '/',
    );
  }
}

class InitApp extends StatelessWidget {
  const InitApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(
          name: null,
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          }
          return const AuthGate();
        });
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    try {
      if (kDebugMode && useEmulators) {
        functions.useFunctionsEmulator('localhost', 5001);
        auth.useAuthEmulator('localhost', 9099);
        firestore.useFirestoreEmulator('localhost', 8080);
        // storage.useStorageEmulator('localhost', 9199);
      }
    } on Exception catch (e) {
      debugPrint('Error: $e');
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          } else if (snapshot.data == null) {
            return Scaffold(
              body: SignInScreen(
                providers: [
                  EmailAuthProvider(),
                ],
              ),
            );
          } else {
            return StreamBuilder(
                stream: firestore
                    .collection('users')
                    .doc(auth.currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Scaffold(
                      body: Center(
                        child: Text('Error: ${snapshot.error}'),
                      ),
                    );
                  } else if (!snapshot.hasData) {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return const Home();
                });
          }
        });
  }
}

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedIndex = 0;
  String? userType;
  bool hasLoaded = false;

  List<Widget> screens = [];
  late StreamSubscription? userTypeStreamSubscription;

  Future<void> getUserType() async {
    userTypeStreamSubscription = firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .snapshots()
        .listen((snapshot) {
      userType = snapshot.data()!['type'];
      if (userType == 'requester') {
        screens = [
          const SentScreen(),
          const SettingsScreen(),
        ];
      } else if (userType == 'holder') {
        screens = [
          const InboxScreen(),
          const SettingsScreen(),
        ];
      } else {
        selectedIndex = 1;
        screens = [
          Container(),
          const SettingsScreen(),
        ];
      }
      hasLoaded = true;
      setState(() {});
    });
  }

  @override
  void initState() {
    getUserType();
    super.initState();
  }

  @override
  void dispose() {
    userTypeStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!hasLoaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Row(
      children: [
        NavigationRail(
          leading: const Padding(
            padding: EdgeInsets.all(8),
            child: FlutterLogo(size: 40),
            //Boomerang
          ),
          destinations: [
            NavigationRailDestination(
              icon: const Icon(Icons.mail),
              label: const Text('Requests'),
              disabled: userType == null,
            ),
            const NavigationRailDestination(
              icon: Icon(Icons.settings),
              label: Text('Settings'),
            ),
          ],
          trailing: Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      auth.currentUser!.email!,
                    ),
                    IconButton(
                      icon: const Icon(Icons.exit_to_app),
                      onPressed: () {
                        auth.signOut();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          selectedIndex: selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              selectedIndex = index;
            });
          },
          extended: MediaQuery.of(context).size.width > 1400,
        ),
        const VerticalDivider(
          thickness: 1,
          width: 1,
        ),
        Expanded(
          child: Scaffold(
            body: screens[selectedIndex],
          ),
        ),
      ],
    );
  }
}
