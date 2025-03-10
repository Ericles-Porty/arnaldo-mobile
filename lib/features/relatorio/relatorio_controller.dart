import 'package:arnaldo/core/database/database_helper.dart';
import 'package:arnaldo/core/enums/pessoa_type.dart';
import 'package:arnaldo/features/operacoes/dtos/linha_operacao_dto.dart';
import 'package:arnaldo/models/pessoa.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class RelatorioController {
  final ValueNotifier<DateTime> dataSelecionadaInicio = ValueNotifier<DateTime>(DateTime.now().subtract(const Duration(days: 7)));
  final ValueNotifier<DateTime> dataSelecionadaFim = ValueNotifier<DateTime>(DateTime.now());

  String get dataSelecionadaInicioFormatadaPadraoBr =>
      '${dataSelecionadaInicio.value.day.toString().padLeft(2, '0')}/${dataSelecionadaInicio.value.month.toString().padLeft(2, '0')}/${dataSelecionadaInicio.value.year}';

  String get dataSelecionadaFimFormatadaPadraoBr =>
      '${dataSelecionadaFim.value.day.toString().padLeft(2, '0')}/${dataSelecionadaFim.value.month.toString().padLeft(2, '0')}/${dataSelecionadaFim.value.year}';

  Future<List<Pessoa>> buscarPessoas(PessoaType tipoPessoa) async {
    var db = Modular.get<DatabaseHelper>();

    return db.getPessoas(tipoPessoa.name);
  }

  Future<List<LinhaOperacaoDto>> buscarOperacoes({required Pessoa pessoa, required DateTime dataInicial, required DateTime dataFinal}) async {
    var db = Modular.get<DatabaseHelper>();

    return db.getPessoaOperacoesByDateRange(pessoa: pessoa, dataInicial: dataInicial, dataFinal: dataFinal);
  }
}
