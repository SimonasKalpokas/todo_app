import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/firestore_service.dart';

class ChooseMainCollectionDialog extends StatefulWidget {
  const ChooseMainCollectionDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<ChooseMainCollectionDialog> createState() =>
      _ChooseMainCollectionDialogState();
}

class _ChooseMainCollectionDialogState
    extends State<ChooseMainCollectionDialog> {
  final mainCollectionController = TextEditingController();

  @override
  void dispose() {
    mainCollectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text('Choose main collection'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Main collection'),
          controller: mainCollectionController,
        ),
        actions: [
          TextButton(
              onPressed: () async {
                var res =
                    await Provider.of<FirestoreService>(context, listen: false)
                        .setMainCollection(mainCollectionController.text);

                if (!mounted) {
                  return;
                }
                Navigator.pop(context, res);
              },
              child: const Text('OK')),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
        ]);
  }
}
