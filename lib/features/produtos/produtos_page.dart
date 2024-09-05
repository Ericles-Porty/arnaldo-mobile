import 'package:arnaldo/features/produtos/produtos_controller.dart';
import 'package:arnaldo/widgets/my_app_bar.dart';
import 'package:arnaldo/widgets/my_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class ProdutosPage extends StatefulWidget {
  const ProdutosPage({super.key});

  @override
  State<ProdutosPage> createState() => _ProdutosPageState();
}

class _ProdutosPageState extends State<ProdutosPage> {
  late ProdutosController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Modular.get<ProdutosController>();
    _controller.dataSelecionada.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: myAppBar(context: context, title: 'Produtos'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    _showDatePicker(context);
                  },
                  child: Text(
                    _controller.dataSelecionadaFormatadaPadraoBr,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          myDivider(context: context),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: size.width * 0.4,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Produtos',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: size.width * 0.25,
                            child: const Text(
                              'Preço de compra',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: size.width * 0.25,
                            child: const Text(
                              'Preço de venda',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                myDivider(context: context),
                ValueListenableBuilder(
                  valueListenable: _controller.dataSelecionada,
                  builder: (BuildContext context, DateTime value, Widget? child) {
                    return Text('Data selecionada: ${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}');
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _controller.dataSelecionada.value,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null && picked != _controller.dataSelecionada.value) {
      _controller.dataSelecionada.value = picked;
    }
  }
}
