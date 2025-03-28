import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kitapapp/main.dart';
import 'package:kitapapp/models/actions.dart';

class TimePickerDialog extends StatefulWidget {
  final void Function(int, int) onSave;

  /// Constructor
  const TimePickerDialog({
    required this.onSave,
    Key? key,
  }) : super(key: key);

  @override
  State<TimePickerDialog> createState() => _TimePickerDialogState();
}

class _TimePickerDialogState extends State<TimePickerDialog> {
  int selectedHour = 8;
  int selectedMinute = 0;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = store.state.apiModel.theme ?? false;

    // Tema renkleri
    final backgroundColor = isDarkMode ? Colors.grey.shade900 : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final primaryColor = isDarkMode ? Colors.blue.shade300 : Colors.blue;
    final secondaryColor = isDarkMode ? Colors.amber.shade300 : Colors.amber.shade700;
    final dropdownColor = isDarkMode ? Colors.grey.shade800 : Colors.white;
    final dropdownBorderColor = isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300;

    return MaterialApp(
      locale: Locale(store.state.apiModel.language!),
      supportedLocales: [
        Locale('en'), // İngilizce
        Locale('tr'), // Türkçe
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return AlertDialog(
          title: Text(
            "${AppLocalizations.of(context)?.bildirim}",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: backgroundColor,
          content: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${AppLocalizations.of(context)?.saat}",
                        style: TextStyle(color: textColor),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: dropdownBorderColor, width: 1.0),
                          color: dropdownColor,
                        ),
                        child: DropdownButton<int>(
                          value: selectedHour,
                          underline: Container(),
                          dropdownColor: dropdownColor,
                          icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                          items: List.generate(24, (index) => index)
                              .map((hour) => DropdownMenuItem(
                                    value: hour,
                                    child: Text(
                                      hour.toString().padLeft(2, '0'),
                                      style: TextStyle(color: textColor),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedHour = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${AppLocalizations.of(context)?.dakika}",
                        style: TextStyle(color: textColor),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: dropdownBorderColor, width: 1.0),
                          color: dropdownColor,
                        ),
                        child: DropdownButton<int>(
                          value: selectedMinute,
                          underline: Container(),
                          dropdownColor: dropdownColor,
                          icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                          items: List.generate(60, (index) => index)
                              .map((minute) => DropdownMenuItem(
                                    value: minute,
                                    child: Text(
                                      minute.toString().padLeft(2, '0'),
                                      style: TextStyle(color: textColor),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedMinute = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: secondaryColor,
              ),
              child: Text("${AppLocalizations.of(context)?.no}"),
            ),
            ElevatedButton(
              onPressed: () {
                widget.onSave(selectedHour, selectedMinute);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: isDarkMode ? Colors.black : Colors.white,
              ),
              child: Text("${AppLocalizations.of(context)?.yes}"),
            ),
          ],
        );
      },
    );
  }
}
