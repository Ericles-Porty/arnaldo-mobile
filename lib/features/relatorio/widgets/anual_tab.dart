import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class AnualTab extends StatefulWidget {
  const AnualTab({super.key});

  @override
  State<AnualTab> createState() => _AnualTabState();
}

class _AnualTabState extends State<AnualTab> {
  int _anoSelecionado = DateTime.now().year;

  Future<void> _selecionarAno() async {
    DateTime now = DateTime.now();

    int? ano = await showYearPicker(
      monthPickerDialogSettings: const MonthPickerDialogSettings(
        actionBarSettings: PickerActionBarSettings(
          confirmWidget: Padding(
            padding: EdgeInsets.all(10.0),
            child: Text("Selecionar"),
          ),
          cancelWidget: Padding(
            padding: EdgeInsets.all(10.0),
            child: Text("Cancelar"),
          ),
          buttonSpacing: 20,
        ),
      ),
      context: context,
      firstDate: DateTime(2023),
      lastDate: now,
      initialDate: DateTime(_anoSelecionado),
    );

    if (ano != null) {
      setState(() {
        _anoSelecionado = ano;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 5,
            children: [
              const Text(
                "Ano selecionado:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _selecionarAno,
                child: Text("$_anoSelecionado"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
