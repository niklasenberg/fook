import 'package:flutter/material.dart';
import 'package:fook/screens/nav_page.dart';

///Appbar that persists over all pages
class FookAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool implyLeading; //Toggle back button, default is off

  const FookAppBar({
    Key? key,
    required this.implyLeading,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(85); //Fixed size

  @override
  Widget build(BuildContext context) {
    return AppBar(
        automaticallyImplyLeading: implyLeading,
        iconTheme: const IconThemeData(
          color: Colors.white, //change your color here
        ),
        //Clickable logo to return to homepage
        title: GestureDetector(
            onTap: () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const NavPage())),
            child: Image.asset(
              'lib/assets/logo_w.png',
              height: 50,
            )),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('lib/assets/Fook_back_sm.png'),
                  fit: BoxFit.fill)),
        ));
  }
}
