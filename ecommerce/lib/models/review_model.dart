import 'Model.dart';

class Review extends Model {
  static const String REVIEWER_UID_KEY = "reviewer_uid";
  static const String RATING_KEY = "rating";
  static const String FEEDBACK_KEY = "review";

  String reviewerUid;
  int rating;
  String feedback;
  Review(
    String id, {
    this.reviewerUid = '',
    this.rating = 3,
    this.feedback = '',
  }) : super(id);

  factory Review.fromMap(Map<String, dynamic> map, {String? id}) {
    return Review(
      id ?? '',
      reviewerUid: map[REVIEWER_UID_KEY],
      rating: map[RATING_KEY],
      feedback: map[FEEDBACK_KEY],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      REVIEWER_UID_KEY: reviewerUid,
      RATING_KEY: rating,
      FEEDBACK_KEY: feedback,
    };
    return map;
  }

  @override
  Map<String, dynamic> toUpdateMap() {
    final map = <String, dynamic>{};
    if (reviewerUid != null) map[REVIEWER_UID_KEY] = reviewerUid;
    if (rating != null) map[RATING_KEY] = rating;
    if (feedback != null) map[FEEDBACK_KEY] = feedback;
    return map;
  }
}

class ReviewModel {
  String? _reviewId;
  String? _reviewerUid;
  int? _rating;
  String? _feedback;

  ReviewModel();

  ReviewModel.fromJson(Map<String, dynamic> json) {
    _reviewId = json['review_id'];
    _reviewerUid = json['reviewer_uid'];
    _rating = json['rating'];
    _feedback = json['review'];
  }

  String get id => _reviewId ?? "";
  String get reviewerUid => _reviewerUid ?? "";
  int get rating => _rating ?? 0;
  String get feedback => _feedback ?? "";
}
