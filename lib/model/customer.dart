class Customer {
  String name;
  String phone;
  String aadhaar;
  String uid;
  String? createdAt;
  String address;
  // String? profileUrl;
  Customer({
    required this.name,
    required this.phone,
    required this.uid,
    required this.aadhaar,
    this.createdAt,
    required this.address, // this.profileUrl,
  });
  Customer.fromMap(Map<String, dynamic> data)
      : name = data['name'],
        phone = data['phone'],
        aadhaar = data['aadhaar'],
        uid = data['uid'],
        createdAt = data['createdAt'],
        address = data['address'];
  // profileUrl: data['profileUrl']

  Map<String, dynamic> toMap() => {
        'name': name,
        'phone': phone,
        'aadhaar': aadhaar,
        'uid': uid,
        'createdAt': createdAt,
        'address': address,
      };
  @override
  String toString() {
    return 'Customer : $name { Aadhaar = $aadhaar, Adress = $address }';
  }
}
