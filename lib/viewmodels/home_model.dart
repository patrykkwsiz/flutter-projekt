import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:email_validator/email_validator.dart';

class HomeModel extends ChangeNotifier{
  get isVisible => _isVisible;
  bool _isVisible = false;
  set isVisible(value){
    _isVisible = value;
    notifyListeners();
}
  get isValid => _isValid;
  bool _isValid = false;
  void isValidEmail(String input){
   _isValid = EmailValidator.validate(input);
    notifyListeners();
  }

}