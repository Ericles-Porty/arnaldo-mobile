import 'package:arnaldo/core/database/database_helper.dart';
import 'package:arnaldo/core/enums/operacao_type.dart';
import 'package:arnaldo/core/enums/pessoa_type.dart';
import 'package:arnaldo/features/operacoes/dtos/linha_operacao_dto.dart';
import 'package:arnaldo/models/pessoa.dart';
import 'package:arnaldo/models/produto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class OperacoesController {
  final ValueNotifier<DateTime> dataSelecionada = ValueNotifier<DateTime>(DateTime.now());

  List<Produto> produtosSemOperacao = [];

  String get dataSelecionadaFormatadaPadraoBr =>
      '${dataSelecionada.value.day.toString().padLeft(2, '0')}/${dataSelecionada.value.month.toString().padLeft(2, '0')}/${dataSelecionada.value.year}';

  Future<List<Pessoa>> fetchPessoas(PessoaType tipoPessoa) async {
    var db = Modular.get<DatabaseHelper>();
    return await db.getPessoas(tipoPessoa.name);
  }

  Future<List<LinhaOperacaoDto>> fetchOperacoes(Pessoa pessoa) async {
    var db = Modular.get<DatabaseHelper>();
    return await db.getPessoaOperacoes(data: dataSelecionada.value, pessoa: pessoa);
  }

  Future<List<LinhaOperacaoDto>> fetchOperacoesV2(Pessoa pessoa) async {
    var db = Modular.get<DatabaseHelper>();
    await fetchProdutosSemOperacao(pessoa: pessoa, data: dataSelecionada.value);
    return await db.getPessoaOperacoesV2(data: dataSelecionada.value, pessoa: pessoa);
  }

  Future<int> atualizarOperacao(LinhaOperacaoDto linhaOperacaoDto) async {
    var db = Modular.get<DatabaseHelper>();

    final operacao = await db.getOperacao(
      idProduto: linhaOperacaoDto.produto.id,
      idPessoa: linhaOperacaoDto.pessoa.id,
      tipoOperacao: linhaOperacaoDto.pessoa.tipo == PessoaType.cliente.name ? OperacaoType.venda.name : OperacaoType.compra.name,
      data: dataSelecionada.value,
    );

    if (operacao == null) return await salvarOperacao(linhaOperacaoDto);

    return await db.updateOperacao(id: operacao.id, quantidade: linhaOperacaoDto.quantidade, desconto: linhaOperacaoDto.desconto);
  }

  Future<int> salvarOperacao(LinhaOperacaoDto linhaOperacaoDto) async {
    var db = Modular.get<DatabaseHelper>();

    return await db.insertOperacao(
      idProduto: linhaOperacaoDto.produto.id,
      idPessoa: linhaOperacaoDto.pessoa.id,
      tipoOperacao: linhaOperacaoDto.pessoa.tipo == PessoaType.cliente.name ? OperacaoType.venda.name : OperacaoType.compra.name,
      quantidade: linhaOperacaoDto.quantidade,
      desconto: linhaOperacaoDto.desconto,
      data: dataSelecionada.value,
      comentario: linhaOperacaoDto.comentario,
    );
  }

  // Retorna a lista com id e nome dos produtos que não tiveram operações na data selecionada para a pessoa informada
  Future<List<Produto>> fetchProdutosSemOperacao({required Pessoa pessoa, required DateTime data}) async {
    var db = Modular.get<DatabaseHelper>();
    produtosSemOperacao = await db.getProdutosSemOperacao(data: dataSelecionada.value, pessoa: pessoa);
    return produtosSemOperacao;
  }
}
