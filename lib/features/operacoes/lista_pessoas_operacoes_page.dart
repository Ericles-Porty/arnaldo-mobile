import 'package:arnaldo/core/enums/pessoa_type.dart';
import 'package:arnaldo/features/operacoes/operacoes_controller.dart';
import 'package:arnaldo/features/operacoes/widgets/linha_pessoa_operacoes.dart';
import 'package:arnaldo/models/pessoa.dart';
import 'package:arnaldo/widgets/my_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class ListaPessoasOperacoesPage extends StatelessWidget {
  const ListaPessoasOperacoesPage({super.key, required this.tipoPessoa});

  final PessoaType tipoPessoa;

  @override
  Widget build(BuildContext context) {
    final controller = Modular.get<OperacoesController>();
    final String appBarTitle = '${tipoPessoa == PessoaType.cliente ? 'Vendas' : 'Compras'} por ${tipoPessoa.name}';
    return Scaffold(
      appBar: myAppBar(context: context, title: appBarTitle, hasLeading: true),
      body: FutureBuilder(
        future: controller.fetchPessoas(tipoPessoa),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else {
            final List<Pessoa> pessoas = snapshot.data as List<Pessoa>;
            if (pessoas.isEmpty) {
              return Center(
                child: Text(
                  'Nenhum ${tipoPessoa == PessoaType.cliente ? 'cliente' : 'fornecedor'} cadastrado.',
                  style: const TextStyle(fontSize: 42, color: Colors.grey),
                ),
              );
            }
            return ListView.builder(
              itemCount: pessoas.length,
              itemBuilder: (context, index) {
                final pessoa = pessoas[index];
                return LinhaPessoaOperacoes(pessoa: pessoa);
              },
            );
          }
        },
      ),
    );
  }
}
