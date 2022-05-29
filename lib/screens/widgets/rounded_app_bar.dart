import 'package:flutter/material.dart';

///Smaller appbar that appers on some pages (home, sale, chats)
class RoundedAppBar extends StatefulWidget implements PreferredSizeWidget {
  //Parameters
  final String _text;
  final Color _color;
  final String _subtitle;

  const RoundedAppBar(this._text, this._color, this._subtitle, {Key? key})
      : super(key: key);

  @override
  State<RoundedAppBar> createState() => _RoundedAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(60); //Fixed size
}

class _RoundedAppBarState extends State<RoundedAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5))),
      title: Text(widget._text, style: TextStyle(color: widget._color)),
      centerTitle: false,
      elevation: 1,
      backgroundColor: Colors.white,
      bottom: widget._subtitle.isEmpty
          ? null
          : PreferredSize(
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 0, 0, 5),
                alignment: Alignment.centerLeft,
                child: Text(
                  widget._subtitle,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              preferredSize: const Size.fromHeight(1),
            ),
    );
  }
}
