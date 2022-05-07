import 'package:flutter/material.dart';
import 'package:fook/widgets/chats_page.dart';
import 'package:fook/widgets/home_page.dart';
import 'package:fook/widgets/profile_page.dart';

class FookAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;

  FookAppBar({
    this.height = 90.0,
  });

  @override
  Size get preferredSize => Size.fromHeight(this.height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
