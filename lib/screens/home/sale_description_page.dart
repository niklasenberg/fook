import 'package:flutter/material.dart';
import 'package:fook/model/sale.dart';
import 'package:fook/screens/fook_logo_appbar.dart';

class SaleDescription extends StatefulWidget {
  final Sale sale;
  const SaleDescription(this.sale, {Key? key}) : super(key: key);

  @override
  State<SaleDescription> createState() => _SaleDescriptionState();
}

class _SaleDescriptionState extends State<SaleDescription> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: FookAppBar(implyLeading: true,),
    backgroundColor: Theme.of(context).backgroundColor,
    );
  }
}
