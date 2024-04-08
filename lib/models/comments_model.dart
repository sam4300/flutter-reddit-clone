import 'dart:convert';

class Comment {
  final String id;
  final DateTime createdAt;
  final String userName;
  final String profilePic;
  final String postId;
  final String text;
  Comment({
    required this.id,
    required this.createdAt,
    required this.userName,
    required this.profilePic,
    required this.postId,
    required this.text,
  });

  Comment copyWith({
    String? id,
    DateTime? createdAt,
    String? userName,
    String? profilePic,
    String? postId,
    String? text,
  }) {
    return Comment(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      userName: userName ?? this.userName,
      profilePic: profilePic ?? this.profilePic,
      postId: postId ?? this.postId,
      text: text ?? this.text,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'userName': userName,
      'profilePic': profilePic,
      'postId': postId,
      'text': text,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      userName: map['userName'] ?? '',
      profilePic: map['profilePic'] ?? '',
      postId: map['postId'] ?? '',
      text: map['text'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Comment.fromJson(String source) =>
      Comment.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Comment(id: $id, createdAt: $createdAt, userName: $userName, profilePic: $profilePic, postId: $postId, text: $text)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Comment &&
        other.id == id &&
        other.createdAt == createdAt &&
        other.userName == userName &&
        other.profilePic == profilePic &&
        other.postId == postId &&
        other.text == text;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        createdAt.hashCode ^
        userName.hashCode ^
        profilePic.hashCode ^
        postId.hashCode ^
        text.hashCode;
  }
}
