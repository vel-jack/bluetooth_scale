import 'package:bluetooth_scale/controller/owner_controller.dart';
import 'package:bluetooth_scale/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditPofile extends StatefulWidget {
  const EditPofile({Key? key, this.fromSplash}) : super(key: key);
  final bool? fromSplash;
  @override
  State<EditPofile> createState() => _EditPofileState();
}

class _EditPofileState extends State<EditPofile> {
  final _formKey = GlobalKey<FormState>();

  final nameC = TextEditingController();
  final phoneC = TextEditingController();
  final emailC = TextEditingController();
  final businessC = TextEditingController();
  final _imgPicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameC.text = ownerController.owner.value.name;
    phoneC.text = ownerController.owner.value.phone;
    emailC.text = ownerController.owner.value.email;
    businessC.text = ownerController.owner.value.business;
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
    await _imgPicker.pickImage(source: _source).then((xfile) {
      if (xfile != null) {
        ownerController.updateImage(xfile);
      }
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
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Saving..'),
                    backgroundColor: Colors.green,
                    duration: Duration(milliseconds: 800),
                  ));

                  ownerController.updateProfile(Owner(
                      name: nameC.text,
                      phone: phoneC.text,
                      email: emailC.text,
                      business: businessC.text));
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
                    Obx(() {
                      return CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.grey.shade100,
                        backgroundImage:
                            ownerController.profileImage.value == null
                                ? const AssetImage('assets/bioz.png')
                                : FileImage(ownerController.profileImage.value!)
                                    as ImageProvider,
                      );
                    }),
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
                      if (!regExForPhone.hasMatch(value!)) {
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
                      if (!regExForEmail.hasMatch(value!)) {
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
