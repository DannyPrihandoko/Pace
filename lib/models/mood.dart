class Mood {
  final int? id;
  final int score; // 1: Awful, 2: Bad, 3: Neutral, 4: Good, 5: Amazing
  final String date;
  final String? comment;

  Mood({
    this.id,
    required this.score,
    required this.date,
    this.comment,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'score': score,
      'date': date,
      'comment': comment,
    };
  }

  factory Mood.fromMap(Map<String, dynamic> map) {
    return Mood(
      id: map['id'],
      score: map['score'],
      date: map['date'],
      comment: map['comment'],
    );
  }

  Mood copyWith({
    int? id,
    int? score,
    String? date,
    String? comment,
  }) {
    return Mood(
      id: id ?? this.id,
      score: score ?? this.score,
      date: date ?? this.date,
      comment: comment ?? this.comment,
    );
  }
}
