// ignore_for_file: prefer_const_constructors


import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:projekt/Screens/home.dart';
import 'package:projekt/services/auth.dart';
import 'package:projekt/widgets/textFieldWidget.dart';
import 'package:projekt/viewmodels/home_model.dart';
import 'package:provider/provider.dart';
import 'package:projekt/widgets/buttonWidget.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
    LoginScreen({super.key});
    
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
    final _formKey = GlobalKey<FormState>();
     String emailTemp ='';
     String passwordTemp = '';
     String? result = '';
     String token = '';
     String? tokenRead = '';
    static final HttpLink httpLink = HttpLink("http://panelcargo.insoft.net.pl/graphql");

  final ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(),
    ),
);

    ScrollController scrollController = ScrollController();
    TextEditingController _emailController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String? _deviceName;

  void readToken() async{
    this.tokenRead = await storage.read(key: 'token');
    print("wut " + this.tokenRead.toString());
    renderCheck();
  }

  @override
  void initState(){
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      readToken();
      if(mounted == true){
          setState(() { });
      }
    });
    getDeviceName();
  
}
  final storage = new FlutterSecureStorage();


  void renderCheck(){
    print(this.tokenRead);
    if (this.tokenRead == null){
       return;
    } else if(this.tokenRead != null){
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context) => Home()));
    }
  }

  @override
  void dispose(){
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void getDeviceName() async{
    try {
      if (Platform.isAndroid){
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        _deviceName = androidInfo.model;
      } else if (Platform.isIOS){
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        _deviceName = iosInfo.utsname.machine;
      }

    } catch (e){
      print(e);
    }

  }

  @override
  Widget build(BuildContext context) {

         String loginMutation(String emailTemp, String passwordTemp) {
          print("test test " + emailTemp + passwordTemp + _deviceName.toString());
    return '''
     mutation {
      login( 
      email: "${emailTemp}"
      password: "${passwordTemp}"
      device: "${_deviceName ?? 'unknown'}"
    )     
    }
        ''';
      }

    final model = Provider.of<HomeModel>(context);
    return GraphQLProvider(
      client: client,
      child: Form(
        key: _formKey,
        child: Scaffold(
          backgroundColor: Color(0xFF005BAB),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(30, 20, 30, 30),
              child: ListView(
                controller: scrollController,
                    shrinkWrap: true,
                  children: <Widget>[
                    SizedBox(height: 50),
                    Image.asset('assets/logo.png',
                    width: 150,
                    height: 150,
                    ),
                    SizedBox(height: 110),
                        TextFieldWidget(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                          return 'Podaj E-mail, pole nie może być puste!';
                           }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        hintText: 'Email',
                        obscureText: false,
                        prefixIconData: Icons.mail_outline, 
                        suffixIconData: model.isValid ? Icons.check: null,
                        onChanged: (value){
                        model.isValidEmail(value);
                        },
                        onTap: () {
                          scrollController.animateTo(scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 200), curve: Curves.easeOut);
                        }, 
                      ),
                    SizedBox(height: 10),
            
                    TextFieldWidget(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                        return 'Podaj hasło, pole nie może być puste!';
                         }
                        return null;
                      },
                      controller: _passwordController,
                      hintText: 'Hasło',
                      obscureText: model.isVisible ? false: true,
                      prefixIconData: Icons.lock_outline,
                      suffixIconData: model.isVisible ? Icons.visibility: Icons.visibility_off,
                      onChanged: (value){
                        model.isValidEmail(value);
                      },
                      onTap: () {
                        scrollController.animateTo(scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 200), curve: Curves.easeOut);
                      }, 
                    ),
                    SizedBox(height: 20),
                   
                    Mutation(options: MutationOptions(
                      document: gql(loginMutation(this._emailController.text, this._passwordController.text)),
                       onCompleted: (dynamic resultData){
                        print(resultData);

                          if(resultData == null){
                            this.result = '';
                          } else {
                          this.result = resultData.toString();
                          this.token = this.result!.substring(30,74);
                          print("token " + this.token);
                          }

                          Map creds = {
                            'email': _emailController.text,
                            'password': _passwordController.text,
                            'device': _deviceName,
                          };

                            if(this.result == ''){
                             ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Container(
                                  height: 50,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC72C41),
                                    borderRadius: BorderRadius.all(Radius.circular(20)),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Błąd!", style: TextStyle(color: Colors.white, fontSize: 18),
                                      overflow: TextOverflow.ellipsis,
                                      ),
                                      Text("Podaj prawidłowe dane"),
                                    ],
                                  ),
                                  ),
                                margin: (MediaQuery.of(context).viewInsets.bottom > 0) ? EdgeInsets.only(bottom: 285) : EdgeInsets.only(bottom: 5),
                                 behavior: SnackBarBehavior.floating, 
                                 backgroundColor: Colors.transparent,
                                 elevation: 0,
                                ),
                                
                              );
                            } else{
                            Auth().saveToken(this.token);
                            Auth().login();
                            Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context) => Home()));
                            print("logowanie zakończone pomyślnie");
                            print("Credentials: " + creds.toString());
                        };

                      },
                    ),
                      builder: (RunMutation? runMutation, QueryResult? queryResult) 
                      { return ButtonWidget(
                        title: 'Logowanie',
                        textColor: Colors.blue.shade100,
                        color: Colors.blue.shade400,
                        boxColor: Colors.blue.shade400,
                        onTap: () { 
                          runMutation!({});
                          
                        if (_formKey.currentState!.validate()) {
                        }
                        });
                      }
                      ),
                      ],
                    ),
              ),
            ),
           ),
        );
}


}