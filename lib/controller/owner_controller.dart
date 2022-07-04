import 'dart:developer';
import 'dart:io';

import 'package:bluetooth_scale/utils/constants.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class OwnerController extends GetxController {
  static OwnerController instance = Get.find();
  SharedPreferences? prefs;
  Rx<Owner> owner = Rx<Owner>(Owner());
  Rx<File?> profileImage = Rx<File?>(null);

  @override
  void onInit() {
    loadFromPrefernces();
    super.onInit();
  }

  void loadFromPrefernces() async {
    prefs = await SharedPreferences.getInstance();
    owner.value.name = prefs!.getString('name') ?? kAppName;
    owner.value.email = prefs!.getString('email') ?? kBiozEmail;
    owner.value.phone = prefs!.getString('phone') ?? '';
    owner.value.name = prefs!.getString('business') ?? kCompanyName;
    final image = prefs!.getString('imagePath') ?? "";
    if (image.isNotEmpty) {
      profileImage.value = File(image);
    }
  }

  void updateProfile(Owner _owner) async {
    prefs ??= await SharedPreferences.getInstance();
    owner.value = _owner;
    prefs!.setString('name', _owner.name);
    prefs!.setString('email', _owner.email);
    prefs!.setString('phone', _owner.phone);
    prefs!.setString('business', _owner.business);
  }

  void updateImage(XFile xImage) async {
    prefs ??= await SharedPreferences.getInstance();
    profileImage.value = File(xImage.path);
    Directory appDocDir = await getApplicationDocumentsDirectory();
    final pathx = path.basename(xImage.path);
    final copyPath = path.join(appDocDir.path, pathx);
    await profileImage.value!.copy(copyPath);

    var oldPath = prefs!.getString('imagePath') ?? '';
    try {
      if (await File(oldPath).exists()) {
        await File(oldPath).delete();
      }
      log('${path.basename(oldPath)} Old Pic deleted', name: 'UpdateImage');
    } on Exception catch (e) {
      log('Can\'t Delete...\n$e', name: 'UpdateImage');
    }
    prefs!.setString('imagePath', copyPath);
    log('${path.basename(copyPath)} New Pic added', name: 'UpdateImage');
  }
}

class Owner {
  Owner({
    this.name = kAppName,
    this.email = kBiozEmail,
    this.phone = '',
    this.business = kCompanyName,
  });
  String name;
  String email;
  String phone;
  String business;
}
