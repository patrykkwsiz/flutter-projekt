import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/home_model.dart';

class TextFieldWidget extends StatelessWidget {

  final String hintText;
  final IconData prefixIconData;
  final IconData? suffixIconData;
  final bool obscureText;
  final void Function(String) onChanged;
  final void Function() onTap;
  final TextEditingController controller;
  final String? Function(String? val)? validator;
  final TextInputType? keyboardType;

  TextFieldWidget({super.key,  
   required this.hintText,
   required this.prefixIconData,
   required this.suffixIconData,
   required this.obscureText,
   required this.onChanged,
   required this.onTap,
   required this.controller,
   this.keyboardType,
   required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<HomeModel>(context);
    return TextFormField(
        onChanged: onChanged,
        onTap: onTap,
        keyboardType: keyboardType,
        validator: validator,
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(
          color: Colors.blue.shade100,
          fontSize: 14,
        ),
        cursorColor: Colors.blue.shade300,
        decoration: InputDecoration(
          labelText: hintText,
          labelStyle: TextStyle(color: Colors.blue.shade100),
          prefixIcon: Icon(
            prefixIconData,
            size: 18,
            color: Colors.blue.shade300,
          ),
          filled: true,
          enabledBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
            ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.blue.shade300),
            ),
            suffixIcon: GestureDetector(
              onTap: (){
                if(suffixIconData == Icons.visibility_off || suffixIconData == Icons.visibility)
                model.isVisible = !model.isVisible;
              },
              child: Icon(
                suffixIconData,
                size: 18,
                color: Colors.blue.shade300,
              ),
            ),
         ),
    
      );
  }
}