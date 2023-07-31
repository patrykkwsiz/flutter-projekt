import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:projekt/Screens/loginScreen.dart';
import 'package:projekt/Screens/home.dart';
import 'package:projekt/services/auth.dart';
import 'package:projekt/viewmodels/home_model.dart';
import 'package:provider/provider.dart';
void main() => runApp(MainApp());


class MainApp extends StatelessWidget {
   MainApp({super.key});
 
   final storage = new FlutterSecureStorage();
  void readToken() async{
    String? token = await storage.read(key: 'token');
    print(token);
  }
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
      ChangeNotifierProvider(create: (context) => HomeModel()),
      ChangeNotifierProvider(create: (context) => Auth()),
      ],
      child: MaterialApp(

        initialRoute: '/Screens/loginScreen',
        routes:{ '/Screens/home' : (context) => Home(),
        '/Screens/loginScreen' : (context) => LoginScreen(),
        }
      )
      );
  }
}
