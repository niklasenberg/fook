import 'package:flutter/material.dart';
import 'package:fook/screens/widgets/sale_description_page.dart';

import '../../handlers/book_handler.dart';
import '../../handlers/sale_handler.dart';
import '../../handlers/user_handler.dart';
import '../../model/book.dart';
import '../../model/sale.dart';
import 'fook_logo_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookDescription extends StatefulWidget {
  final Book book;
  final String shortCode;
  List<Sale> sales = [];

  BookDescription(this.book, this.shortCode, {Key? key}) : super(key: key);

  @override
  State<BookDescription> createState() => _BookDescriptionState();
}

class _BookDescriptionState extends State<BookDescription> {
  late Future _future;
  late bool showOlder;
  late String order;

  @override
  void initState() {
    super.initState();
    order = "Price";
    _future = SaleHandler.getCurrentSalesForBook(
        widget.book, widget.shortCode, order, FirebaseFirestore.instance);
    showOlder = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: FookAppBar(
          implyLeading: true,
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        body: Column(
          children: [
            Row(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  height: MediaQuery.of(context).size.height * 0.23,
                  width: MediaQuery.of(context).size.width/2,
                  child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: 10),
                          SizedBox(
                            height: 100,
                            width: 70,
                            child: Container(
                              decoration: const BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(2.0,
                                        2.0), // shadow direction: bottom right
                                  ),
                                ],
                              ),
                              height: 50,
                              child: Image.network(widget
                                  .book.info.imageLinks["smallThumbnail"]
                                  .toString()),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Flexible(child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  (widget.book.info.title +
                                      ": " +
                                      widget.book.info.subtitle)
                                      .toUpperCase(),
                                  overflow: TextOverflow.fade,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),)
                        ],
                      ),
                ),
                Container(height: MediaQuery.of(context).size.height * 0.23,
                  width: MediaQuery.of(context).size.width/2, child: Column( children: [
                    SizedBox(height: 30),
                      DropdownButton<String>(
                        hint: Text(
                          'Sort by: ',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        items: <String>['Price', 'Condition'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            order = newValue!;
                            if(showOlder){
                              _future = SaleHandler.getSalesForBook(
                                  widget.book, order, FirebaseFirestore.instance);
                            }else{
                              _future = SaleHandler.getCurrentSalesForBook(
                                  widget.book, widget.shortCode, order, FirebaseFirestore.instance);
                            }
                          });
                        },
                      ),
                      SizedBox(height: 10,),
                      CheckboxListTile(
                        title: Text("Show older",
                            textAlign: TextAlign.center),
                        value: showOlder,
                        onChanged: (newValue) {
                          setState(() {
                            showOlder = newValue!;
                            if(showOlder){
                              _future = SaleHandler.getSalesForBook(
                                  widget.book, order, FirebaseFirestore.instance);
                            }else{
                              _future = SaleHandler.getCurrentSalesForBook(
                                  widget.book, widget.shortCode, order, FirebaseFirestore.instance);
                            }
                          });
                        }, //  <-- leading Checkbox
                      )

                    ],))
              ],
            ),
            Container(
              padding: EdgeInsets.all(4),
              margin: EdgeInsets.all(8),
              height: MediaQuery.of(context).size.height * 0.58,
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                ),
                BoxShadow(
                  color: Colors.white,
                  spreadRadius: -2.0,
                  blurRadius: 12.0,
                ),
              ], borderRadius: BorderRadius.all(Radius.circular(8))),
              child: FutureBuilder(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return Center(
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(
                        Theme.of(context).colorScheme.primary,
                      )));
                    }
                    if (snapshot.hasData) {
                      widget.sales = snapshot.data as List<Sale>;
                      if (widget.sales.isEmpty) {
                        return Center(
                          child: Text(
                              "There are no current books for this course! :("),
                        );
                      }
                      return ListView.builder(
                          itemCount: widget.sales.length,
                          itemBuilder: (context, index) => FutureBuilder(
                                future: _getInfo(widget.sales[index]),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    Map<String, dynamic> infoList =
                                        snapshot.data as Map<String, dynamic>;
                                    return GestureDetector(
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SaleDescription(
                                                        widget.sales[index]))),
                                        child: SaleCard(
                                            widget.sales[index],
                                            infoList["seller"],
                                            infoList["book"],
                                            context));
                                  }
                                  return Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context)
                                                .backgroundColor,
                                            offset: Offset(2.0,
                                                2.0), // shadow direction: bottom right
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      margin: EdgeInsets.all(5),
                                      width: double.infinity,
                                      height: 150,
                                      child: Center(
                                          child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                        Theme.of(context).colorScheme.primary,
                                      ))));
                                },
                              ));
                    }
                    return Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                      Theme.of(context).colorScheme.primary,
                    )));
                  }),
            )
          ],
        ));
  }
}

/*Row(mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.network(widget.book.info.imageLinks["smallThumbnail"].toString()),
                        SizedBox(
                          width: 4,
                        ),
                        DropdownButton<String>(
                          hint: Text(
                            'Sort by: ',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          items: <String>['Price', 'Condition'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              order = newValue!;
                              if(showOlder){
                                _future = SaleHandler.getSalesForBook(
                                    widget.book, order, FirebaseFirestore.instance);
                              }else{
                                _future = SaleHandler.getCurrentSalesForBook(
                                    widget.book, widget.shortCode, order, FirebaseFirestore.instance);
                              }
                            });
                          },
                        ),
                        Container(
                            width: 200,
                            child: CheckboxListTile(

                              title: Text("Show older",
                                  textAlign: TextAlign.center),
                              value: showOlder,
                              onChanged: (newValue) {
                                setState(() {
                                  showOlder = newValue!;
                                  if(showOlder){
                                    _future = SaleHandler.getSalesForBook(
                                        widget.book, order, FirebaseFirestore.instance);
                                  }else{
                                    _future = SaleHandler.getCurrentSalesForBook(
                                        widget.book, widget.shortCode, order, FirebaseFirestore.instance);
                                  }
                                });
                              }, //  <-- leading Checkbox
                            ))*/

_getInfo(Sale sale) async {
  Map<String, dynamic> infoList = {};
  infoList["seller"] =
      await UserHandler.getUser(sale.userID, FirebaseFirestore.instance);
  infoList["book"] = await BookHandler.getBook(sale.isbn);
  return infoList;
}
