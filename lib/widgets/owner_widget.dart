import 'package:bluetooth_scale/pages/owner/edit_profile.dart';
import 'package:bluetooth_scale/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OwnerHeaderWidget extends StatelessWidget {
  const OwnerHeaderWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return UserAccountsDrawerHeader(
        accountName: Text(ownerController.owner.value.name),
        accountEmail: Text(ownerController.owner.value.email),
        currentAccountPicture: Hero(
          tag: 'owner_image',
          child: CircleAvatar(
            radius: 70,
            backgroundColor: Colors.grey.shade100,
            backgroundImage: ownerController.profileImage.value == null
                ? const AssetImage('assets/bioz.png')
                : FileImage(ownerController.profileImage.value!)
                    as ImageProvider,
          ),
        ),
        otherAccountsPictures: [
          IconButton(
              onPressed: () {
                Get.to(() => const EditPofile());
              },
              color: Colors.white,
              icon: const Icon(Icons.edit))
        ],
      );
    });
  }
}
