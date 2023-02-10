import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';
import '../../providers/color_provider.dart';
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
    final appColors = Provider.of<ColorProvider>(context).appColors;
    return AlertDialog(
      contentPadding: const EdgeInsets.only(top: 10),
      backgroundColor: appColors.backgroundColor,
      title: Text(
        'Select a category',
        style: TextStyle(fontSize: 24, color: appColors.primaryColor),
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
                          style: TextStyle(
                              fontSize: 14, color: appColors.secondaryColor)),
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
                          ? Icon(Icons.check, color: appColors.borderColor)
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
                        fontSize: 14,
                        color: appColors.secondaryColor.withOpacity(0.75))),
                leading: Icon(Icons.add,
                    size: 15,
                    color: appColors.secondaryColor.withOpacity(0.75)),
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
              child: Text("Cancel",
                  style: TextStyle(
                      color: appColors.primaryColorLight, fontSize: 20)),
              onPressed: () {
                Navigator.pop(context, category);
              }),
        ),
      ],
    );
  }
}
