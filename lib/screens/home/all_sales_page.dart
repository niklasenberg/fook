import 'package:flutter/material.dart';
import 'package:fook/handlers/book_handler.dart';
import 'package:fook/handlers/user_handler.dart';
import 'package:fook/screens/home/sale_description_page.dart';
import '../../handlers/sale_handler.dart';
import '../../model/book.dart';
import '../../model/course.dart';
import '../../model/sale.dart';
import '../../model/user.dart';
import '../fook_logo_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllSalesPage extends StatefulWidget {
  final Course course;
  bool showOlder = false;
  AllSalesPage(this.course, {Key? key}) : super(key: key);

  @override
  State<AllSalesPage> createState() => _AllSalesPageState();
}

class _AllSalesPageState extends State<AllSalesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: FookAppBar(
      implyLeading: true,
    ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Scaffold(appBar: AppBar(backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20))),
        centerTitle: false,
        title: RichText(
          text: TextSpan(
                text: widget.course.shortCode,
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 18)),
        ),
        bottom: PreferredSize(
          child: Container(padding: const EdgeInsets.fromLTRB(18, 0, 0, 5),
            alignment: Alignment.centerLeft,
            child: Text(widget.course.name,
              style: TextStyle(fontSize: 14),),
          ),
          preferredSize: const Size.fromHeight(1),
        ),
      ),
          body: Column(children: [
              Container(
                  width: double.infinity,
                  margin: EdgeInsets.fromLTRB(4, 0, 0, 0),
                  child: Row(
                    children: [
                      SizedBox(width: 4,),
                      DropdownButton<String>(
                        hint: Text(
                          'Sort by',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        items:
                            <String>['Price', 'Condition'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (_) {},
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                      ),
                      SizedBox(height: 40,
                          width: 50,child: CheckboxListTile(
                        title: Text("Show older"),
                        value: widget.showOlder,
                        onChanged: (newValue) {
                          setState(() {
                            widget.showOlder = newValue!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
                      ))
    ])
    ),
              Container(
            padding: EdgeInsets.all(4),
            margin: EdgeInsets.all(8),
            height: MediaQuery.of(context).size.height*0.64,
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                  ),
                  BoxShadow(
                    color: Colors.white,
                    spreadRadius: -2.0,
                    blurRadius: 12.0,
                  ),
                ], borderRadius: BorderRadius.all(Radius.circular(8))
            ),child: FutureBuilder(future: SaleHandler.getSalesForCourse(widget.course.shortCode, FirebaseFirestore.instance),
              builder: (context, snapshot){
                if (snapshot.hasData) {
                  List<Sale> sales = snapshot.data as List<Sale>;
                  if (sales.isEmpty){
                    return Center(child: Text("We are all out of books for this course! :("),);
                  }
                  return ListView.builder(
                      itemCount: sales.length,
                      itemBuilder: (context, index) => FutureBuilder(
                        future: _getInfo(sales[index]),
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
                                                sales[index]))),
                                child: SaleCard(
                                    sales[index],
                                    infoList["seller"],
                                    infoList["book"],
                                    context));
                          }
                          return Container(decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).backgroundColor,
                                offset: Offset(2.0, 2.0), // shadow direction: bottom right
                              ),
                            ],
                            borderRadius: BorderRadius.circular(20),
                          ),
                              margin: EdgeInsets.all(10),
                              width: double.infinity,
                              height: 150,
                              child: Center(
                                  child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation(
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
              }),)],)),
    );
  }
}

_getInfo(Sale sale) async {
  Map<String, dynamic> infoList = {};
  infoList["seller"] = await UserHandler.getUser(sale.userID, FirebaseFirestore.instance);
  infoList["book"] = await BookHandler.getBook(sale.isbn);
  return infoList;
}

Widget SaleCard(Sale sale, User seller, Book book, context) {
  Color background = Colors.grey.shade300;
  Color fill = Colors.white;
  final List<Color> gradient = [
    background,
    background,
    fill,
    fill,
  ];
  const double fillPercent = 50; // fills 56.23% for container from bottom
  const double fillStop = (100 - fillPercent) / 100;
  const List<double> stops = [0.0, fillStop, fillStop, 1.0];
  return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(2.0, 2.0), // shadow direction: bottom right
              ),
            ],
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: gradient,
              stops: stops,
              end: Alignment.bottomCenter,
              begin: Alignment.topCenter,
            ),
          ),
          margin: EdgeInsets.all(10),
          width: double.infinity,
          height: 150,
          child: Stack(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(
                              2.0, 2.0), // shadow direction: bottom right
                        ),
                      ],
                    ),
                    height: 130,
                    child: Image.network(
                        book.info.imageLinks["smallThumbnail"].toString()),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  // Texts
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        // UEC607 & Digital communication text
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Flexible(
                                  child: RichText(
                                    text: TextSpan(children: <TextSpan>[
                                      TextSpan(
                                          text: (book.info.title +
                                              ": " +
                                              book.info.subtitle)
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                          )),
                                    ]),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Flexible(
                                  child: RichText(
                                    text: TextSpan(children: <TextSpan>[
                                      const TextSpan(
                                          text: "ISBN: ",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12)),
                                      TextSpan(
                                          text: sale.isbn,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          )),
                                    ]),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Flexible(
                                  child: RichText(
                                    text: TextSpan(children: <TextSpan>[
                                      const TextSpan(
                                          text: "Seller: ",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12)),
                                      TextSpan(
                                          text: seller.name +
                                              " " +
                                              seller.lastName,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontSize: 12)),
                                    ]),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Flexible(
                                  child: RichText(
                                    text: TextSpan(children: <TextSpan>[
                                      const TextSpan(
                                          text: "Condition: ",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12)),
                                      TextSpan(
                                          text: sale.condition,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontSize: 12)),
                                    ]),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              alignment: Alignment.bottomRight,
                              padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                              child: RichText(
                                text: TextSpan(children: <TextSpan>[
                                  TextSpan(
                                      text: sale.price.toString() + ":-",
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                                ]),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ));
}
