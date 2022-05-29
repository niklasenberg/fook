import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fook/screens/widgets/sale_card.dart';
import 'package:fook/screens/sale_description_page.dart';
import 'package:fook/theme/colors.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../handlers/book_handler.dart';
import '../handlers/sale_handler.dart';
import '../handlers/user_handler.dart';
import '../model/book.dart';
import '../model/sale.dart';
import 'widgets/fook_logo_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

///Page displaying a book and all sale objects related to it
class BookDescription extends StatefulWidget {
  final Book book;
  final String shortCode;

  const BookDescription(this.book, this.shortCode, {Key? key})
      : super(key: key);

  @override
  State<BookDescription> createState() => _BookDescriptionState();
}

class _BookDescriptionState extends State<BookDescription> {
  //Fetched list of sales
  List<Sale> sales = [];

  //Filters and sorting helpers
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
        appBar: const FookAppBar(
          implyLeading: true,
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        body: Column(children: [
          Row(children: [_bookBox(), _filterBox()]),
          _saleList()
        ]));
  }

  ///Contains picture of book along with title and existing subtitle
  Widget _bookBox() {
    return Container(
      alignment: Alignment.centerLeft,
      height: MediaQuery.of(context).size.height * 0.23,
      width: MediaQuery.of(context).size.width / 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            width: 70,
            child: SizedBox(
              height: 50,
              child: widget.book.info.imageLinks["smallThumbnail"] != null
                  ? Image.network(
                      widget.book.info.imageLinks["smallThumbnail"].toString())
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
    );
  }

  ///Contains radiobuttons and toggleswitch to control filters
  ///and sorting of sale object query
  Widget _filterBox() {
    return SizedBox(
        height: MediaQuery.of(context).size.height * 0.23,
        width: MediaQuery.of(context).size.width / 2,
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.06,
              child: ListTile(
                title: const Text(
                  'Price',
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
                            widget.book, order, FirebaseFirestore.instance);
                      } else {
                        _future = SaleHandler.getCurrentSalesForBook(
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
                title: const Text(
                  'Condition',
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
                            widget.book, order, FirebaseFirestore.instance);
                      } else {
                        _future = SaleHandler.getCurrentSalesForBook(
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
            const Spacer(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
              child: const Text(
                'Include Older Editions',
                style: TextStyle(
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
                            widget.book, order, FirebaseFirestore.instance);
                      } else {
                        _future = SaleHandler.getCurrentSalesForBook(
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
        ));
  }

  ///Visual presentation of Sale objects for the corresponding book
  Widget _saleList() {
    return Container(
      padding: const EdgeInsets.all(4),
      margin: const EdgeInsets.all(8),
      height: MediaQuery.of(context).size.height - 320,
      decoration: BoxDecoration(
        image: const DecorationImage(
            opacity: 0.1,
            scale: 4,
            image: AssetImage(
              "lib/assets/s_logo_o.png",
            )),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.5, 0.5),
            blurRadius: 1,
          ),
        ],
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: CustomColors.fookGradient,
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
              sales = snapshot.data as List<Sale>;
              if (sales.isEmpty) {
                String isbn =
                    widget.book.info.industryIdentifiers.first.identifier;
                return Center(
                  child: ElevatedButton(
                    child: const Text(
                      'Check Campusbokhandeln',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      var url = 'https://campusbokhandeln.se/s/' + isbn;
                      _launchUrl(url);
                    },
                  ),
                );
              }
              return ListView.builder(
                  itemCount: sales.length,
                  itemBuilder: (context, index) => FutureBuilder(
                        future: _getSaleInfo(sales[index]),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            Map<String, dynamic> infoList =
                                snapshot.data as Map<String, dynamic>;
                            return GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SaleDescription(sales[index]))),
                                child: saleCard(
                                    FirebaseAuth.instance.currentUser!.uid,
                                    sales[index].userID,
                                    sales[index],
                                    infoList["seller"],
                                    infoList["book"],
                                    context));
                          }
                          return Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).backgroundColor,
                                    offset: const Offset(2.0,
                                        2.0), // shadow direction: bottom right
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              margin: const EdgeInsets.all(10),
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
          }),
    );
  }
}

///Helper method to send user to webpage
_launchUrl(String url) async {
  if (await canLaunchUrlString(url)) {
    await launchUrlString(url);
  } else {
    throw ('Could not launch $url + :(');
  }
}

///Helper method to retrieve information about Sale objects
_getSaleInfo(Sale sale) async {
  Map<String, dynamic> infoList = {};
  infoList["seller"] =
      await UserHandler.getUser(sale.userID, FirebaseFirestore.instance);
  infoList["book"] = await BookHandler.getBook(sale.isbn);
  return infoList;
}
