class TaskModel {
  String id;            
  String userId;  
  String title;
  String date;         
  int timestamp;       
  int status; 
  int isDeleted;         

  TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.date,
    required this.timestamp,
    this.status = 0,
    this.isDeleted=0
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'],
        userId: json['userId']??'',
        title: json['title'],
        date: json['date'],
        timestamp: json['timestamp'],
        status: json['status'],
        isDeleted:json['isDeleted']??0

      );

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