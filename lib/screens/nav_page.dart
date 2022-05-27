import 'package:flutter/material.dart';
import 'package:fook/screens/chat/chats_page.dart';
import 'package:fook/screens/home_page.dart';
import 'package:fook/screens/profile_page.dart';
import 'package:fook/screens/search_page.dart';
import 'package:fook/screens/widgets/fook_logo_appbar.dart';
import 'package:fook/screens/sale/sale_home_page.dart';
import 'package:fluttericon/elusive_icons.dart';

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

  static const List<Widget> _pages = <Widget>[
    Center(child: HomePage()),
    Center(child: SearchPage()),
    Center(child: SaleHomePage()),
    Center(child: ChatsPage()),
    Center(child: ProfilePage()),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FookAppBar(
        implyLeading: false,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 0.5,
                blurRadius: 1.5,
              ),
            ],
            gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xffeae6e6),
            Color(0xfffafafa),
            Color(0xfffaf4f4),
            Color(0xffe5e3e3)
          ],
        )
            // image: DecorationImage(
            //     image: AssetImage('lib/assets/Fook_back_sm.png'),
            //fit: BoxFit.fill),
            ),
        child: BottomNavigationBar(
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
        ),
      ),
    );
  }
}
