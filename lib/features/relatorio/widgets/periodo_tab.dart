import 'package:arnaldo/core/utils.dart';
import 'package:arnaldo/features/relatorio/relatorio_controller.dart';
import 'package:arnaldo/models/operacao.dart';
import 'package:arnaldo/models/pessoa.dart';
import 'package:flutter/material.dart';

class PeriodoTab extends StatefulWidget {
  const PeriodoTab({super.key, required this.pessoa});

  final Pessoa pessoa;

  @override
  State<PeriodoTab> createState() => _PeriodoTabState();
}

class _PeriodoTabState extends State<PeriodoTab> {
  late RelatorioController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RelatorioController();
  }

  Future<void> _selecionarPeriodo() async {
    final amanha = DateTime.now().add(const Duration(days: 1));
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: amanha,
      initialDateRange: DateTimeRange(start: _controller.periodoSelecionado.value.inicio, end: _controller.periodoSelecionado.value.fim),
    );

    if (picked != null) _controller.periodoSelecionado.value = DateRange(inicio: picked.start, fim: picked.end);

    await _controller.buscarOperacoes(
      idPessoa: widget.pessoa.id,
      periodo: DateRange(
        inicio: _controller.periodoSelecionado.value.inicio,
        fim: _controller.periodoSelecionado.value.fim,
      ),
    );
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
                  "Período selecionado:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _selecionarPeriodo,
                  child: ValueListenableBuilder(
                    valueListenable: _controller.periodoSelecionado,
                    builder: (BuildContext context, DateRange periodo, Widget? child) {
                      return Text(
                        "${formatarDataPadraoBr(periodo.inicio)} - ${formatarDataPadraoBr(periodo.fim)}",
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
              future: _controller.buscarOperacoes(idPessoa: widget.pessoa.id, periodo: _controller.periodoSelecionado.value),
              builder: (context, snapshot) {
                return ValueListenableBuilder(
                  valueListenable: _controller.operacoes,
                  builder: (BuildContext context, List<Operacao> operacoes, Widget? child) {
                    if (operacoes.isEmpty) return const Center(child: Text('Nenhuma operação encontrada.'));

                    return Column(
                      children: [
                        Container(
                          width: double.infinity,
                          color: Colors.grey[300],
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
                          child: const OperacaoHeader(),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                for (int i = 0; i < operacoes.length; i++)
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(color: Colors.grey[300]!),
                                      ),
                                    ),
                                    child: operacaoRow(operacoes[i], cor: i % 2 == 1 ? Colors.grey[200] : Colors.white),
                                  ),
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

  Widget operacaoRow(Operacao op, {Color? cor}) {
    final total = (op.preco * op.quantidade) - op.desconto;
    final dataFormatada = formatarDataPadraoBr(obterDataPorString(op.data));
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 1),
      color: cor ?? Colors.white,
      child: Row(
        children: [
          _Cell(dataFormatada),
          _Cell(op.produto?.nome ?? '-'),
          _Cell(op.quantidade.toString()),
          _Cell('R\$ ${op.preco.toStringAsFixed(2)}'),
          _Cell('R\$ ${op.desconto.toStringAsFixed(2)}'),
          _Cell('R\$ ${total.toStringAsFixed(2)}'),
          _Cell(op.comentario ?? '-'),
          switchCell(op),
        ],
      ),
    );
  }

  SizedBox switchCell(Operacao op) {
    return SizedBox(
      width: 76,
      child: ValueListenableBuilder(
          valueListenable: _controller.operacoesPagas[op.id]!,
          builder: (BuildContext context, bool pago, Widget? child) {
            return Switch(
              value: pago,
              onChanged: (bool value) async => await _controller.atualizarPagoOperacao(idOperacao: op.id, pago: value),
              activeColor: Colors.green,
              activeTrackColor: Colors.green[200],
              inactiveThumbColor: Colors.red,
              inactiveTrackColor: Colors.red[200],
            );
          }),
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
    return SizedBox(
      width: 76,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
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
      width: 76,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
    );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             spacing: 5,
//             children: [
//               const Text(
//                 "Período selecionado:",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 10),
//               ElevatedButton(
//                 onPressed: _selecionarPeriodo,
//                 child: Text("${_controller.dataSelecionadaInicioFormatadaPadraoBr} - ${_controller.dataSelecionadaFimFormatadaPadraoBr}"),
//               ),
//             ],
//           ),
//           ValueListenableBuilder<DateRange>(
//             valueListenable: _controller.periodo,
//             builder: (BuildContext context, DateRange value, Widget? child) {
//               return FutureBuilder(
//                   future: _controller.buscarOperacoes(idPessoa: widget.pessoa.id, periodo: value),
//                   builder: (BuildContext context, AsyncSnapshot<List<Operacao>> snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(child: CircularProgressIndicator());
//                     }
//
//                     if (snapshot.hasError) {
//                       return Center(child: Text('Erro: ${snapshot.error}'));
//                     }
//
//                     return Expanded(
//                       child: Column(
//                         children: [
//                           const Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text("Data"),
//                               Text("Produto"),
//                               Text("Quantidade"),
//                               Text("Preço"),
//                               Text("Desconto"),
//                               Text("Total"),
//                               Text("Comentário"),
//                               Text("Pago"),
//                             ],
//                           ),
//                           Expanded(
//                             child: ListView.builder(
//                               itemCount: snapshot.data!.length,
//                               itemBuilder: (context, index) {
//                                 return Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(formatarDataPadraoBr(obterDataPorString(snapshot.data![index].data))),
//                                     Text(snapshot.data![index].produto!.nome),
//                                     Text(snapshot.data![index].quantidade.toString()),
//                                     Text(snapshot.data![index].preco.toString()),
//                                     Text(snapshot.data![index].desconto.toString()),
//                                     Text(formatarValorMonetario(
//                                         snapshot.data![index].quantidade * snapshot.data![index].preco - snapshot.data![index].desconto)),
//                                     Text(snapshot.data![index].comentario ?? ''),
//                                     // ValueListenableBuilder(
//                                     //     valueListenable: _controller.operacoesPagas,
//                                     //     builder: (context, value, child) {
//                                     //       return Checkbox(
//                                     //         value: value[snapshot.data![index].id] ?? false,
//                                     //         onChanged: (bool? value) {
//                                     //           final operacaoAtualizada = snapshot.data![index].copyWith(pago: value ?? false);
//                                     //           _controller.atualizarPagoOperacao(idOperacao: operacaoAtualizada.id, pago: value!);
//                                     //           snapshot.data![index] = operacaoAtualizada;
//                                               // _controller.operacoesPagas[].value[snapshot.data![index].id] = value ?? false;
//                                     //         },
//                                     //       );
//                                     //     }),
//                                   ],
//                                 );
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   });
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
