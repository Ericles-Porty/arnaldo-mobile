import 'package:arnaldo/core/utils.dart';
import 'package:arnaldo/features/relatorio/relatorio_controller.dart';
import 'package:arnaldo/models/operacao.dart';
import 'package:arnaldo/models/pessoa.dart';
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class AnualTab extends StatefulWidget {
  const AnualTab({super.key, required this.pessoa});

  final Pessoa pessoa;

  @override
  State<AnualTab> createState() => _AnualTabState();
}

class _AnualTabState extends State<AnualTab> {
  late RelatorioController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RelatorioController();
  }

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
      initialDate: DateTime(_controller.anoSelecionado.value),
    );

    if (ano != null) _controller.anoSelecionado.value = ano;

    await _controller.buscarOperacoes(
        idPessoa: widget.pessoa.id,
        periodo: DateRange(inicio: DateTime(_controller.anoSelecionado.value), fim: DateTime(_controller.anoSelecionado.value + 1)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 50,
            child: Row(
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
                  child: ValueListenableBuilder(
                    valueListenable: _controller.anoSelecionado,
                    builder: (BuildContext context, int ano, Widget? child) {
                      return Text(
                        "$ano",
                        style: const TextStyle(fontSize: 18),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _controller.buscarOperacoes(
                  idPessoa: widget.pessoa.id,
                  periodo: DateRange(inicio: DateTime(_controller.anoSelecionado.value), fim: DateTime(_controller.anoSelecionado.value + 1))),
              builder: (context, snapshot) {
                return ValueListenableBuilder(
                  valueListenable: _controller.operacoes,
                  builder: (BuildContext context, List<Operacao> operacoes, Widget? child) {
                    if (operacoes.isEmpty) return const Center(child: Text('Nenhuma operação encontrada.'));

                    return Column(
                      children: [
                        Container(
                          color: Colors.grey[300],
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          child: const OperacaoHeader(),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                ...operacoes.map((op) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(color: Colors.grey[300]!),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                    child: operacaoRow(op),
                                  );
                                })
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Row operacaoRow(Operacao op) {
    final total = (op.preco * op.quantidade) - op.desconto;
    final dataFormatada = formatarDataPadraoBr(obterDataPorString(op.data));
    return Row(
      children: [
        _Cell(dataFormatada),
        _Cell(op.produto?.nome ?? '-'),
        _Cell(op.quantidade.toString()),
        _Cell('R\$ ${op.preco.toStringAsFixed(2)}'),
        _Cell('R\$ ${op.desconto.toStringAsFixed(2)}'),
        _Cell('R\$ ${total.toStringAsFixed(2)}'),
        _Cell(op.comentario ?? '-'),
        _Cell(op.pago ? 'Sim' : 'Não'),
      ],
    );
  }
}

class OperacaoHeader extends StatelessWidget {
  const OperacaoHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _HeaderCell('Data'),
        _HeaderCell('Produto'),
        _HeaderCell('Quantidade'),
        _HeaderCell('Preço'),
        _HeaderCell('Desconto'),
        _HeaderCell('Total'),
        _HeaderCell('Comentário'),
        _HeaderCell('Pago'),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;

  const _HeaderCell(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;

  const _Cell(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
    );
  }
}
