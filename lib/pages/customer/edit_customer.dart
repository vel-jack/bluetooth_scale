import 'package:bluetooth_scale/db/db_helper.dart';
import 'package:bluetooth_scale/model/customer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditCustomer extends StatefulWidget {
  const EditCustomer({Key? key, this.customer}) : super(key: key);
  final Customer? customer;
  @override
  State<EditCustomer> createState() => _EditCustomerState();
}

class _EditCustomerState extends State<EditCustomer> {
  final _formKey = GlobalKey<FormState>();

  final nameC = TextEditingController();
  final phoneC = TextEditingController();
  final aadhaarC = TextEditingController();
  final addressC = TextEditingController();
  final RegExp _number = RegExp(r'^[0-9]{10}$');
  final RegExp _aadhaar = RegExp(r'^[0-9]{12}$');
  final RegExp _name = RegExp(r'^[A-Za-z ]+$');
  final RegExp _address = RegExp(r'^[0-9A-Za-z ,.&/\n]+$');

  List<String> uID = ['', '', ''];
  ValueNotifier<String> custId = ValueNotifier('');
  final DateFormat formatter = DateFormat('dd/MM/yyyy hh:mm aa');
  bool isNew = true;
  DBHelper? dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper ??= DBHelper();
    if (widget.customer != null) {
      fillForm(widget.customer!);
    }
  }

  @override
  void dispose() {
    nameC.dispose();
    phoneC.dispose();
    aadhaarC.dispose();
    addressC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nameC.text.isEmpty ? 'New customer' : nameC.text),
        actions: [
          TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Saving..'),
                    duration: Duration(milliseconds: 500),
                  ));

                  Customer customer = Customer(
                    name: nameC.text,
                    phone: phoneC.text,
                    uid: custId.value,
                    aadhaar: aadhaarC.text,
                    address: addressC.text.trim(),
                  );
                  //   phoneC.text, custId.value, aadhaarC.text, addressC.text
                  if (isNew) {
                    customer.createdAt = getDateTime();
                    await dbHelper!
                        .addCustomer(customer)
                        .then((value) => Navigator.pop(context, customer));
                  } else {
                    customer.createdAt = widget.customer!.createdAt;
                    await dbHelper!
                        .updateCustomer(customer)
                        .then((value) => Navigator.pop(context, customer));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Validation error'),
                    duration: Duration(milliseconds: 500),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              child: Text(isNew ? 'Add' : 'Update')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: nameC,
                  validator: (value) {
                    value = value!.trim();
                    if (value.isEmpty) {
                      return 'Please enter name';
                    } else {
                      if (!_name.hasMatch(value)) {
                        return 'Only alphabets and spaces accepted';
                      }
                    }
                    return null;
                  },
                  onChanged: (value) {
                    value = value.replaceAll(' ', '');
                    uID[0] = value.isNotEmpty
                        ? value.length > 3
                            ? value.substring(0, 4)
                            : value + 'z' * (4 - value.length)
                        : '';
                    updateUniqueID();
                  },
                  maxLength: 20,
                  decoration: const InputDecoration(
                      icon: Icon(Icons.person),
                      labelText: 'Customer Name',
                      border: OutlineInputBorder(),
                      counterText: ''),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: phoneC,
                  maxLength: 10,
                  validator: (value) {
                    if (!_number.hasMatch(value!)) {
                      return 'Please enter valid number';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    uID[1] = value.length > 4
                        ? value.substring(value.length - 4)
                        : value;
                    updateUniqueID();
                  },
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.phone),
                    counterText: '',
                    prefixText: '+91',
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  onChanged: (value) {
                    uID[2] = value.length > 3
                        ? value.substring(value.length - 4)
                        : value;
                    updateUniqueID();
                  },
                  controller: aadhaarC,
                  validator: (value) {
                    if (!_aadhaar.hasMatch(value!)) {
                      return 'Please enter valid Aadhar';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  maxLength: 12,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.branding_watermark),
                    counterText: '',
                    labelText: 'Aadhaar Number',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: addressC,
                  maxLines: null,
                  maxLength: 80,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter address';
                    } else {
                      if (!_address.hasMatch(value)) {
                        return 'Some characters not supported';
                      }
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    icon: Icon(Icons.home),
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.confirmation_num,
                      color: Colors.black45,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ValueListenableBuilder(
                        valueListenable: custId,
                        builder: (BuildContext context, String value,
                            Widget? child) {
                          return Text(
                            'ID : $value',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: value.isEmpty
                                    ? Colors.black45
                                    : value.length == 12
                                        ? Colors.green
                                        : Colors.red),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (!isNew)
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.black45,
                      ),
                      Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            'Joined : ${widget.customer!.createdAt}',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue),
                          )),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void updateUniqueID() {
    if (!isNew) return;
    custId.value = '${uID[0]}${uID[1]}${uID[2]}';
  }

  void fillForm(Customer customer) {
    setState(() {
      isNew = false;
      nameC.text = customer.name;
      phoneC.text = customer.phone;
      aadhaarC.text = customer.aadhaar;
      addressC.text = customer.address;
      custId.value = customer.uid;
    });
  }

  String? getDateTime() {
    DateTime now = DateTime.now();
    return formatter.format(now);
  }
}