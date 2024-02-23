import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/widgets/form_label.dart';

import '../../providers/color_provider.dart';
import '../../services/firestore_service.dart';

class ChooseMainCollectionDialog extends StatefulWidget {
  const ChooseMainCollectionDialog({
    super.key,
  });

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
    final colorProvider = Provider.of<ColorProvider>(context);
    final appColors = colorProvider.appColors;
    return AlertDialog(
        title: const Text('Choose main collection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: TextStyle(color: appColors.secondaryColor),
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Main collection'),
              controller: mainCollectionController,
            ),
            const FormLabel(text: "Dark mode"),
            Switch(
              value: colorProvider.theme == 'dark',
              onChanged: (value) async {
                await Provider.of<ColorProvider>(context, listen: false)
                    .setAppColors(value ? 'dark' : 'light');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () async {
                var res =
                    await Provider.of<FirestoreService>(context, listen: false)
                        .setMainCollection(mainCollectionController.text);

                if (!context.mounted) {
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
