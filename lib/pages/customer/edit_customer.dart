import 'package:bluetooth_scale/model/customer.dart';
import 'package:bluetooth_scale/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
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

  List<String> uID = ['', '', ''];
  ValueNotifier<String> custId = ValueNotifier('');
  final DateFormat formatter = DateFormat('dd/MM/yyyy hh:mm aa');
  bool isNew = true;

  @override
  void initState() {
    super.initState();
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
                  Get.snackbar(
                    'Saving..',
                    'Customer profile saved successfully ',
                    leftBarIndicatorColor: Colors.green,
                    duration: const Duration(seconds: 1),
                    animationDuration: const Duration(milliseconds: 500),
                  );
                  Customer customer = Customer(
                    name: nameC.text,
                    phone: phoneC.text,
                    uid: custId.value,
                    aadhaar: aadhaarC.text,
                    address: addressC.text.trim(),
                  );
                  // Todo pop added message
                  if (isNew) {
                    customer.createdAt = getDateTime();
                    customerController.addCutomer(customer);
                    Navigator.pop(context, customer);
                  } else {
                    customer.createdAt = widget.customer!.createdAt;
                    customerController.updateCustomer(customer);
                    Navigator.pop(context, customer);
                  }
                } else {
                  Get.snackbar(
                    'Validation error',
                    'Please provide valid informations',
                    leftBarIndicatorColor: Colors.red,
                    duration: const Duration(seconds: 1),
                    animationDuration: const Duration(milliseconds: 500),
                  );
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
                      if (!regExForName.hasMatch(value)) {
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
                    if (!regExForPhone.hasMatch(value!)) {
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
                    if (!regExForAadhaar.hasMatch(value!)) {
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
                      if (!regExForAddress.hasMatch(value)) {
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
