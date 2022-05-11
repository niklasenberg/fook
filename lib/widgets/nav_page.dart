import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fook/widgets/chats_page.dart';
import 'package:fook/widgets/home_page.dart';
import 'package:fook/widgets/profile_page.dart';
import 'package:fook/widgets/fook_logo_appbar.dart';

class NavPage extends StatefulWidget {
  const NavPage({Key? key}) : super(key: key);

  @override
  _NavPageState createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: Colors.transparent,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
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
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return HomePage();
          case 1:
            return ChatsPage();
          case 2:
            return ProfilePage();
          default:
            return HomePage();
        }
      },
    );
  }
}


/*return CupertinoTabScaffold(
      appBar: FookAppBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      cupertinoTabBar: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('lib/assets/Fook_back_sm.png'),
              fit: BoxFit.fill),
        ),
        child: 
      ),
    );*/