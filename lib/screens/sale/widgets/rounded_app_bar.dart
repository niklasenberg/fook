//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';


class RoundedAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String _text;
  final Color _color;



  const RoundedAppBar(this._text, this._color);

  @override
  Widget build(BuildContext context){
    return AppBar(
          shape: const RoundedRectangleBorder(
            
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20))),
          title:  Text(_text, style: TextStyle(color: _color)),
          centerTitle: true,
          backgroundColor: Colors.white); 
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => throw UnimplementedError();
  }




  













  