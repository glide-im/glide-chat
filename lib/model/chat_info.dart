class ChatInfo {
  final String id;
  final String name;
  final String avatar;
  final num lastSee;

  const ChatInfo({
    required this.id,
    required this.name,
    required this.avatar,
    required this.lastSee,
  });

  static const ChatInfo empty =
      ChatInfo(id: "", name: "", avatar: "", lastSee: 0);

  ChatInfo copyWith({
    String? id,
    String? name,
    String? avatar,
    num? lastSee,
  }) {
    return ChatInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      lastSee: lastSee ?? this.lastSee,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'lastSee': lastSee,
    };
  }

  factory ChatInfo.fromMap(Map<String, dynamic> map) {
    return ChatInfo(
      id: map['id'] as String,
      name: map['name'] as String,
      avatar: map['avatar'] as String,
      lastSee: map['lastSee'] as num,
    );
  }
}
