import 'dart:async';

import 'package:boomarang/firebase_options.dart';
import 'package:boomarang/misc/alert_dialog.dart';
import 'package:boomarang/screens/add_request.dart';
import 'package:boomarang/screens/holder.dart';
import 'package:boomarang/screens/profile.dart';
import 'package:boomarang/screens/requester.dart';
import 'package:boomarang_shared/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' hide ProfileScreen;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFunctions functions =
    FirebaseFunctions.instanceFor(region: 'us-central1');
FirebaseStorage storage = FirebaseStorage.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;

bool useEmulators = true;

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
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
      theme: ThemeData(
        fontFamily: GoogleFonts.balooPaaji2().fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
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
      //add google font
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Text('Initialising Firebase...'),
                  ],
                ),
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
      buildErrorAlertDialog(e);
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Text('Checking authentication...'),
                  ],
                ),
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            Text('Checking user information...'),
                          ],
                        ),
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            Text('Creating account...'),
                          ],
                        ),
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
  BoomarangUser? user;
  bool hasLoaded = false;
  String? version;
  String? buildNumber;

  List<Widget> screens = [];
  late StreamSubscription? userTypeStreamSubscription;

  Future<void> getUserType() async {
    userTypeStreamSubscription = firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) {
        return;
      }
      user = BoomarangUser.fromMap(snapshot.data() as Map<String, dynamic>);

      if (user!.userType == 'requester') {
        screens = [
          const AddRequestScreen(),
          const RequesterScreen(),
          const ProfileScreen(),
        ];
      } else if (user!.userType == 'holder') {
        screens = [
          const HolderScreen(),
          const ProfileScreen(),
        ];
      } else {
        selectedIndex = 1;
        screens = [
          Container(),
          const ProfileScreen(),
        ];
      }
      hasLoaded = true;
      setState(() {});
    });
  }

  @override
  void initState() {
    getUserType();
    PackageInfo.fromPlatform().then((value) {
      version = value.version;
      buildNumber = value.buildNumber;
    });
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
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                const FlutterLogo(size: 100),
                const SizedBox(
                  height: 40,
                ),
                Text(
                  'Boomarang',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 40,
                )
              ],
            ),
            //Boomerang
          ),
          destinations: [
            if (user?.userType == 'requester')
              NavigationRailDestination(
                icon: const Icon(Icons.add),
                label: Text(
                  'Add New',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            NavigationRailDestination(
              icon: const Icon(Icons.mail),
              label: Text(
                'Requests',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              disabled: user?.userType == null,
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.person),
              label: Text(
                'Profile',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
          trailing: Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  auth.currentUser!.email!,
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    //holder or requester icon
                    Icon(
                      user?.userType == 'holder'
                          ? Icons.arrow_circle_up_rounded
                          : Icons.arrow_circle_down_rounded,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      user?.userType == 'holder' ? 'Holder' : 'Requester',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                TextButton.icon(
                  label: const Text('Sign out'),
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: () {
                    auth.signOut();
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    Text('Version: $version',
                        style: Theme.of(context).textTheme.bodySmall),
                    Text('Build number: $buildNumber',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                const SizedBox(
                  height: 20,
                )
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
          thickness: 3,
          width: 3,
        ),
        Expanded(child: Scaffold(body: screens[selectedIndex])),
      ],
    );
  }
}
