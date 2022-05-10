//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

class SalePage extends StatefulWidget {
  const SalePage({Key? key}) : super(key: key);

  @override
  State<SalePage> createState() => _SalePageState();
}

class _SalePageState extends State<SalePage> {
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20))),
          title: const Text('MY SALES', style: TextStyle(color: Colors.orange)),
          centerTitle: true,
          backgroundColor: Colors.white),
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
            Container(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: const Text('No ads to be shown')),
            Container(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: const Text('Create new'))
          ])));
}
