class TransactionX {
  int? tid;
  String customerName;
  String customerID;
  String weight;
  String date;

  TransactionX({
    required this.customerName,
    required this.customerID,
    required this.weight,
    required this.date,
  });
  TransactionX.fromMap(Map<String, dynamic> data)
      : customerName = data['customerName'],
        tid = data['tid'] as int,
        customerID = data['customerID'],
        weight = data['weight'],
        date = data['date'];

  Map<String, String> toMap() => {
        'customerName': customerName,
        'customerID': customerID,
        'weight': weight,
        'date': date,
      };
}
