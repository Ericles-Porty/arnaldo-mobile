import 'package:arnaldo/core/enums/rota.dart';
import 'package:arnaldo/features/exportar/exportar_module.dart';
import 'package:arnaldo/features/home/home_page.dart';
import 'package:arnaldo/features/importar/importar_module.dart';
import 'package:arnaldo/features/operacoes/operacoes_module.dart';
import 'package:arnaldo/features/pessoas/pessoas_module.dart';
import 'package:arnaldo/features/produtos/produtos_module.dart';
import 'package:arnaldo/features/relatorio/relatorio_module.dart';
import 'package:flutter_modular/flutter_modular.dart';

class HomeModule extends Module {
  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.child('/', child: (context) => HomePage());
    r.child('/${Rota.home.name}', child: (context) => HomePage());
    r.module('/pessoas', module: PessoasModule());
    r.module('/produtos', module: ProdutosModule());
    r.module('/operacoes', module: OperacoesModule());
    r.module('/relatorio', module: RelatorioModule());
    r.module('/exportar', module: ExportarModule());
    r.module('/importar', module: ImportarModule());
  }
}
