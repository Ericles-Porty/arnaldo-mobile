import 'package:arnaldo/core/enums/pessoa_type.dart';
import 'package:arnaldo/core/utils.dart';
import 'package:arnaldo/features/operacoes/dtos/linha_operacao_dto.dart';
import 'package:arnaldo/features/operacoes/operacoes_controller.dart';
import 'package:arnaldo/models/pessoa.dart';
import 'package:arnaldo/models/produto.dart';
import 'package:arnaldo/widgets/my_app_bar.dart';
import 'package:arnaldo/widgets/my_divider.dart';
import 'package:arnaldo/widgets/my_vertical_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class ListaOperacoesPessoaPage extends StatefulWidget {
  const ListaOperacoesPessoaPage({super.key, required this.pessoa});

  final Pessoa pessoa;

  @override
  State<ListaOperacoesPessoaPage> createState() => _ListaOperacoesPessoaPageState();
}

class _ListaOperacoesPessoaPageState extends State<ListaOperacoesPessoaPage> {
  late OperacoesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Modular.get<OperacoesController>();
  }

  @override
  Widget build(BuildContext context) {
    final tipoOperacao = widget.pessoa.tipo == PessoaType.cliente.name ? 'Compras' : 'Vendas';
    return Scaffold(
      appBar: myAppBar(
        context: context,
        title: '$tipoOperacao de ${widget.pessoa.nome}',
        hasLeading: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    _showDatePicker(context);
                  },
                  child: ValueListenableBuilder(
                    valueListenable: _controller.dataSelecionada,
                    builder: (BuildContext context, DateTime data, Widget? child) {
                      return Text(
                        _controller.dataSelecionadaFormatadaPadraoBr,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Builder(builder: (context) {
                      final size = MediaQuery.of(context).size;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: size.width * 0.275,
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Quantidade',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          myVerticalDivider(size: size),
                          SizedBox(
                            width: size.width * 0.175,
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Preço',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          myVerticalDivider(size: size),
                          SizedBox(
                            width: size.width * 0.15,
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Desconto',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          myVerticalDivider(size: size),
                          SizedBox(
                            width: size.width * 0.2,
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Total',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
          myDivider(context: context, indent: 0),
          ValueListenableBuilder(
            valueListenable: _controller.dataSelecionada,
            builder: (BuildContext context, DateTime data, Widget? child) {
              return Expanded(
                child: FutureBuilder(
                  future: _controller.fetchOperacoesV2(widget.pessoa),
                  builder: (BuildContext context, AsyncSnapshot<List<LinhaOperacaoDto>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Erro ao carregar operacoes'));
                    }
                    final size = MediaQuery.of(context).size;
                    final operacoes = snapshot.data!;
                    return Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                ListView.builder(
                                  primary: false,
                                  shrinkWrap: true,
                                  itemCount: operacoes.length,
                                  itemBuilder: (context, index) {
                                    final operacao = operacoes[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                                          border: Border.all(
                                            color: Theme.of(context).colorScheme.secondary,
                                            width: 3,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        operacao.produto.nome,
                                                        textAlign: TextAlign.center,
                                                        style: const TextStyle(
                                                          fontSize: 24,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4),
                                              child: myDivider(context: context, indent: 0),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: size.width * 0.25,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      SizedBox(
                                                        width: size.width * 0.175,
                                                        child: InkWell(
                                                          onTap: () async {
                                                            await _showDialogEditarQuantidade(context: context, linhaOperacaoDto: operacao);
                                                          },
                                                          child: SizedBox(
                                                            child: Text(
                                                              '${formatarValorMonetario(operacao.quantidade)} ${operacao.produto.medida}',
                                                              textAlign: TextAlign.center,
                                                              style: const TextStyle(
                                                                fontSize: 18,
                                                                decoration: TextDecoration.underline,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: size.width * 0.07,
                                                        child: Center(
                                                          child: Stack(
                                                            children: [
                                                              IconButton(
                                                                onPressed: () async {
                                                                  await _showDialogComentario(context: context, linhaOperacaoDto: operacao, data: data);
                                                                },
                                                                icon: const Icon(
                                                                  Icons.comment,
                                                                  color: Colors.green,
                                                                ),
                                                              ),
                                                              // Colocar a condição de quando tiver 1 ou mais comentários
                                                              if (operacao.comentario != null && operacao.comentario!.isNotEmpty)
                                                                Positioned(
                                                                  right: 0,
                                                                  top: 0,
                                                                  child: Container(
                                                                    padding: const EdgeInsets.all(2),
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.white,
                                                                      borderRadius: BorderRadius.circular(10),
                                                                    ),
                                                                    constraints: const BoxConstraints(
                                                                      minWidth: 20,
                                                                      minHeight: 20,
                                                                    ),
                                                                    child: const Text(
                                                                      '1',
                                                                      style: TextStyle(
                                                                        color: Colors.black,
                                                                        fontSize: 12,
                                                                      ),
                                                                      textAlign: TextAlign.center,
                                                                    ),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                myVerticalDivider(size: size),
                                                SizedBox(
                                                  width: size.width * 0.2,
                                                  child: Text(
                                                    'R\$${formatarValorMonetario(operacao.preco)}',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ),
                                                myVerticalDivider(size: size),
                                                InkWell(
                                                  onTap: () async {
                                                    await _showDialogEditarDesconto(context: context, linhaOperacaoDto: operacao);
                                                  },
                                                  child: SizedBox(
                                                    width: size.width * 0.2,
                                                    child: Text(
                                                      'R\$${formatarValorMonetario(operacao.desconto)}',
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        decoration: TextDecoration.underline,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                myVerticalDivider(size: size),
                                                SizedBox(
                                                  width: size.width * 0.2,
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      'R\$${formatarValorMonetario(operacao.total)}',
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                if (_controller.produtosSemOperacao.isNotEmpty)
                                  ElevatedButton(
                                    child: Text('Adicionar nova ${widget.pessoa.tipo == PessoaType.cliente.name ? 'venda' : 'compra'}', style: TextStyle(fontSize: 24)),
                                    onPressed: () async {
                                      var produtosSemOperacao = await _controller.fetchProdutosSemOperacao(pessoa: widget.pessoa, data: data);
                                      await _showModalBottomSheetAdicionarOperacao(context: context, produtosSemOperacao: produtosSemOperacao);
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // total
                        SizedBox(
                          height: 100,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.secondary,
                                  width: 3,
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Total',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 24,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: myDivider(context: context, indent: 0),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: size.width * 0.2,
                                        child: const Text(
                                          ' ',
                                        ),
                                      ),
                                      myVerticalDivider(size: size),
                                      SizedBox(
                                        width: size.width * 0.2,
                                        child: const Text(
                                          ' ',
                                        ),
                                      ),
                                      myVerticalDivider(size: size),
                                      SizedBox(
                                        width: size.width * 0.2,
                                        child: Text(
                                          'R\$${formatarValorMonetario(operacoes.fold(0, (total, operacao) => total + operacao.desconto))}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      myVerticalDivider(size: size),
                                      SizedBox(
                                        width: size.width * 0.2,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            'R\$${formatarValorMonetario(operacoes.fold(0, (total, operacao) => total + operacao.total))}',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _controller.dataSelecionada.value,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null && picked != _controller.dataSelecionada.value) {
      _controller.dataSelecionada.value = picked;
    }
  }

  Future<dynamic> _showDialogComentario({
    required BuildContext context,
    required LinhaOperacaoDto linhaOperacaoDto,
    required DateTime data,
  }) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController controller = TextEditingController(text: linhaOperacaoDto.comentario);
        return AlertDialog(
          title: const Text('Comentário', style: TextStyle(fontSize: 32)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Pessoa: ${linhaOperacaoDto.pessoa.nome}',
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 26,
                ),
              ),
              Text(
                'Produto: ${linhaOperacaoDto.produto.nome}',
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 26,
                ),
              ),
              Text(
                'Data: ${formatarDataPadraoBr(data)}',
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                style: const TextStyle(fontSize: 24),
                controller: controller,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  hintText: 'Digite o comentário',
                  label: Text('Comentário', style: TextStyle(fontSize: 24)),
                ),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar', style: TextStyle(fontSize: 24, color: Colors.red)),
                ),
                ElevatedButton(
                  child: const Text('Salvar', style: TextStyle(fontSize: 32)),
                  onPressed: () async {
                    await _controller.salvarOperacao(linhaOperacaoDto.copyWith(
                      comentario: controller.text,
                    ));
                    Navigator.of(context).pop();
                    setState(() {});
                  },
                ),
              ],
            )
          ],
        );
      },
    );
  }

  Future<dynamic> _showModalBottomSheetAdicionarOperacao({
    required BuildContext context,
    required List<Produto> produtosSemOperacao,
  }) {
    final size = MediaQuery.of(context).size;
    return showModalBottomSheet(
      isScrollControlled: true,
      scrollControlDisabledMaxHeightRatio: 0.5,
      showDragHandle: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            child: ListView.builder(
              primary: false,
              shrinkWrap: true,
              itemCount: produtosSemOperacao.length,
              itemBuilder: (context, index) {
                final produto = produtosSemOperacao[index];
                return Center(
                  child: Column(
                    children: [
                      SizedBox(
                        width: size.width * 0.8,
                        child: ElevatedButton(
                          child: Text(produto.nome, style: const TextStyle(fontSize: 32)),
                          onPressed: () async {
                            LinhaOperacaoDto linhaOperacaoDto = LinhaOperacaoDto(
                              pessoa: widget.pessoa,
                              produto: produto,
                              quantidade: 0,
                              preco: 0,
                              total: 0,
                              desconto: 0,
                            );
                            await _controller.salvarOperacao(linhaOperacaoDto);
                            Navigator.of(context).pop();
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> _showDialogEditarQuantidade({
    required BuildContext context,
    required LinhaOperacaoDto linhaOperacaoDto,
  }) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        final textoInicial = formatarValorMonetarioOuVazio(linhaOperacaoDto.quantidade);
        TextEditingController textEditingController = TextEditingController(text: textoInicial);
        return AlertDialog(
          title: const Text('Editar quantidade', style: TextStyle(fontSize: 32)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Pessoa: ${linhaOperacaoDto.pessoa.nome}',
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 26,
                ),
              ),
              Text(
                'Produto: ${linhaOperacaoDto.produto.nome}',
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 26,
                ),
              ),
              Text(
                'Preço atual: R\$${linhaOperacaoDto.preco}',
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                style: const TextStyle(fontSize: 24),
                controller: textEditingController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Digite a nova quantidade',
                  label: Text('Nova quantidade', style: TextStyle(fontSize: 24)),
                ),
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar', style: TextStyle(fontSize: 24, color: Colors.red)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _controller.atualizarOperacao(linhaOperacaoDto.copyWith(
                      quantidade: double.parse(textEditingController.text),
                    ));
                    Navigator.of(context).pop();
                    setState(() {});
                  },
                  child: const Text('Salvar', style: TextStyle(fontSize: 32)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> _showDialogEditarDesconto({
    required BuildContext context,
    required LinhaOperacaoDto linhaOperacaoDto,
  }) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        final textoInicial = formatarValorMonetarioOuVazio(linhaOperacaoDto.desconto);
        TextEditingController textEditingController = TextEditingController(text: textoInicial);
        return AlertDialog(
          title: const Text('Editar desconto', style: TextStyle(fontSize: 32)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Pessoa: ${linhaOperacaoDto.pessoa.nome}',
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 26,
                ),
              ),
              Text(
                'Produto: ${linhaOperacaoDto.produto.nome}',
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 26,
                ),
              ),
              Text(
                'Preço atual: R\$${linhaOperacaoDto.preco}',
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                style: const TextStyle(fontSize: 24),
                controller: textEditingController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Digite o novo desconto',
                  label: Text('Novo desconto', style: TextStyle(fontSize: 24)),
                ),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar', style: TextStyle(fontSize: 24, color: Colors.red)),
                ),
                ElevatedButton(
                  child: const Text('Salvar', style: TextStyle(fontSize: 32)),
                  onPressed: () async {
                    await _controller.atualizarOperacao(linhaOperacaoDto.copyWith(
                      desconto: double.parse(textEditingController.text),
                    ));
                    Navigator.of(context).pop();
                    setState(() {});
                  },
                ),
              ],
            )
          ],
        );
      },
    );
  }
}
