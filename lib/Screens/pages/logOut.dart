import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:projekt/Screens/loginScreen.dart';
import 'package:projekt/services/auth.dart';
import 'package:projekt/widgets/buttonWidget.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class LogOut extends StatefulWidget {
  LogOut({super.key});

  @override
  State<LogOut> createState() => _LogOutState();
}

class _LogOutState extends State<LogOut> {
  final storage = new FlutterSecureStorage();
  String? tokenRead = '';

  void initState() {
    super.initState();
    readToken();
    if (mounted == true) {
      setState(() {});
    }
  }

  Future<void> readToken() async {
    tokenRead = await storage.read(key: 'token');
    print("debug test " + tokenRead.toString());
  }

  @override
  Widget build(BuildContext context) {
    final HttpLink _httpLink =
        HttpLink("http://panelcargo.insoft.net.pl/graphql");
    final _authLink = AuthLink(
      getToken: () async => 'Bearer ${tokenRead}',
    );
    Link _link = _authLink.concat(_httpLink);

    final ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        link: _link,
        cache: GraphQLCache(),
      ),
    );

    final String logoutMutation = r'''
     mutation {
      logout{
        id
      }     
     }
        ''';

    return GraphQLProvider(
      client: client,
      child: Scaffold(
        backgroundColor: Color(0xFFe7e7e7),
        body: Column(
          children: [
            SizedBox(
              height: 200,
            ),
            Text(
              "Wylogować?",
              style: TextStyle(
                fontSize: 35,
              ),
            ),
            Mutation(
                options: MutationOptions(
                    document: gql(logoutMutation),
                    onCompleted: (dynamic resultData) {
                      print("id " + resultData.toString());
                    }),
                builder: (RunMutation? runMutation, QueryResult? queryResult) {
                  return SafeArea(
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 100,
                        child: ButtonWidget(
                          title: "Wyloguj",
                          color: Color(0xFFe7e7e7),
                          textColor: Colors.white,
                          boxColor: Color(0xFF005BAB),
                          onTap: () {
                            runMutation!({});
                            Auth().logout();
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()));
                          },
                        ),
                      ),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
