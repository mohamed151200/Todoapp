class TaskModel {
  String id;             // للموبايل (Sqflite Auto-increment)
  String userId;  // للمزامنة (Firebase Document ID)
  String title;
  String date;         // تاريخ المهمة (مثلاً: 2026-03-22)
  int timestamp;       // وقت الإنشاء/التعديل (بالميللي ثانية) للمزامنة
  int status; 
  int isDeleted;         // 0: لم تبدأ، 1: اكتملت

  TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.date,
    required this.timestamp,
    this.status = 0,
    this.isDeleted=0
  });

  // من JSON (سواء من السيكولايت أو الفايربيز) لـ Object
  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'],
        userId: json['userId']??'',
        title: json['title'],
        date: json['date'],
        timestamp: json['timestamp'],
        status: json['status'],
        isDeleted:json['isDeleted']??0

      );

  // من Object لـ Map (عشان التخزين)
  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'date': date,
        'timestamp': timestamp,
        'status': status,
        'isDeleted': isDeleted
      };
}