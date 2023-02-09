import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/constants.dart';

import '../../models/category.dart';
import '../../services/firestore_service.dart';
import '../color_picker_form_field.dart';
import '../form_label.dart';

class CategoryCreateDialog extends StatefulWidget {
  const CategoryCreateDialog({super.key});

  @override
  State<CategoryCreateDialog> createState() => _CategoryCreateDialogState();
}

class _CategoryCreateDialogState extends State<CategoryCreateDialog> {
  final TextEditingController nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Color? color;

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    return AlertDialog(
      backgroundColor: backgroundColor,
      title: const Text(
        'New category',
        style: TextStyle(fontSize: 24, color: primaryColor),
      ),
      content: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FormLabel(text: 'Name'),
              TextFormField(
                style: const TextStyle(color: white1),
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const FormLabel(text: 'Color'),
              const SizedBox(height: 10),
              ColorPickerFormField(
                onSaved: (value) {
                  color = value;
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a color';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 0, 6.0, 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColorLight,
                      minimumSize: const Size.fromHeight(43)),
                  child: const Text(
                    "Save",
                    style: TextStyle(
                        color: buttonColor,
                        fontSize: 20,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final category =
                          Category(color!.value, nameController.text);
                      await firestoreService.addCategory(category);
                      if (mounted) {
                        Navigator.pop(context, category);
                      }
                    }
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6.0, 0, 12.0, 8.0),
                child: TextButton(
                    style: TextButton.styleFrom(
                        minimumSize: const Size.fromHeight(43)),
                    child: const Text("Cancel",
                        style:
                            TextStyle(color: primaryColorLight, fontSize: 20)),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ),
            ),
          ],
        )
      ],
    );
  }
}
