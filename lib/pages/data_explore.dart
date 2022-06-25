import 'package:flutter/material.dart';

class DataExplore extends StatefulWidget {
  const DataExplore({Key? key}) : super(key: key);

  @override
  State<DataExplore> createState() => _DataExploreState();
}

class _DataExploreState extends State<DataExplore> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import/Export')),
      body: ListView(children: [
        ListTile(
          onTap: () {},
          title: const Text('Export to PDF'),
          leading: const Icon(Icons.picture_as_pdf),
        ),
        ListTile(
          onTap: () {},
          title: const Text('Export Data'),
          leading: const Icon(Icons.file_upload),
        ),
        ListTile(
            onTap: () {},
            title: const Text('Import Data'),
            leading: const Icon(Icons.download),
            subtitle: const Text('The old data will be lost'),
            trailing: const Tooltip(
              triggerMode: TooltipTriggerMode.tap,
              message: 'Critical Action',
              child: Icon(
                Icons.info,
                color: Colors.red,
              ),
            )),
      ]),
    );
  }
}
