import 'package:flutter/material.dart';

class MensalTab extends StatefulWidget {
  const MensalTab({super.key});

  @override
  State<MensalTab> createState() => _MensalTabState();
}

class _MensalTabState extends State<MensalTab> {
  DateTime _dataSelecionada = DateTime.now();

  Future<void> _selecionarMes() async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2023),
      lastDate: now,
      locale: const Locale("pt", "BR"),
      // Configura para o Brasil (opcional)
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            primaryColor: Colors.blue,
            colorScheme: ColorScheme.light(primary: Colors.blue),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dataSelecionada = DateTime(picked.year, picked.month);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }
}
