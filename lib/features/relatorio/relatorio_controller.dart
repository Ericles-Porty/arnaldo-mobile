import 'package:arnaldo/core/database/database_helper.dart';
import 'package:arnaldo/core/enums/pessoa_type.dart';
import 'package:arnaldo/models/operacao.dart';
import 'package:arnaldo/models/pessoa.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class RelatorioController {
  final ValueNotifier<DateRange> periodoSelecionado =
      ValueNotifier<DateRange>(DateRange(inicio: DateTime.now().subtract(const Duration(days: 7)), fim: DateTime.now()));
  final ValueNotifier<DateTime> mesSelecionado = ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<int> anoSelecionado = ValueNotifier<int>(DateTime.now().year);
  final Map<int, ValueNotifier<bool>> operacoesPagas = {};

  Future<List<Pessoa>> buscarPessoas(PessoaType tipoPessoa) async {
    var db = Modular.get<DatabaseHelper>();

    return db.getPessoas(tipoPessoa.name);
  }

  final ValueNotifier<List<Operacao>> operacoes = ValueNotifier<List<Operacao>>([]);

  Future<List<Operacao>> buscarOperacoes({required int idPessoa, required DateRange periodo}) async {
    var db = Modular.get<DatabaseHelper>();
    var listaOperacoes = await db.listarOperacoes(idPessoa: idPessoa, dataInicio: periodo.inicio, dataFim: periodo.fim);
    operacoes.value = listaOperacoes;

    for (var operacao in listaOperacoes) {
      operacoesPagas[operacao.id] = ValueNotifier<bool>(operacao.pago);
    }
    return listaOperacoes;
  }

  Future<int> atualizarPagoOperacao({required int idOperacao, required bool pago}) async {
    var db = Modular.get<DatabaseHelper>();
    operacoesPagas[idOperacao]?.value = pago;

    return db.updateOperacaoPago(id: idOperacao, pago: pago);
  }
}

class DateRange {
  final DateTime inicio;
  final DateTime fim;

  DateRange({required this.inicio, required this.fim});
}
