class Mood {
  final int? id;
  final int score; // 1: Awful, 2: Bad, 3: Neutral, 4: Good, 5: Amazing
  final String date; // Format: YYYY-MM-DD
  final String? comment;

  Mood({
    this.id,
    required this.score,
    required this.date,
    this.comment,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'score': score,
      'date': date,
      'comment': comment,
    };
    // Only include id for UPDATE — INSERT uses AUTOINCREMENT
    if (id != null) map['id'] = id;
    return map;
  }

  factory Mood.fromMap(Map<String, dynamic> map) {
    return Mood(
      id: map['id'] as int?,
      score: map['score'] as int,
      date: map['date'] as String,
      comment: map['comment'] as String?,
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
