class UserInfo {
  final String id;
  final String name;
  final String avatar;
  final num lastSee;

  const UserInfo({
    required this.id,
    required this.name,
    required this.avatar,
    required this.lastSee,
  });

  static const UserInfo empty =
      UserInfo(id: "", name: "", avatar: "", lastSee: 0);

  UserInfo copyWith({
    String? id,
    String? name,
    String? avatar,
    num? lastSee,
  }) {
    return UserInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      lastSee: lastSee ?? this.lastSee,
    );
  }
}
