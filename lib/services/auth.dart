import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class Auth extends ChangeNotifier{
  bool _isLoggedIn = false;
   bool get authenticated => _isLoggedIn;
  final storage = new FlutterSecureStorage();

  void logout(){
    _isLoggedIn = false;
    this.storage.delete(key: 'token');
    this.storage.delete(key: 'selectedValue');
    this.storage.delete(key: 'selectedValue2');
    notifyListeners();
  }


  void login(){
    _isLoggedIn = true;
    notifyListeners();
  }

  void saveToken(String token){
    this.storage.write(key: 'token', value: token);
    print("storing token debug: " + token);
  }

  void saveOptions(String selectedValue, String selectedValue2){
    this.storage.write(key: 'selectedValue', value: selectedValue);
    this.storage.write(key: 'selectedValue2', value: selectedValue2);
  }

}
