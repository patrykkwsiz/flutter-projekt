import 'package:flutter/material.dart';
import 'package:projekt/Screens/pages/settingsPage.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:projekt/Screens/pages/homePage.dart';
import 'package:projekt/Screens/pages/logOut.dart';
class Home extends StatefulWidget{
 
  @override
  State<Home> createState() => _HomeState();
  
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

 void _navigateToHomePage() {
    setState(() {
      _selectedIndex = 1;
    });
  }

 final List<Widget> _pages = [];

@override
  void initState() {
    super.initState();
    _pages.addAll([
      SettingsPage(onConfirm: _navigateToHomePage, activeTabIndex: _selectedIndex,),
      HomePage(),
      LogOut(),
    ]);
  }


  
  void _navigateBottomBar(int index){

    setState(() {
      _selectedIndex = index;
      
    });
  }
@override
  Widget build(BuildContext context){
    return Scaffold(
        backgroundColor: Color(0xFFe7e7e7),
        body:_pages[_selectedIndex],

        
        bottomNavigationBar: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25,),
            child: GNav(
            gap: 5,
            backgroundColor: Colors.white,
            color: Color(0xFF9B9B9B),
            activeColor: Color.fromARGB(255, 74, 73, 73),
            padding: EdgeInsets.all(16),
            onTabChange: _navigateBottomBar,
            selectedIndex: _selectedIndex,
                 tabs: [
            GButton(
              icon: Icons.settings,
              iconSize: 30,
              text: "Ustawienia"),
            
            GButton(
              icon: Icons.home,
              iconSize: 30,
              text: "Strona główna",),
             GButton(
              icon: Icons.logout,
              iconSize: 30,
              text: "Wyloguj",),  
          
                 ],
                ),
          ),
        ),
    );
}
}