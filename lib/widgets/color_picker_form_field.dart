import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/color_provider.dart';
import 'not_implemented_alert.dart';

const pickerColors = [
  Colors.blue,
  Colors.red,
  Colors.green,
  Colors.yellow,
  Colors.purple,
  Colors.orange,
  Colors.cyan,
  Colors.lime,
];

class ColorPickerFormField extends FormField<Color> {
  ColorPickerFormField({
    super.key,
    super.onSaved,
    super.validator,
    super.initialValue,
    bool autovalidate = false,
  }) : super(
            autovalidateMode: autovalidate
                ? AutovalidateMode.always
                : AutovalidateMode.disabled,
            builder: (FormFieldState<Color> field) {
              final state = field as _ColorPickerFormFieldState;
              final appColors =
                  Provider.of<ColorProvider>(state.context).appColors;
              return InputDecorator(
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)),
                  fillColor: Colors.transparent,
                  errorText: state.errorText,
                ),
                child: Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: pickerColors
                            .map((color) => Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: GestureDetector(
                                    onTap: () {
                                      state.didChange(color);
                                    },
                                    child: Container(
                                      height: 26,
                                      width: 26,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: color,
                                        border: Border.all(
                                            color: appColors.borderColor,
                                            width: 0.5,
                                            style: BorderStyle.solid),
                                      ),
                                      child: state.value == color
                                          ? Icon(
                                              Icons.check,
                                              size: 15,
                                              color: appColors.backgroundColor,
                                            )
                                          : null,
                                    ),
                                  ),
                                ))
                            .toList()),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: const BorderSide(
                                    color: Colors.black, width: 0.25))),
                        onPressed: () {
                          notImplementedAlert(state.context);
                        },
                        icon: const Icon(Icons.palette),
                        label: const Text('Custom color',
                            style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              );
            });

  @override
  FormFieldState<Color> createState() => _ColorPickerFormFieldState();
}

class _ColorPickerFormFieldState extends FormFieldState<Color> {
  @override
  ColorPickerFormField get widget => super.widget as ColorPickerFormField;

  @override
  void didChange(Color? value) {
    super.didChange(value);
    setState(() {});
  }
}
