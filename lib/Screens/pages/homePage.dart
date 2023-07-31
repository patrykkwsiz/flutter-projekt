import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:easy_debounce/easy_debounce.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool? hasMorePages = true;
  int? lastItem;
  final storage = new FlutterSecureStorage();
  String? tokenRead = '';
  bool _isLoading = true;
  IconData? fromIcon;
  IconData? toIcon;
  String searchText = '';
  dynamic help;
  final TextEditingController _searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  int currentPage = 1;

  void initState() {
    super.initState();
    _isLoading = true;
    readToken();
  }

  Future<void> readToken() async {
    tokenRead = await storage.read(key: 'token');
    print("wut " + tokenRead.toString());
    setState(() {
      _isLoading = false;
    });
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

    String infoQuery(int currentPage) {
      return '''query {
toReloadForLoggedInOperator(first: 20, page: ${this.currentPage}){
paginatorInfo{
  currentPage
  hasMorePages
  lastItem
  total
}
data{
  containerNumber
  from	
  to
  cargoWeight
  grossWeight
}
}
}
''';
    }

    if (_isLoading) {
      return Scaffold(
          backgroundColor: Color(0xFFe7e7e7),
          body: Container(
              child: Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          )));
    } else {
      return GraphQLProvider(
          client: client,
          child: Scaffold(
            backgroundColor: Color(0xFFe7e7e7),
            body: Query(
                options: QueryOptions(
                  document: gql(infoQuery(currentPage)),
                  variables: {'currentPage': currentPage},
                ),
                builder: (QueryResult result,
                    {VoidCallback? refetch, FetchMore? fetchMore}) {
                  if (result.hasException)
                    return Text(result.exception.toString());
                  if (result.isLoading && this.currentPage == 1)
                    return Center(child: CircularProgressIndicator());

                  final data =
                      result.data?['toReloadForLoggedInOperator']['data'];

                  final paginator = result.data?['toReloadForLoggedInOperator']
                      ['paginatorInfo'];
                  print(paginator);

                  FetchMoreOptions opts = FetchMoreOptions(
                      variables: {'currentPage': currentPage},
                      updateQuery: (previousResultData, fetchMoreResultData) {
                        if (paginator['hasMorePages'] == true) {
                          print("test " + currentPage.toString());
                        }

                        final List<dynamic> repos = [
                          ...previousResultData!['toReloadForLoggedInOperator']
                              ['data'] as List<dynamic>,
                          ...fetchMoreResultData!['toReloadForLoggedInOperator']
                              ['data'] as List<dynamic>,
                        ];
                        fetchMoreResultData['toReloadForLoggedInOperator']
                            ['data'] = repos;
                        return fetchMoreResultData;
                      });

                  final List<Map<String, dynamic>>? dataList =
                      (data as List?)?.cast<Map<String, dynamic>>();
                  List<Map<String, dynamic>> filteredData = dataList ?? [];
                  if (searchText.isNotEmpty) {
                    filteredData = dataList!
                        .where((item) => item['containerNumber']
                            .toString()
                            .toLowerCase()
                            .contains(searchText.toLowerCase()))
                        .toList();
                  }

                  return Stack(children: [
                    Container(
                        padding: EdgeInsets.fromLTRB(360, 30, 5, 0),
                        child: IconButton(
                          icon: Icon(Icons.clear),
                          iconSize: 20,
                          onPressed: () {
                            setState(() {
                              searchText = '';
                              _searchController.clear();
                            });
                          },
                        )),
                    Column(children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(30, 20, 40, 0),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            EasyDebounce.debounce(
                                'debouncer',
                                Duration(milliseconds: 900),
                                () => setState(() {
                                      searchText = value;
                                    }));
                          },
                          onSubmitted: (value) {
                            setState(() {
                              searchText = _searchController.text;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Wyszukaj...',
                            contentPadding: EdgeInsets.fromLTRB(2, 20, 0, 0),
                          ),
                        ),
                      ),
                      Expanded(
                        child: NotificationListener(
                          onNotification: (t) {
                            if (t is ScrollEndNotification &&
                                _scrollController.position.pixels >=
                                    _scrollController
                                        .position.maxScrollExtent) {
                              fetchMore!(opts);
                              //setState(() {});
                              currentPage++;
                              print("test 2" + currentPage.toString());
                            }
                            return true;
                          },
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: filteredData.length,
                                itemBuilder: (context, index) {
                                  final item = filteredData[index];
                                  return Container(
                                    height: 100,
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Column(
                                      children: [
                                        ListTile(
                                          title: Text(
                                              'Kontener: ${item['containerNumber']}',
                                              style: TextStyle(
                                                  color: Colors.black)),
                                          trailing: Column(
                                            children: [
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Text('Z: ${item['from']}',
                                                  style: TextStyle(
                                                      color: Colors.black)),
                                              Text('Do: ${item['to']}',
                                                  style: TextStyle(
                                                      color: Colors.black)),
                                            ],
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            margin: EdgeInsets.only(left: 16),
                                            child: Column(
                                              children: [
                                                Text(
                                                    item['grossWeight'] != null
                                                        ? 'Gross Weight: ${item['grossWeight']}'
                                                        : 'Gross Weight: Nie podano',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15.5)),
                                                Text(
                                                    item['cargoWeight'] != null
                                                        ? 'Cargo weight: ${item['cargoWeight']}'
                                                        : 'Cargo Weight: Nie podano',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15.5)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                          ),
                        ),
                      ),
                    ]),
                  ]);
                }),
          ));
    }
  }
}
