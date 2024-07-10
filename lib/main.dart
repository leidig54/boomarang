import 'package:boomarang/data/auth_provider.dart';
import 'package:boomarang/data/user_provider.dart';
import 'package:boomarang/firebase_options.dart';
import 'package:boomarang/misc/tab_index_provider.dart';
import 'package:boomarang/requester/screens/add_request.dart';
import 'package:boomarang/shared/auth_gate.dart';
import 'package:boomarang_shared/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

//TODO: make stepper scrollable
//TODO: fix delay when navgating back

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFunctions functions =
    FirebaseFunctions.instanceFor(region: 'us-central1');
FirebaseStorage storage = FirebaseStorage.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;

bool useEmulators = true;

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: null,
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
    return ChangeNotifierProvider(
        create: (context) => UserAuthProvider(),
        lazy: false,
        builder: (context, child) {
          return MultiProvider(
            key: ValueKey(context.watch<UserAuthProvider>().user?.uid),
            providers: [
              ChangeNotifierProvider(create: (context) => UserProvider()),
              ChangeNotifierProvider(create: (context) => TabIndexProvider()),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              navigatorKey: navigatorKey,
              theme: themeData,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', 'GB'), // English, UK
              ],
              routes: {
                '/': (context) => const AuthGate(),
                '/add-request': (context) => const AddRequestScreen(),
              },
              initialRoute: '/',
              //add google font
            ),
          );
        });
  }
}
