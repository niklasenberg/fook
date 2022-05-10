import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fook/handlers/book_handler.dart';
import 'package:fook/handlers/course_handler.dart';
import 'package:fook/model/course.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fook/handlers/user_handler.dart';
import 'package:fook/model/user.dart' as fook;
import 'package:fook/handlers/sale_handler.dart';
import 'package:fook/model/sale.dart';
import 'package:fook/model/book.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: UserHandler.getUser(
            FirebaseAuth.instance.currentUser!.uid, FirebaseFirestore.instance),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            fook.User thisUser = snapshot.data as fook.User;
            return Scaffold(
              appBar: AppBar(
                centerTitle: false,
                title: RichText(
                  text: TextSpan(children: <TextSpan>[
                    TextSpan(
                        text: "Welcome ",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 20)),
                    TextSpan(
                        text: thisUser.name,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ]),
                ),
                bottom: PreferredSize(
                  child: Container(padding: const EdgeInsets.fromLTRB(18, 0, 0, 5),
                    alignment: Alignment.centerLeft,
                    child: const Text("Your current courses",
                    style: TextStyle(fontSize: 16),),
                  ),
                  preferredSize: const Size.fromHeight(1),
                ),
                backgroundColor: Theme.of(context).backgroundColor,
              ),
              body: Center(
                child: FutureBuilder(
                    future: _update(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<Course> courses = snapshot.data as List<Course>;
                        return Center(
                          child: ListView.builder(
                              itemCount: courses.length,
                              itemBuilder: (BuildContext context, int index) {
                                return CourseCard(courses[index], context);
                              }),
                        );
                      } else if (snapshot.hasError) {
                        return Text(
                          'Delivery error: ${snapshot.error.toString()}',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    }),
              ),
              backgroundColor: Theme.of(context).backgroundColor,
            );
          } else {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(
              Theme.of(context).colorScheme.primary,
            )));
          }
        });
  }
}

Widget CourseCard(Course course, BuildContext context) {
  return Card(
    elevation: 4.0,
    child: Column(
  children: [
    ListTile(
      title: Text(course.shortCode,
      style: TextStyle(color: Theme.of(context).primaryColor),),
      subtitle: Text(course.name),
      trailing: MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0)
        ),
        onPressed: () {},
        child: const Text('Show all'),
        textColor: Theme.of(context).colorScheme.onSecondary,
        color: Theme.of(context).colorScheme.secondary,
      ),
    ),
    SizedBox(
      height: 200.0,
      child: SaleCarousel(course, context)
    ),
  ],
    ),
  );
}

Widget SaleCarousel(Course course, BuildContext context){
  return FutureBuilder(future: _getSales(course),
  builder: (context, snapshot) {
    if(snapshot.hasData){
      List<Sale> sales = snapshot.data as List<Sale>;
      if (sales.isEmpty){
        return const Center(child: Text("No current literature available.\n"
            "Try pressing the \"Show all\" button"),);
      }else{
        return ListView.builder(scrollDirection: Axis.horizontal,
          itemCount: sales.length,
            itemBuilder: (BuildContext context, int index) => SaleCard(sales[index], context));
        /*return CarouselSlider(
            options: CarouselOptions(enableInfiniteScroll: true),
    items: sales.map((sale) => SaleCard(sale, context)).toList(),
        );*/}

    }else{
      return Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(
                Theme.of(context).colorScheme.primary,
              )));
    }
  });
}

Widget SaleCard(Sale sale, context) {
  return SizedBox( width: 100,child: Card(
      child: FutureBuilder(
        future: BookHandler.getBook(sale.isbn),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Book book = snapshot.data as Book;
            return InkWell(
                onTap: () => _doSomething(),
                child: Column(
                  children: [
                    SizedBox(
                      height: 100,
                      width: 70,
                      child: Ink.image(
                        image: NetworkImage(book.info.imageLinks['smallThumbnail'].toString()),
                        fit: BoxFit.fill,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      alignment: Alignment.centerLeft,
                      child: Text(sale.condition),
                    ),
                  ],
                ));
          } else {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(
                      Theme.of(context).colorScheme.primary,
                    )));
          }
        },
      )),);
}

_doSomething(){
  //Placeholder
}

Future<List<Course>> _update() async {
  return await CourseHandler.updateUserCourses(
      FirebaseAuth.instance.currentUser!.uid, FirebaseFirestore.instance);
}

Future<List<Sale>> _getSales(Course course) async {
  List<Sale> result = [];
  for(String isbn in course.getCurrentIsbns()){
    result.addAll(await SaleHandler.getSalesForISBN(isbn, FirebaseFirestore.instance));
  }
  return result;
}
