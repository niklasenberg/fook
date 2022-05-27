import 'package:flutter/material.dart';
import 'package:fook/screens/widgets/sale_card.dart';
import 'package:fook/screens/sale_description_page.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../handlers/book_handler.dart';
import '../handlers/sale_handler.dart';
import '../handlers/user_handler.dart';
import '../model/book.dart';
import '../model/sale.dart';
import 'widgets/fook_logo_appbar.dart';
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
  late String isbn = widget.key.toString();

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
                  width: MediaQuery.of(context).size.width / 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 10),
                      SizedBox(
                        height: 100,
                        width: 70,
                        child: Container(
                          height: 50,
                          child:
                              widget.book.info.imageLinks["smallThumbnail"] !=
                                      null
                                  ? Image.network(widget
                                      .book.info.imageLinks["smallThumbnail"]
                                      .toString())
                                  : Image.asset(
                                      "lib/assets/placeholderthumbnail.png",
                                      width: 70,
                                      height: 3,
                                    ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                widget.book.info.subtitle.isNotEmpty
                                    ? (widget.book.info.title +
                                            ": " +
                                            widget.book.info.subtitle)
                                        .toUpperCase()
                                    : widget.book.info.title.toUpperCase(),
                                overflow: TextOverflow.fade,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                    height: MediaQuery.of(context).size.height * 0.23,
                    width: MediaQuery.of(context).size.width / 2,
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.06,
                          child: ListTile(
                            title: Text('Price',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            leading: Radio(
                              value: 'Price',
                              groupValue: order,
                              onChanged: (value) {
                                setState(() {
                                  order = value.toString();
                                  if (showOlder) {
                                    _future = SaleHandler.getSalesForBook(
                                        widget.book,
                                        order,
                                        FirebaseFirestore.instance);
                                  } else {
                                    _future =
                                        SaleHandler.getCurrentSalesForBook(
                                            widget.book,
                                            widget.shortCode,
                                            order,
                                            FirebaseFirestore.instance);
                                  }
                                });
                              },
                              autofocus: true,
                              activeColor: Theme.of(context).highlightColor,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.06,
                          child: ListTile(
                            title: Text('Condition',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            leading: Radio(
                              value: 'Condition',
                              groupValue: order,
                              onChanged: (value) {
                                setState(() {
                                  order = value.toString();
                                  if (showOlder) {
                                    _future = SaleHandler.getSalesForBook(
                                        widget.book,
                                        order,
                                        FirebaseFirestore.instance);
                                  } else {
                                    _future =
                                        SaleHandler.getCurrentSalesForBook(
                                            widget.book,
                                            widget.shortCode,
                                            order,
                                            FirebaseFirestore.instance);
                                  }
                                });
                              },
                              activeColor: Theme.of(context).highlightColor,
                            ),
                          ),
                        ),

                        Spacer(),

                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                          child: Text(
                            'Include Older Editions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.06,
                            child: Switch(
                              value: showOlder,
                              onChanged: (newValue) {
                                setState(() {
                                  showOlder = newValue;
                                  if (showOlder) {
                                    _future = SaleHandler.getSalesForBook(
                                        widget.book,
                                        order,
                                        FirebaseFirestore.instance);
                                  } else {
                                    _future =
                                        SaleHandler.getCurrentSalesForBook(
                                            widget.book,
                                            widget.shortCode,
                                            order,
                                            FirebaseFirestore.instance);
                                  }
                                });
                              },
                              activeColor: Theme.of(context).highlightColor,
                            )),
                      ],
                    ))
              ],
            ),
            Container(
              padding: EdgeInsets.all(4),
              margin: EdgeInsets.all(8),
              height: MediaQuery.of(context).size.height - 320,
              decoration: BoxDecoration(
                image: DecorationImage(
                    opacity: 0.1,
                    scale: 4,
                    image: AssetImage(
                      "lib/assets/s_logo_o.png",
                    )),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.5, 0.5),
                    blurRadius: 1,
                  ),
                ],
                borderRadius: BorderRadius.all(Radius.circular(8)),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xffeae6e6),
                    Color(0xfffafafa),
                    Color(0xfffaf4f4),
                    Color(0xffe5e3e3)
                  ],
                ),
              ),
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
                        String isbn = widget.book.info.industryIdentifiers.first.identifier;
                        return Center(
                          child: ElevatedButton(
                            child: const Text('Check Campusbokhandeln'),
                            onPressed: () {
                              var url = 'https://campusbokhandeln.se/s/' + isbn;
                              launchUrl(url);
                            },
                          ),
                        );
                        // Här ska campusbokhandeln komma in
                        /*return Center(
                          child: Text("No sales published for this book! :("),
                        );*/
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
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      margin: EdgeInsets.all(10),
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

launchUrl(String url) async {
  if (await canLaunchUrlString(url)) {
    await launchUrlString(url);
  } else {
    throw ('Could not launch $url + :(');
  }
}

_getInfo(Sale sale) async {
  Map<String, dynamic> infoList = {};
  infoList["seller"] =
      await UserHandler.getUser(sale.userID, FirebaseFirestore.instance);
  infoList["book"] = await BookHandler.getBook(sale.isbn);
  return infoList;
}