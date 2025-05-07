import 'package:arnaldo/core/enums/pessoa_type.dart';
import 'package:arnaldo/features/relatorio/relatorio_controller.dart';
import 'package:arnaldo/widgets/my_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class RelatorioPage extends StatefulWidget {
  const RelatorioPage({super.key});

  @override
  State<RelatorioPage> createState() => _RelatorioPageState();
}

class _RelatorioPageState extends State<RelatorioPage> {
  late RelatorioController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RelatorioController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(
        context: context,
        title: 'Relatório',
        hasLeading: true,
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  ElevatedButton(
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Clientes',
                        style: TextStyle(fontSize: 40),
                      ),
                    ),
                    onPressed: () {
                      Modular.to.pushNamed(
                        '/relatorio/pessoas',
                        arguments: PessoaType.cliente,
                      );
                    },
                  ),
                  const SizedBox(width: 24),
                  ElevatedButton(
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Fornecedores',
                        style: TextStyle(fontSize: 40),
                      ),
                    ),
                    onPressed: () {
                      Modular.to.pushNamed(
                        '/relatorio/pessoas',
                        arguments: PessoaType.fornecedor,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
