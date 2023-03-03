import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttersocial/controller/auth_controller.dart';
import 'package:fluttersocial/controller/main_controller.dart';
import 'package:fluttersocial/firebase_options.dart';
import 'package:fluttersocial/model/color_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: ColorTheme().base(),
        textTheme: TextTheme(bodyText2: TextStyle(color: ColorTheme().textColor())),
        iconTheme: IconThemeData(color: ColorTheme().textColor())
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.userChanges(),
        builder: (BuildContext context, snapshot) {
          return (snapshot.hasData) ? MainController(memberUid: snapshot.data!.uid) : AuthController();
        },
      ),
    );
  }
}