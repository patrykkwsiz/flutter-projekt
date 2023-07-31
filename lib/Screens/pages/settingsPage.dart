import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:projekt/services/auth.dart';
import 'package:projekt/widgets/buttonWidget.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class SettingsPage extends StatefulWidget{
  final VoidCallback onConfirm;
  final int activeTabIndex;

  SettingsPage({required this.onConfirm, required this.activeTabIndex});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? selectedValue;
  String? selectedValue2;
  final storage = new FlutterSecureStorage();  
  String? tokenRead = '';
  bool _isLoading = true;

 void initState() {
    super.initState();
    _isLoading = true;
    readToken();
    readOptions();
  }

  
  Future<void> readToken() async {
    tokenRead = await storage.read(key: 'token');
    print("wut " + tokenRead.toString());
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> readOptions() async {
    this.selectedValue = await storage.read(key: 'selectedValue');
    this.selectedValue2 = await storage.read(key: 'selectedValue2');
  }
   
@override
  Widget build(BuildContext context){
  final HttpLink _httpLink = HttpLink("http://panelcargo.insoft.net.pl/graphql");
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


     final String machineData = r'''
      query{
        reloadingMachines{
          machineName
          id
        }
      }

      ''';

     final String terminalData = r'''
      query{
        userTerminals{
          name
          id
        }
      }     

      ''';


    if(_isLoading){return Scaffold(
       backgroundColor: Color(0xFFe7e7e7),
       body: Container(child: Align(alignment: Alignment.center, child: CircularProgressIndicator(),)))
    ;}
    else{
    return GraphQLProvider(
      client: client,
      child: Scaffold(
        backgroundColor: Color(0xFFe7e7e7),
        body: Center(
          child: Column(
            children: [
        
               Container(
                  margin: EdgeInsets.only(top: 100),
                  child: Query(options: QueryOptions(
                      document: gql(terminalData)),
                  
                   builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) 
                   {
                   
                    if(result.hasException){
                    return Text(result.exception.toString());
                  }
                    if(result.isLoading)
                    {return Container( width: 350,
                      height: 50,
                      padding: EdgeInsets.all(2),
                       decoration: BoxDecoration(
                        color: Colors.white,),
                        child: Row(
                          children: [
                            CircularProgressIndicator(),
                            Container(
                              width: 306,
                              height: 50,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Icon(
                                  Icons.arrow_drop_down,
                                  color: Color(0xFF9B9B9B),
                                ),
                              ),
                            ),
                          ],
                        ),
                        );}
                        
        
                    List? test = result.data?['userTerminals'];
                      print(test!.first);
        
                    return Container(
                     width: 350,
                     height: 50,
                      padding: EdgeInsets.all(2),
                       decoration: BoxDecoration(
                        color: Colors.white,),
                      child: ButtonTheme(
                        alignedDropdown: true,
        
                      child: DropdownButton(
                        hint: Text("Wybierz terminal"),
                        underline: Container(color: Colors.transparent,),
                        value: selectedValue2,
                        isExpanded: true,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF9B9B9B),),
                        items: test.map((e) {
                          return DropdownMenuItem<String>(child: new Text(e["name"]), value: e["id"],);
                          }).toList(),
                        onChanged: (v){
                          
                          setState(() {});
                          selectedValue2 = v;
                        }),
                    ),
                    );
                   },
                  ),
                ), 
        
                Container(
                  margin: EdgeInsets.only(top: 50),
                  child: Query(options: QueryOptions(
                      document: gql(machineData)),
                  
                   builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) 
                   {
                   
                    if(result.hasException){
                    return Text(result.exception.toString());
                  }
                     if(result.isLoading)
                    {return Container( width: 350,
                      height: 50,
                      padding: EdgeInsets.all(2),
                       decoration: BoxDecoration(
                        color: Colors.white,),
                        
                        child: Row(
                          children: [
                            CircularProgressIndicator(),
                            Container(
                              width: 306,
                              height: 50,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Icon(
                                  Icons.arrow_drop_down,
                                  color: Color(0xFF9B9B9B),
                                ),
                              ),
                            ),
                          ],
                        ),
                        );}
        
        
                    List? test = result.data?['reloadingMachines'];
                      print(test!.first);
        
                    return Container(
                      width: 350,
                      height: 50,
                      padding: EdgeInsets.all(2),
                       decoration: BoxDecoration(
                        color: Colors.white,),
                      child: ButtonTheme(
                        alignedDropdown: true,
                        
                        child: DropdownButton(
                          hint: Text("Wybierz maszynę"),
                          isExpanded: true,
                          underline: Container(color: Colors.transparent,),
                          value: selectedValue,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFF9B9B9B),),
                          items: test.map((e) {
                            return DropdownMenuItem<String>(child: new Text(e["machineName"]), value: e["id"],);
                            }).toList(),
                          onChanged: (v){
                            
                            setState(() {});
                            selectedValue = v;
                          }),
                      ),
                    );
                   },
                  ),
                ),
        
                SizedBox(height: 50,),
        
                Container(
                  width: 100,
                  height: 50,
                  child: ButtonWidget(
                    textColor: Colors.white,
                    title: "Potwierdź",
                    boxColor: Color(0xFF005BAB),
                    color: Color(0xFFe7e7e7),
                    onTap: () {
                    Auth().saveOptions(this.selectedValue.toString(), this.selectedValue2.toString());
                    ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  width: 160,
                                  content: Container(
                                  height: 15,
                                  color: Colors.transparent,
                                  child: Stack(
                                   
                                    children: [
                                    
                                    Text("Zapisano wybór",
                                    style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),),

                                    
                                        Container(
                                          margin: EdgeInsets.fromLTRB(110,0,0,25),
                                          child:  Icon(Icons.check,
                                            color: Colors.white,
                                            size: 18,
                                            ),
                                                                        
                                        
                                      ),
                                    

                                  ]),
                                ),
                                 behavior: SnackBarBehavior.floating, 
                                 backgroundColor: const Color(0xFF005BAB),
                                 elevation: 0,
                                ),
                          );
                        widget.onConfirm();
                    },
                    
                    ),
                )
        
            ],
          ),
        ),
        
          ),
    );
  }
}
}