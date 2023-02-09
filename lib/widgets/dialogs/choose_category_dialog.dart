import 'package:flutter/material.dart';
import 'package:todo_app/constants.dart';

import '../../models/category.dart';
import 'category_create_dialog.dart';

class ChooseCategoryDialog extends StatefulWidget {
  final Category? category;
  final Iterable<Category> categories;

  const ChooseCategoryDialog(
      {super.key, required this.category, required this.categories});

  @override
  State<ChooseCategoryDialog> createState() => _ChooseCategoryDialogState();
}

class _ChooseCategoryDialogState extends State<ChooseCategoryDialog> {
  Category? category;
  @override
  void initState() {
    category = widget.category;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.only(top: 10),
      backgroundColor: backgroundColor,
      title: const Text(
        'Select a category',
        style: TextStyle(fontSize: 24, color: primaryColor),
      ),
      content: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: widget.categories
                .map((category) => ListTile(
                      minVerticalPadding: 0,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
                      minLeadingWidth: 10,
                      horizontalTitleGap: 15,
                      title: Text(category.name,
                          style: const TextStyle(fontSize: 14, color: white1)),
                      leading: SizedBox(
                        height: double.infinity,
                        child: CircleAvatar(
                          backgroundColor: Color(category.colorValue),
                          maxRadius: 7.5,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          this.category = category;
                          Navigator.pop(context, category);
                        });
                      },
                      trailing: this.category == category
                          ? const Icon(Icons.check, color: white2)
                          : null,
                    ))
                .followedBy([
              ListTile(
                minVerticalPadding: 0,
                contentPadding: const EdgeInsets.symmetric(horizontal: 13),
                minLeadingWidth: 10,
                horizontalTitleGap: 13,
                title: Text('Add new..',
                    style: TextStyle(
                        fontSize: 14, color: white1.withOpacity(0.75))),
                leading:
                    Icon(Icons.add, size: 15, color: white1.withOpacity(0.75)),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => const CategoryCreateDialog(),
                  ).then((value) {
                    if (value != null) {
                      Navigator.pop(context, value);
                    }
                  });
                },
              ),
            ]),
          ).toList(),
        ),
      ),
      actionsAlignment: MainAxisAlignment.start,
      actions: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20, left: 40),
          child: TextButton(
              child: const Text("Cancel",
                  style: TextStyle(color: primaryColorLight, fontSize: 20)),
              onPressed: () {
                Navigator.pop(context, category);
              }),
        ),
      ],
    );
  }
}
