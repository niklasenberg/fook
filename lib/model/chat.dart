import 'package:fook/model/message.dart';

class Chat {
  final List<String> members;
  final List<Message> messages;

  const Chat({
    required this.members,
    required this.messages,
  });

  static Chat fromJson(Map<String, dynamic> json) => Chat(
        members: json['members'],
        messages: json['messages'],
      );

  Map<String, dynamic> toJson() => {
        'members': members,
        'messages': messages,
      };
}
