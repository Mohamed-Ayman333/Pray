class UserState {
  final int optionalPrayerCounter;

  const UserState({required this.optionalPrayerCounter});

  Map<String, dynamic> toJson() {
    return {'optionalPrayerCounter': optionalPrayerCounter};
  }

  factory UserState.fromJson(Map<String, dynamic> json) {
    return UserState(
      optionalPrayerCounter: (json['optionalPrayerCounter'] as int?) ?? 0,
    );
  }

  UserState copyWith({int? optionalPrayerCounter}) {
    return UserState(
      optionalPrayerCounter:
          optionalPrayerCounter ?? this.optionalPrayerCounter,
    );
  }

  UserState incrementOptionalPrayerCounter({int step = 1}) {
    return copyWith(optionalPrayerCounter: optionalPrayerCounter + step);
  }

  UserState decrementOptionalPrayerCounter({int step = 1}) {
    final newCount = (optionalPrayerCounter - step)
        .clamp(0, double.infinity)
        .toInt();
    return copyWith(optionalPrayerCounter: newCount);
  }
}
