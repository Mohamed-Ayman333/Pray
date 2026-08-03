class Prayer {
  final String name;
  final DateTime time;
  final bool isDone;

  Prayer({required this.name, required this.time, required this.isDone,});

  Map<String, dynamic> toJson() {
    return {
      'name':name,
      'time':time.toIso8601String(),
      'isDone':isDone,
    };
  }

  factory Prayer.fromJson(Map<String, dynamic> json){
    return Prayer(name:json['name'] as String,
        time: DateTime.parse(json['time'] as String),
        isDone:json['isDone'] as bool);
  }

  Prayer copyWith({String? name, DateTime? time, bool? isDone}){
    return Prayer(name: name??this.name
        , time: time?? this.time
        , isDone: isDone?? this.isDone);
  }

}