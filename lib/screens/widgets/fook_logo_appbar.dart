import 'package:flutter/material.dart';
import 'package:fook/screens/chat/chats_page.dart';
import 'package:fook/screens/home/home_page.dart';
import 'package:fook/screens/profile_page.dart';

class FookAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  bool implyLeading = false;

  FookAppBar({
    this.height = 85.0,
    required this.implyLeading,
  });

  @override
  Size get preferredSize => Size.fromHeight(this.height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: implyLeading,
      iconTheme: const IconThemeData(
        color: Colors.white, //change your color here
      ),
      title: Image.asset(
        'lib/assets/logo_w.png',
        height: 50,
      ),
      centerTitle: true,
      flexibleSpace: Container( 
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('lib/assets/Fook_back.png'),
                fit: BoxFit.fill)),
      ),
    );
  }
}
