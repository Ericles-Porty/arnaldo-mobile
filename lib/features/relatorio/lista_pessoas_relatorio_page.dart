import 'package:arnaldo/core/enums/pessoa_type.dart';
import 'package:arnaldo/features/relatorio/relatorio_controller.dart';
import 'package:arnaldo/widgets/my_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class ListaPessoasRelatorioPage extends StatefulWidget {
  const ListaPessoasRelatorioPage({
    super.key,
    required this.pessoaType,
  });

  final PessoaType pessoaType;

  @override
  State<ListaPessoasRelatorioPage> createState() => _ListaPessoasRelatorioPageState();
}

class _ListaPessoasRelatorioPageState extends State<ListaPessoasRelatorioPage> {
  late RelatorioController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RelatorioController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context: context, title: "Listagem de ${widget.pessoaType.name}s", hasLeading: true),
      body: FutureBuilder(
        future: _controller.buscarPessoas(widget.pessoaType),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) return Center(child: Text('Erro: ${snapshot.error}, tente novamente', style: const TextStyle(fontSize: 24)));

            if (snapshot.data == null) return const Center(child: Text("Não foi possível carregar os dados", style: TextStyle(fontSize: 24)));

            if (snapshot.data!.isEmpty) return const Center(child: Text('Nenhuma pessoa encontrada', style: TextStyle(fontSize: 24)));

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  minVerticalPadding: 20,
                  tileColor: index.isEven ? Colors.grey[200] : Colors.white,
                  title: Text(
                    snapshot.data![index].nome,
                    style: TextStyle(decoration: snapshot.data![index].ativo ? TextDecoration.none : TextDecoration.lineThrough),
                  ),
                  titleTextStyle: const TextStyle(fontSize: 24, color: Colors.black),
                  onTap: () {
                    Modular.to.pushNamed('/relatorio/pessoa', arguments: snapshot.data![index]);
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      Modular.to.pushNamed('/relatorio/pessoa', arguments: snapshot.data![index]);
                    },
                  ),
                );
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
