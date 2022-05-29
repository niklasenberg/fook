import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttericon/elusive_icons.dart';
import '../../handlers/sale_handler.dart';
import '../../model/book.dart';
import '../../model/sale.dart';
import '../../utils.dart';
import '../widgets/fook_logo_appbar.dart';
import '../widgets/rounded_app_bar.dart';

///Page for editing existing Sale objects
class EditSale extends StatefulWidget {
  //Existing Sale and book object, retrieved from sale_home_page
  final Book thisbook;
  final Sale thissale;

  const EditSale({
    Key? key,
    required this.thisbook,
    required this.thissale,
  }) : super(key: key);

  @override
  State<EditSale> createState() => _EditSaleState();
}

class _EditSaleState extends State<EditSale> {
  //Controllers for editable parameters
  TextEditingController priceController = TextEditingController();
  TextEditingController conditionController = TextEditingController();
  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    priceController.text = widget.thissale.price.toString();
    commentController.text = widget.thissale.description;
    conditionController.text = widget.thissale.condition;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: const FookAppBar(
        implyLeading: true,
      ),
      body: _editSaleForm());

  ///Form for editing Sale parameters
  Widget _editSaleForm() {
    return SingleChildScrollView(
      child: Column(children: [
        RoundedAppBar("EDIT SALE", Theme.of(context).highlightColor, ""),
        Container(
            //Nedersta rektangeln (För att kunna färgfylla, skugga osv)
            margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            padding: const EdgeInsets.all(15),
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.74,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(1.0, 1.0),
                  blurRadius: 2,
                  spreadRadius: 0.5,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          TextFormField(
                            enabled: false,
                            initialValue: widget.thissale.isbn,
                            decoration: const InputDecoration(
                              label: Text(
                                "ISBN",
                                style: (TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600)),
                              ),
                              filled: true,
                              fillColor: Color.fromARGB(255, 228, 227, 227),
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(/*Skanna streckkod och ruta*/
                          children: [
                        const Text("Scan barcode:",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        MaterialButton(
                          height: 50,
                          color: const Color.fromARGB(255, 228, 227, 227),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          onPressed: () {},
                          child: const Icon(
                            Elusive.barcode,
                            color: Colors.white,
                            size: 30,
                          ),
                        )
                      ]),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                        height: 55,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: TextFormField(
                          initialValue: widget.thisbook.info.title,
                          decoration: const InputDecoration(
                              label: Text(
                                "Title",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600),
                              ),
                              filled: true,
                              fillColor: Color.fromARGB(255, 228, 227, 227)),
                          enabled: false,
                        )),
                    Container(
                      child: TextFormField(
                        initialValue: widget.thisbook.info.authors.toString(),
                        //controller: authorController,
                        decoration: const InputDecoration(
                            label: Text(
                              "Authors",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                            filled: true,
                            fillColor: Color.fromARGB(255, 228, 227, 227)),
                        enabled: false,
                      ),
                      height: 55,
                      margin: const EdgeInsets.only(bottom: 10),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                          height: 55,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: Theme.of(context).highlightColor,
                              )),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                                value: conditionController.text,
                                iconSize: 36,
                                icon: const Icon(Icons.arrow_drop_down,
                                    color: Colors.black),
                                isExpanded: true,
                                items: Utility.items
                                    .map((item) => DropdownMenuItem(
                                        value: item, child: Text(item)))
                                    .toList(),
                                onChanged: (value) => setState(() =>
                                    conditionController.text =
                                        value.toString())),
                          )),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        controller: priceController,
                        //kan ej ha controller och initialvalue
                        decoration: const InputDecoration(
                          label: Text(
                            "Your price",
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        enabled: true,

                        inputFormatters: [
                          LengthLimitingTextInputFormatter(4),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: TextField(
                        controller: commentController,
                        decoration: const InputDecoration(
                          label: Text(
                            "Comments",
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        enabled: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Stack(
                      children: [
                        _deleteButton(),
                        _updateButton(),
                      ],
                    )
                  ],
                ),
              ],
            )),
      ]),
    );
  }

  ///Button for deletion of Sale objects
  Widget _deleteButton() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: ElevatedButton.icon(
        label: const Text('Delete'),
        icon: const Icon(Icons.delete),
        style: ElevatedButton.styleFrom(
          onPrimary: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: (() {
          _deleteDialog(context);
        }),
      ),
    );
  }

  ///Button for updating Sale objects
  Widget _updateButton() {
    return Align(
      alignment: Alignment.bottomRight,
      child: ElevatedButton.icon(
          label: const Text('Update'),
          icon: const Icon(Icons.update),
          style: ElevatedButton.styleFrom(
            onPrimary: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () {
            if (priceController.text.isNotEmpty) {
              _updateSale(
                commentController.text,
                conditionController.text,
                int.parse(priceController.text),
                context,
                widget.thissale.saleID,
              );
              Navigator.pop(context);
            } else {
              Utility.toastMessage("Price can't be empty", 2, Colors.red);
            }
          }),
    );
  }

  ///Dialog for deleting Sale objects
  _deleteDialog(BuildContext context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              side: BorderSide(
                  color: Theme.of(context).colorScheme.primary, width: 3),
            ),
            contentPadding: const EdgeInsets.only(top: 10.0),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.15,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.015,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: const <Widget>[
                      Text(
                        "Delete sale?",
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(
                                  color: Colors.black,
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                ),
                              ),
                            ),
                          ),
                          child: const Text(
                            'Yes',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            SaleHandler.removeSale(widget.thissale.saleID,
                                FirebaseFirestore.instance);
                            Utility.toastMessage("Sale removed", 1, Colors.red);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.05,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(
                                  color: Colors.black,
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                ),
                              ),
                            ),
                          ),
                          child: const Text('No',
                              style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  ///Helper method for updating Sale object in database
  _updateSale(
    String description,
    String condition,
    int price,
    BuildContext context,
    String saleID,
  ) async {
    SaleHandler.updateSale(
      description,
      condition,
      price,
      saleID,
      FirebaseFirestore.instance,
    );
    Utility.toastMessage('Updated', 1, Colors.green);
    return true;
  }
}
