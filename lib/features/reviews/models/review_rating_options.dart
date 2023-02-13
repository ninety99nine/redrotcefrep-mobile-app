class ReviewRatingOptions {
  late List<String> ratingSubjects;
  late List<RatingOption> ratingOptions;

  ReviewRatingOptions.fromJson(Map<String, dynamic> json) {
    ratingSubjects = List<String>.from(json['ratingSubjects']);
    ratingOptions = (json['ratingOptions'] as List).map((ratingOption) => RatingOption.fromJson(ratingOption)).toList();
  }
}

class RatingOption {
  late String name;
  late int rating;

  RatingOption.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    rating = json['rating'];
  }
}