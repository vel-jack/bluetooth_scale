import 'dart:io';

import 'package:bluetooth_scale/utils/blue_singleton.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

import '../select_device.dart';

class EditPofile extends StatefulWidget {
  const EditPofile({Key? key, this.fromSplash}) : super(key: key);
  final bool? fromSplash;
  @override
  State<EditPofile> createState() => _EditPofileState();
}

class _EditPofileState extends State<EditPofile> {
  final _formKey = GlobalKey<FormState>();

  final RegExp _number = RegExp(r'^[0-9]{10}$');
  final RegExp _email = RegExp(
      r"^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$");

  final nameC = TextEditingController();
  final phoneC = TextEditingController();
  final emailC = TextEditingController();
  final businessC = TextEditingController();

  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  XFile? xImage;
  final _imgPicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    prefs.then((pref) {
      nameC.text = pref.getString('name') ?? '';
      phoneC.text = pref.getString('number') ?? '';
      emailC.text = pref.getString('email') ?? '';
      businessC.text = pref.getString('business') ?? '';
    });
  }

  @override
  void dispose() {
    nameC.dispose();
    phoneC.dispose();
    emailC.dispose();
    businessC.dispose();
    super.dispose();
  }

  void takePhoto(ImageSource _source) async {
    await _imgPicker.pickImage(source: _source).then((value) {
      setState(() {
        xImage = value;
        Singleton().profileImage = File(xImage!.path);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        actions: [
          IconButton(
              tooltip: 'Save',
              onPressed: () async {
                if (xImage != null) {
                  Directory appDocDir =
                      await getApplicationDocumentsDirectory();

                  final pathx = path.basename(xImage!.path);
                  final copyPath = path.join(appDocDir.path, pathx);
                  await Singleton().profileImage!.copy(copyPath);
                  prefs.then((value) async {
                    var oldPath = value.getString('imgPath') ?? '';
                    try {
                      if (await File(oldPath).exists()) {
                        await File(oldPath).delete();
                      }
                      debugPrint('${path.basename(oldPath)} Old Pic deleted');
                    } on Exception catch (e) {
                      debugPrint('Can\'t Delete...\n$e');
                    }
                    value.setString('imgPath', copyPath);
                    debugPrint('${path.basename(copyPath)} New Pic added');
                  });
                  xImage = null;
                }

                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Saving..'),
                    backgroundColor: Colors.green,
                    duration: Duration(milliseconds: 800),
                  ));
                  Singleton().name = nameC.text;
                  Singleton().phone = phoneC.text;
                  Singleton().email = emailC.text;
                  Singleton().business = businessC.text;
                  prefs.then((pref) {
                    pref.setString('name', nameC.text);
                    pref.setString('number', phoneC.text);
                    pref.setString('email', emailC.text);
                    pref.setString('business', businessC.text);
                  }).then((value) {
                    if (widget.fromSplash != null) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SelectDevice()));
                    } else {
                      Navigator.pop(context);
                    }
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Please check your details'),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              icon: const Icon(Icons.done))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.grey.shade100,
                      backgroundImage: Singleton().profileImage == null
                          ? const AssetImage('assets/bioz.png')
                          : FileImage(Singleton().profileImage!)
                              as ImageProvider,
                    ),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 20,
                          child: IconButton(
                              onPressed: () {
                                showModalBottomSheet(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    context: context,
                                    builder: (builder) {
                                      return bottomSheet();
                                    });
                              },
                              icon: const Icon(
                                Icons.camera_alt,
                              )),
                        ))
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: nameC,
                    maxLength: 20,
                    validator: (value) {
                      value = value!.trim();
                      if (value.isEmpty) {
                        return 'Please enter name';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        labelText: 'Name',
                        counterText: '',
                        border: OutlineInputBorder(),
                        hintText: 'Your Name'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: phoneC,
                    maxLength: 10,
                    validator: (value) {
                      if (!_number.hasMatch(value!)) {
                        return 'Please enter valid number';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.phone),
                        prefixText: '+91',
                        border: OutlineInputBorder(),
                        labelText: 'Phone',
                        counterText: '',
                        hintText: 'XXXXXXXXXX'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: emailC,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (!_email.hasMatch(value!)) {
                        return 'Please enter valid email';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                        icon: Icon(Icons.mail),
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        hintText: 'user@email.com'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    maxLength: 20,
                    controller: businessC,
                    validator: (value) {
                      if (value!.isEmpty) return 'Please type company name';
                      return null;
                    },
                    decoration: const InputDecoration(
                        icon: Icon(Icons.store),
                        labelText: 'Company',
                        counterText: '',
                        border: OutlineInputBorder(),
                        hintText: 'abc company'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 180,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Choose profile photo',
                    style: TextStyle(fontSize: 18)),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'))
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt, size: 30),
            title: const Text('Take a Photo'),
            onTap: () {
              takePhoto(ImageSource.camera);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.image, size: 30),
            title: const Text('Choose from gallery'),
            onTap: () {
              takePhoto(ImageSource.gallery);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
