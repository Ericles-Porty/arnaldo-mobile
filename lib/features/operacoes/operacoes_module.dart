import 'package:arnaldo/core/enums/pessoa_type.dart';
import 'package:arnaldo/features/operacoes/lista_operacoes_pessoa_page.dart';
import 'package:arnaldo/features/operacoes/lista_pessoas_operacoes_page.dart';
import 'package:arnaldo/features/operacoes/operacoes_controller.dart';
import 'package:arnaldo/models/pessoa.dart';
import 'package:flutter_modular/flutter_modular.dart';

class OperacoesModule extends Module {
  @override
  void binds(i) {
    i.addSingleton(OperacoesController.new);
  }

  @override
  void routes(r) {
    r.child('/pessoas', child: (context) => ListaPessoasOperacoesPage(tipoPessoa: r.args.data as PessoaType));
    r.child('/pessoa', child: (context) => ListaOperacoesPessoaPage(pessoa: r.args.data as Pessoa));
  }
}
