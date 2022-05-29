import 'package:flutter/material.dart';
import 'package:fook/screens/chat/chats_page.dart';
import 'package:fook/screens/home_page.dart';
import 'package:fook/screens/profile_page.dart';
import 'package:fook/screens/search_page.dart';
import 'package:fook/screens/widgets/fook_logo_appbar.dart';
import 'package:fook/screens/sale/sale_home_page.dart';
import 'package:fluttericon/elusive_icons.dart';

import '../theme/colors.dart';

///Page for top of widget tree, reached after loggin in
class NavPage extends StatefulWidget {
  const NavPage({Key? key}) : super(key: key);

  @override
  _NavPageState createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> {
  //Default page index (home_page)
  int _selectedIndex = 0;

  //List of child widgets, main pages of app
  static const List<Widget> _pages = <Widget>[
    Center(child: HomePage()),
    Center(child: SearchPage()),
    Center(child: SaleHomePage()),
    Center(child: ChatsPage()),
    Center(child: ProfilePage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FookAppBar(
        implyLeading: false,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 0.5,
                blurRadius: 1.5,
              ),
            ],
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: CustomColors.fookGradient)),
        child: _fookNavBar(),
      ),
    );
  }

  ///Main navigation bar for entire app
  Widget _fookNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.black,
      backgroundColor: Colors.transparent,
      elevation: 0,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
          backgroundColor: Colors.white,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
          backgroundColor: Colors.white,
        ),
        BottomNavigationBarItem(
          icon: Icon(Elusive.tag),
          label: 'Sell',
          backgroundColor: Colors.white,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble),
          label: 'Chat',
          backgroundColor: Colors.white,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
          backgroundColor: Colors.white,
        ),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
    );
  }

  ///Helper method for selecting page in navbar
  _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
