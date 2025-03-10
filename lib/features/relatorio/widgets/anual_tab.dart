import 'package:flutter/material.dart';

class AnualTab extends StatefulWidget {
  const AnualTab({super.key});

  @override
  State<AnualTab> createState() => _AnualTabState();
}

class _AnualTabState extends State<AnualTab> {
  int _anoSelecionado = DateTime.now().year;

  Future<void> _selecionarAno() async {
    int? pickedAno = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Selecione o Ano"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 10, // Mostra os últimos 10 anos
              itemBuilder: (BuildContext context, int index) {
                int ano = DateTime.now().year - index;
                return ListTile(
                  title: Text("$ano"),
                  onTap: () => Navigator.pop(context, ano),
                );
              },
            ),
          ),
        );
      },
    );

    if (pickedAno != null) {
      setState(() {
        _anoSelecionado = pickedAno;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }
}
