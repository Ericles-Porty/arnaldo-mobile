import 'package:flutter/material.dart';

class PeriodoTab extends StatefulWidget {
  const PeriodoTab({super.key});

  @override
  State<PeriodoTab> createState() => _PeriodoTabState();
}

class _PeriodoTabState extends State<PeriodoTab> {
  DateTime _dataInicial = DateTime.now().subtract(const Duration(days: 7));
  DateTime _dataFinal = DateTime.now();

  Future<void> _selecionarPeriodo() async {
    DateTime now = DateTime.now();
    DateTime dataInicio = now.subtract(Duration(days: now.weekday));
    DateTime dataFim = now.add(Duration(days: DateTime.daysPerWeek - now.weekday - 1));

    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: dataFim,
      initialDateRange: DateTimeRange(start: dataInicio, end: dataFim),
    );

    if (picked != null) {
      setState(() {
        _dataInicial = picked.start;
        _dataFinal = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Período selecionado:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _selecionarPeriodo,
          child: Text("${_dataInicial.day}/${_dataInicial.month} - ${_dataFinal.day}/${_dataFinal.month}"),
        ),
      ],
    );
  }
}
