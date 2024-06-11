import 'package:boomarang/firebase_options.dart';
import 'package:boomarang/screens/inbox.dart';
import 'package:boomarang/screens/profile.dart';
import 'package:boomarang/screens/sandbox.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
      navigatorKey: navigatorKey,
      home: FutureBuilder(
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
          }),
    );
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
      }
    } on Exception catch (e) {
      print('Error: $e');
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
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await auth.signInAnonymously();
                  },
                  child: const Text('Sign in Anonymously'),
                ),
              ),
            );
          } else {
            return const Home();
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

  List<Widget> screens = [
    const InboxScreen(),
    const ProfileScreen(),
    const SandboxScreen(),
    const Text('Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NavigationRail(
          leading: const Padding(
            padding: EdgeInsets.all(8.0),
            //Boomerang
          ),
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.mail),
              label: Text('Inbox'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.account_circle),
              label: Text('Account'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.person),
              label: Text('Sandbox'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.settings),
              label: Text('Settings'),
              disabled: true,
            ),
          ],
          selectedIndex: selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              selectedIndex = index;
            });
          },
          extended: true,
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
