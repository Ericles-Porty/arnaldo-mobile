import 'package:arnaldo/core/enums/pessoa_type.dart';
import 'package:arnaldo/features/relatorio/relatorio_controller.dart';
import 'package:arnaldo/features/relatorio/relatorio_page.dart';
import 'package:arnaldo/features/relatorio/lista_pessoas_relatorio_page.dart';
import 'package:arnaldo/features/relatorio/relatorio_periodo_page.dart';
import 'package:arnaldo/models/pessoa.dart';
import 'package:flutter_modular/flutter_modular.dart';

class RelatorioModule extends Module {
  @override
  void binds(i) {
    i.addSingleton(RelatorioController.new);
  }

  @override
  void routes(r) {
    r.child('/', child: (context) => const RelatorioPage());
    r.child('/pessoas', child: (context) => ListaPessoasRelatorioPage(pessoaType: r.args.data as PessoaType));
    r.child('/pessoa', child: (context) => RelatorioPeriodoPage(pessoa: r.args.data as Pessoa));
  }
}
