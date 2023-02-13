import '../../../core/shared_models/user.dart';

class Review {
  late int id;
  late int rating;
  late String subject;
  late String? comment;
  late DateTime createdAt;
  late DateTime updatedAt;
  late Relationships relationships;

  Review.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    rating = json['rating'];
    subject = json['subject'];
    comment = json['comment'];
    createdAt = DateTime.parse(json['createdAt']);
    updatedAt = DateTime.parse(json['updatedAt']);
    relationships = Relationships.fromJson(json['relationships'].runtimeType == List ? {} : json['relationships']);
  }
}

class Relationships {
  late User user;

  Relationships.fromJson(Map<String, dynamic> json) {
    user = User.fromJson(json['user']);
  }
}