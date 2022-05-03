import 'package:fook/model/course.dart';
import 'package:fook/model/user.dart';

class Sale {
  final User user;
  final Course course;
  final int price;
  final int condition;

  Sale({
    required this.user,
    required this.course,
    required this.price,
    required this.condition,
  });
}
