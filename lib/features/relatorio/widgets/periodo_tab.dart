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
      initialDateRange: DateTimeRange(start: _controller.periodo.value.inicio, end: _controller.periodo.value.fim),
    );

    if (picked != null) {
      _controller.periodo.value = DateRange(inicio: picked.start, fim: picked.end);
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
            spacing: 5,''
            children: [
              const Text(
                "Período selecionado:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _selecionarPeriodo,
                child: Text("${_controller.dataSelecionadaInicioFormatadaPadraoBr} - ${_controller.dataSelecionadaFimFormatadaPadraoBr}"),
              ),
            ],
          ),
          ValueListenableBuilder<DateRange>(
            valueListenable: _controller.periodo,
            builder: (BuildContext context, DateRange value, Widget? child) {
              return FutureBuilder(
                  future: _controller.buscarOperacoes(idPessoa: widget.pessoa.id, periodo: value),
                  builder: (BuildContext context, AsyncSnapshot<List<Operacao>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Erro: ${snapshot.error}'));
                    }

                    return Expanded(
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Data"),
                              Text("Produto"),
                              Text("Quantidade"),
                              Text("Preço"),
                              Text("Desconto"),
                              Text("Total"),
                              Text("Comentário"),
                              Text("Pago"),
                            ],
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(formatarDataPadraoBr(obterDataPorString(snapshot.data![index].data))),
                                    Text(snapshot.data![index].produto!.nome),
                                    Text(snapshot.data![index].quantidade.toString()),
                                    Text(snapshot.data![index].preco.toString()),
                                    Text(snapshot.data![index].desconto.toString()),
                                    Text(formatarValorMonetario(
                                        snapshot.data![index].quantidade * snapshot.data![index].preco - snapshot.data![index].desconto)),
                                    Text(snapshot.data![index].comentario ?? ''),
                                    ValueListenableBuilder(
                                        valueListenable: _controller.operacoesPagas,
                                        builder: (context, value, child) {
                                          return Checkbox(
                                            value: value[snapshot.data![index].id] ?? false,
                                            onChanged: (bool? value) {
                                              final operacaoAtualizada = snapshot.data![index].copyWith(pago: value ?? false);
                                              _controller.atualizarPagoOperacao(idOperacao: operacaoAtualizada.id, pago: value!);
                                              snapshot.data![index] = operacaoAtualizada;
                                              _controller.operacoesPagas.value[snapshot.data![index].id] = value ?? false;
                                            },
                                          );
                                        }),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  });
            },
          ),
        ],
      ),
    );
  }
}
