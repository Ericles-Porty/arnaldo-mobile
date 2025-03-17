import 'package:arnaldo/features/relatorio/relatorio_controller.dart';
import 'package:arnaldo/models/pessoa.dart';
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class MensalTab extends StatefulWidget {
  const MensalTab({super.key,required this.pessoa});

  final Pessoa pessoa;

  @override
  State<MensalTab> createState() => _MensalTabState();
}

class _MensalTabState extends State<MensalTab> {

  late RelatorioController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RelatorioController();
  }

  DateTime _dataSelecionada = DateTime.now();

  Future<void> _selecionarMes() async {
    DateTime now = DateTime.now();
    DateTime? mes = await showMonthPicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: now,
      initialDate: _dataSelecionada,
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
    );

    if (mes != null) {
      setState(() {
        _dataSelecionada = mes;
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
                "Mês selecionado:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _selecionarMes,
                child: Text("${_dataSelecionada.month}/${_dataSelecionada.year}"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
