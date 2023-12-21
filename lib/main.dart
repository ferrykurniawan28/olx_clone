import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:olx/screens/createpost.dart';
import 'package:olx/screens/home.dart';
import 'package:olx/screens/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:olx/screens/profil.dart';
import 'firebase_options.dart';

final _auth = FirebaseAuth.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  bool isUserLoggedIn = FirebaseAuth.instance.currentUser != null;
  runApp(MainApp(
    initialLoginStatus: isUserLoggedIn,
  ));
}

class MainApp extends StatefulWidget {
  final bool initialLoginStatus;
  const MainApp({super.key, required this.initialLoginStatus});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late bool isLogin;

  @override
  void initState() {
    super.initState();
    isLogin = widget.initialLoginStatus;
  }

  void updateLoginStatus(bool isLogin) {
    setState(() {
      this.isLogin = isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // initialRoute: '/login',
      title: "Bishop",
      theme: ThemeData(
        textTheme: GoogleFonts.latoTextTheme(),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Loading...'),
                ],
              ),
            );
          }
          if (snapshot.hasData) {
            return Home(
              login: isLogin,
              onLoginStatusChanged: updateLoginStatus,
            );
          } else {
            return Login(
              onLoginStatusChanged: updateLoginStatus,
            );
          }
        },
      ),
      routes: {
        '/login': (context) => Login(
              onLoginStatusChanged: updateLoginStatus,
            ),
        '/home': (context) => Home(
              login: isLogin,
              onLoginStatusChanged: updateLoginStatus,
            ),
        '/profile': (context) => Profile(
              onLoginStatusChanged: updateLoginStatus,
            ),
        '/create_post': (context) => const CreatePost(),
      },
    );
  }
}
