import 'package:flutter/material.dart';

class SalePage extends StatefulWidget {
  const SalePage({Key? key}) : super(key: key);

  @override
  State<SalePage> createState() => _SalePageState();
}

class _SalePageState extends State<SalePage> {
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          title: const Text('My sales'),
          centerTitle: true,
          backgroundColor: Colors.white),
      body: const Center(
        child: Text('Create, edit or delete ads'),
      ));

  /*
      appBar: AppBar(
          title: const Text('My sales'),
          centerTitle: true,
          backgroundColor: Colors.white),
      body: const Center(
        child: Text('Create, edit or delete ads'),
      ) 
      */
}
