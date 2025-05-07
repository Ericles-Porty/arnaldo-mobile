import 'dart:io';

import 'package:arnaldo/core/database/database_ddl.dart';
import 'package:arnaldo/core/database/database_seed.dart';
import 'package:arnaldo/core/enums/pessoa_type.dart';
import 'package:arnaldo/core/utils.dart';
import 'package:arnaldo/features/operacoes/dtos/linha_operacao_dto.dart';
import 'package:arnaldo/models/dtos/linha_produto_dto.dart';
import 'package:arnaldo/models/operacao.dart';
import 'package:arnaldo/models/pessoa.dart';
import 'package:arnaldo/models/produto.dart';
import 'package:arnaldo/models/produto_historico.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String _databaseName = 'arnaldo.db';
  static const String downloadFolderPath = '/storage/emulated/0/Download';
  static const String backupFolderPath = '/storage/emulated/0/Download/arnaldo/backups';
  static const String exportedFolderPath = '/storage/emulated/0/Download/arnaldo/exported';
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  //#region Helpers
  Future<void> warmUp() async {
    if (kDebugMode) print('Warming up database');
    await openDatabaseConnection();
    if (kDebugMode) print('Database warmed up');
  }

  Future<void> fake() async {}

  DatabaseHelper._internal();

  Future<String> getDatabasePath() async {
    final directory = await getDatabasesPath();
    String path = join(directory, _databaseName);
    return path;
  }

  Future<String> createDatabaseCopy({bool isExporting = false}) async {
    final dbPath = await getDatabasePath();
    final dbFile = File(dbPath);

    final directory = await getExternalStorageDirectory();
    if (directory == null) throw Exception('Não foi possível encontrar o diretório de armazenamento externo');

    // final backupFolderPath = '${directory.path}/backups';
    // final backupDirectory = Directory(backupFolderPath);
    // if (!(await backupDirectory.exists())) await backupDirectory.create(recursive: true);

    final folderPath = isExporting ? exportedFolderPath : backupFolderPath;
    final copyDirectory = Directory(folderPath);
    if (!(await copyDirectory.exists())) await copyDirectory.create(recursive: true);

    final dateNow = DateTime.now();
    final dataFormatada = formatarDataHoraPadraoUs(dateNow);
    final copyFilePath = '$folderPath/backup_$dataFormatada.db';
    await dbFile.copy(copyFilePath);
    return copyFilePath;
  }

  Future<(bool, String)> exportDatabase(String filePath) async {
    final shareResults = await Share.shareXFiles([XFile(filePath)]);
    if (shareResults.status == ShareResultStatus.success) return (true, 'Banco de dados exportado com sucesso.');
    if (shareResults.status == ShareResultStatus.dismissed) return (false, 'Exportação do banco de dados cancelada.');
    if (shareResults.status == ShareResultStatus.unavailable) return (false, 'Exportação do banco de dados indisponível.');
    return (false, 'Erro desconhecido ao exportar o banco de dados.');
  }

  Future<(bool, String)> importDatabase() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result == null || result.files.single.path == null) return (false, 'Nenhum arquivo selecionado.');

    final pickedFilePath = result.files.single.path!;
    final pickedFile = File(pickedFilePath);

    if (!await pickedFile.exists()) return (false, 'Arquivo selecionado não encontrado.');

    if (extension(pickedFilePath) != '.db') return (false, 'Arquivo selecionado não é um arquivo de banco de dados.');

    // Copia o arquivo de banco de dados atual para um arquivo de backup
    await createDatabaseCopy();

    // Fechar a conexão com o banco de dados antes de substituir
    await closeDatabaseConnection();

    // Substitui o arquivo de banco de dados atual pelo arquivo importado
    final dbPath = await getDatabasePath();
    final copiedFile = await pickedFile.copy(dbPath);

    // Reinicializa a conexão com o banco de dados
    await openDatabaseConnection();

    return (true, 'Banco de dados importado com sucesso.');
  }

  Future<void> closeDatabaseConnection() async {
    if (_database == null) return;
    if (kDebugMode) print('Closing database connection');
    await _database!.close();
    _database = null;
  }

  Future<void> openDatabaseConnection() async {
    _database ??= await _initDatabase();
    if (kDebugMode) print('Database connection opened');
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = await getDatabasePath();
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onOpen: _onOpen,
    );
  }

  Future<void> _onOpen(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await databaseDdl(db, version);
    await databaseSeed(db, version);
  }

  //#endregion

  //#region Pessoa
  Future<Pessoa> getPessoa(int id) async {
    final db = await database;
    final response = await db.query('pessoa', where: 'id = ?', whereArgs: [id]);
    return Pessoa.fromMap(response.first);
  }

  Future<List<Pessoa>> getPessoas(String tipo) async {
    final db = await database;
    final response = await db.query('pessoa', where: 'tipo = ?', orderBy: 'nome', whereArgs: [tipo]);
    return response.map((pessoa) => Pessoa.fromMap(pessoa)).toList();
  }

  Future<int> insertPessoa(String nome, String tipo) async {
    final db = await database;
    return await db.insert('pessoa', {'nome': nome, 'tipo': tipo, 'ativo': 1});
  }

  Future<int> updatePessoa(int id, String nome) async {
    final db = await database;
    return await db.update('pessoa', {'nome': nome}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deletePessoa(int id) async {
    final db = await database;
    // await db.delete('operacao', where: 'id_pessoa = ?', whereArgs: [id]);
    return await db.delete('pessoa', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> togglePessoa(int id, bool ativo) async {
    final db = await database;
    return await db.update('pessoa', {'ativo': ativo ? 1 : 0}, where: 'id = ?', whereArgs: [id]);
  }

//#endregion

  //#region Produto
  Future<Produto> getProduto(int id) async {
    final db = await database;
    final response = await db.query('produto', where: 'id = ?', whereArgs: [id]);
    return Produto.fromMap(response.first);
  }

  Future<List<Produto>> getProdutos() async {
    final db = await database;
    final response = await db.query('produto', orderBy: 'nome');
    return response.map((produto) => Produto.fromMap(produto)).toList();
  }

  Future<int> insertProduto(String nome, String medida) async {
    final db = await database;
    return await db.insert('produto', {'nome': nome, 'medida': medida});
  }

  Future<int> updateProduto(int id, String nome, String medida) async {
    final db = await database;
    return await db.update('produto', {'nome': nome, 'medida': medida}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteProduto(int id) async {
    final db = await database;
    return await db.delete('produto', where: 'id = ?', whereArgs: [id]);
  }

//#endregion

  //#region Produto Historico
  Future<LinhaProdutoDto> getProdutoPreco(int idProduto, DateTime dataSelecionada) async {
    final db = await database;

    const produtoPrecoCompraQuery = '''
      SELECT 
        PR.nome,
        PH.id_produto,
        PH.preco,
        PH.tipo
      FROM produto_historico AS PH
      JOIN produto AS PR ON PR.id = PH.id_produto
      WHERE tipo = 'compra' AND PH.data = (SELECT MAX(data) FROM produto_historico WHERE tipo = 'compra' AND id_produto = PH.id_produto AND data <= ?) AND PH.id_produto = ?
    ''';

    final produtoPrecoCompraResponse = await db.rawQuery(produtoPrecoCompraQuery, [formatarDataPadraoUs(dataSelecionada), idProduto]);
    if (produtoPrecoCompraResponse.isEmpty) {
      throw Exception('Nenhum produto cadastrado até a data informada');
    }

    const produtoPrecoVentaQuery = '''
      SELECT 
        PR.nome,
        PH.id_produto,
        PH.preco,
        PH.tipo
      FROM produto_historico AS PH
      JOIN produto AS PR ON PR.id = PH.id_produto
      WHERE tipo = 'venda' AND PH.data = (SELECT MAX(data) FROM produto_historico WHERE tipo = 'venda' AND id_produto = PH.id_produto AND data <= ?) AND PH.id_produto = ?
    ''';

    final produtoPrecoVentaResponse = await db.rawQuery(produtoPrecoVentaQuery, [formatarDataPadraoUs(dataSelecionada), idProduto]);
    if (produtoPrecoVentaResponse.isEmpty) {
      throw Exception('Nenhum produto cadastrado até a data informada');
    }

    return LinhaProdutoDto(
      nome: produtoPrecoCompraResponse.first['nome'] as String,
      idProduto: produtoPrecoCompraResponse.first['id_produto'] as int,
      precoCompra: produtoPrecoCompraResponse.first['preco'] as double,
      precoVenda: produtoPrecoVentaResponse.first['preco'] as double,
    );
  }

  Future<Map<DateTime, List<LinhaProdutoDto>>> getProdutosPrecosByDateRange({required DateTime dataInicial, required DateTime dataFinal}) async {
    final db = await database;

    const produtosPrecosCompraQuery = '''
      SELECT 
        PR.nome,
        PH.id_produto,
        PH.preco,
        PH.tipo,
        PH.data
      FROM produto_historico AS PH
      JOIN produto AS PR ON PR.id = PH.id_produto
      WHERE tipo = 'compra' AND PH.data BETWEEN ? AND ?
    ''';

    const produtosPrecosVendaQuery = '''
      SELECT 
        PR.nome,
        PH.id_produto,
        PH.preco,
        PH.tipo,
        PH.data
      FROM produto_historico AS PH
      JOIN produto AS PR ON PR.id = PH.id_produto
      WHERE tipo = 'venda' AND PH.data BETWEEN ? AND ?
    ''';

    List<Map<String, dynamic>> produtosPrecosCompraResponse =
        await db.rawQuery(produtosPrecosCompraQuery, [formatarDataPadraoUs(dataInicial), formatarDataPadraoUs(dataFinal)]);
    List<Map<String, dynamic>> produtosPrecosVentaResponse =
        await db.rawQuery(produtosPrecosVendaQuery, [formatarDataPadraoUs(dataInicial), formatarDataPadraoUs(dataFinal)]);
    List<Produto> produtos = await getProdutos();

    Map<DateTime, List<LinhaProdutoDto>> produtosPrecos = {};

    for (var data = dataInicial; data.isBefore(dataFinal); data = data.add(const Duration(days: 1))) {
      for (var produto in produtos) {
        if (produtosPrecos[data] == null) produtosPrecos[data] = [];

        produtosPrecos[data]!.add(LinhaProdutoDto(nome: produto.nome, idProduto: produto.id, precoCompra: 0, precoVenda: 0));
      }
    }

    for (var produtoHistorico in produtosPrecosCompraResponse) {
      final data = obterDataPorString(produtoHistorico['data']);
      produtosPrecos[data]!.firstWhere((element) => element.idProduto == produtoHistorico['id_produto']).precoCompra = produtoHistorico['preco'];
    }

    for (var produtoHistorico in produtosPrecosVentaResponse) {
      final data = obterDataPorString(produtoHistorico['data']);
      produtosPrecos[data]!.firstWhere((element) => element.idProduto == produtoHistorico['id_produto']).precoVenda = produtoHistorico['preco'];
    }

    return produtosPrecos;
  }

  Future<List<LinhaProdutoDto>> getProdutosPrecos(DateTime dataSelecionada) async {
    final db = await database;

    const produtosPrecosCompraQuery = '''
      SELECT 
        PR.nome,
        PH.id_produto,
        PH.preco,
        PH.tipo
      FROM produto_historico AS PH
      JOIN produto AS PR ON PR.id = PH.id_produto
      WHERE tipo = 'compra' AND PH.data = (SELECT MAX(data) FROM produto_historico WHERE tipo = 'compra' AND id_produto = PH.id_produto AND data <= ?) 
    ''';

    const produtosPrecosVendaQuery = '''
      SELECT 
        PR.nome,
        PH.id_produto,
        PH.preco,
        PH.tipo
      FROM produto_historico AS PH
      JOIN produto AS PR ON PR.id = PH.id_produto
      WHERE tipo = 'venda' AND PH.data = (SELECT MAX(data) FROM produto_historico WHERE tipo = 'venda' AND id_produto = PH.id_produto AND data <= ?) 
    ''';

    List<Map<String, dynamic>> produtosPrecosCompraResponse = await db.rawQuery(produtosPrecosCompraQuery, [formatarDataPadraoUs(dataSelecionada)]);
    List<Map<String, dynamic>> produtosPrecosVentaResponse = await db.rawQuery(produtosPrecosVendaQuery, [formatarDataPadraoUs(dataSelecionada)]);
    List<Produto> produtos = await getProdutos();

    Map<String, LinhaProdutoDto> produtosPrecos = {};

    for (var produto in produtos) {
      produtosPrecos[produto.nome] = LinhaProdutoDto(nome: produto.nome, idProduto: produto.id, precoCompra: 0, precoVenda: 0);
    }

    for (var produtoHistorico in produtosPrecosCompraResponse) {
      produtosPrecos[produtoHistorico['nome']]!.precoCompra = produtoHistorico['preco'];
    }

    for (var produtoHistorico in produtosPrecosVentaResponse) {
      produtosPrecos[produtoHistorico['nome']]!.precoVenda = produtoHistorico['preco'];
    }

    return produtosPrecos.values.toList();
  }

  // Retorna o Id e nome dos produtos que não possuem operação na data informada
  Future<List<Produto>> getProdutosSemOperacao({required Pessoa pessoa, required DateTime data}) async {
    final db = await database;

    final produtosResponse = await getProdutos();

    List<Produto> produtos = [];

    final response = await db.rawQuery('''
      SELECT 
        PR.id as id_produto,
        PR.nome as nome_produto,
        pr.medida as medida_produto
      FROM operacao AS O
      JOIN produto_historico AS PH ON PH.id = O.id_produto_historico
      JOIN produto AS PR ON PR.id = PH.id_produto
      JOIN pessoa AS P ON P.id = O.id_pessoa
      WHERE O.id_pessoa = ? AND O.data = ?
    ''', [pessoa.id, formatarDataPadraoUs(data)]);

    for (var produto in produtosResponse) {
      if (response.indexWhere((element) => element['nome_produto'] == produto.nome) == -1) {
        produtos.add(Produto(id: produto.id, nome: produto.nome, medida: produto.medida));
      }
    }

    return produtos;
  }

  Future<ProdutoHistorico?> getProductHistoricoById(int id) async {
    final db = await database;
    final response = await db.query('produto_historico', where: 'id = ?', whereArgs: [id]);
    if (response.isEmpty) return null;
    return ProdutoHistorico.fromMap(response.first);
  }

  Future<ProdutoHistorico> getProdutoHistorico({required int idProduto, required String tipoProdutoHistorico, DateTime? data}) async {
    final db = await database;

    var query = 'SELECT * FROM produto_historico WHERE id_produto = ? AND tipo = ?';
    if (data != null) query += ' AND data <= ?';
    query += ' ORDER BY data DESC, id DESC LIMIT 1';

    final response = await db.rawQuery(query, data != null ? [idProduto, tipoProdutoHistorico, formatarDataPadraoUs(data)] : [idProduto, tipoProdutoHistorico]);

    if (response.isEmpty) {
      throw Exception('Nenhum produto cadastrado até a data informada');
    }

    return ProdutoHistorico.fromMap(response.first);
  }

  Future<int> insertProdutoHistorico(int idProduto, String tipo, double preco, DateTime data) async {
    final db = await database;

    final response =
        await db.query('produto_historico', where: 'id_produto = ? AND tipo = ? AND data = ?', whereArgs: [idProduto, tipo, formatarDataPadraoUs(data)]);

    if (response.isNotEmpty) {
      return await db.update('produto_historico', {'preco': preco}, where: 'id = ?', whereArgs: [response.first['id']]);
    }

    return await db.insert('produto_historico', {
      'id_produto': idProduto,
      'tipo': tipo,
      'preco': preco,
      'data': formatarDataPadraoUs(data),
    });
  }

  Future<int> updateProdutoHistorico(int id, double preco) async {
    final db = await database;
    return await db.update('produto_historico', {'preco': preco}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> batchUpdatePrecosOperacoes({required DateTime data}) async {
    final db = await database;

    final operacoes = await db.query('operacao', where: 'data <= ?', whereArgs: [formatarDataPadraoUs(data)]);

    for (var operacao in operacoes) {
      final operacaoMapeada = Operacao.fromMap(operacao);

      final produtoHistoricoOperacao = await getProductHistoricoById(operacaoMapeada.idProdutoHistorico);
      final produtoHistoricoMaisRecente = await getProdutoHistorico(
        idProduto: produtoHistoricoOperacao!.idProduto,
        tipoProdutoHistorico: operacaoMapeada.tipo,
        data: obterDataPorString(operacaoMapeada.data),
      );

      if (produtoHistoricoMaisRecente.id == operacaoMapeada.idProdutoHistorico) continue;

      await db.update('operacao', {'id_produto_historico': produtoHistoricoMaisRecente.id}, where: 'id = ?', whereArgs: [operacaoMapeada.id]);
    }
  }

  Future<int> deleteProdutoHistorico(int id) async {
    final db = await database;
    return await db.delete('produto_historico', where: 'id = ?', whereArgs: [id]);
  }

//#endregion

  //#region Operacao
  Future<List<Operacao>> listarOperacoes({
    required int idPessoa,
    required DateTime dataInicio,
    required DateTime dataFim,
  }) async {
    final inicioStr = formatarDataHoraPadraoUs(dataInicio).substring(0, 10);
    final fimStr = formatarDataHoraPadraoUs(dataFim).substring(0, 10);

    final db = await database;

    final result = await db.rawQuery('''
    SELECT 
      o.id AS id,
      o.quantidade,
      o.preco AS preco_operacao,
      o.tipo AS tipo_operacao,
      o.data AS data_operacao,
      o.desconto,
      o.pago,
      o.comentario,
      
      ph.id AS id_produto_historico,
      ph.tipo AS tipo_produto_historico,
      ph.data AS data_produto_historico,
      ph.preco AS preco_historico,
          
      p.id AS id_produto, 
      p.nome AS nome_produto,
      p.medida,

      pes.id AS id_pessoa,
      pes.nome AS nome_pessoa,
      pes.tipo AS tipo_pessoa,
      pes.ativo AS ativo_pessoa

    FROM operacao o
    INNER JOIN produto_historico ph ON o.id_produto_historico = ph.id
    INNER JOIN produto p ON ph.id_produto = p.id
    INNER JOIN pessoa pes ON o.id_pessoa = pes.id

    WHERE o.id_pessoa = ?
      AND date(o.data) BETWEEN date(?) AND date(?)

    ORDER BY o.data DESC
  ''', [idPessoa, inicioStr, fimStr]);

    return result.map((row) {
      return Operacao(
        id: row['id'] as int,
        idProdutoHistorico: row['id_produto_historico'] as int,
        idPessoa: row['id_pessoa'] as int,
        tipo: row['tipo_operacao'] as String,
        quantidade: row['quantidade'] as double,
        preco: row['preco_operacao'] as double,
        desconto: row['desconto'] as double,
        data: row['data_operacao'] as String,
        pago: row['pago'] == 1,
        comentario: row['comentario'] as String?,
        produto: Produto(
          id: row['id_produto_historico'] as int,
          nome: row['nome_produto'] as String,
          medida: row['medida'] as String,
        ),
        pessoa: Pessoa(
          id: row['id_pessoa'] as int,
          nome: row['nome_pessoa'] as String,
          tipo: row['tipo_pessoa'] as String,
          ativo: row['ativo_pessoa'] == 1,
        ),
      );
    }).toList();
  }

  Future<List<Operacao>> getOperacoesByPersonAndDateRange({required int idPessoa, required DateTime dataInicial, required DateTime dataFinal}) async {
    final db = await database;
    final response = await db.query('operacao',
        where: 'id_pessoa = ? AND data BETWEEN ? AND ?', whereArgs: [idPessoa, formatarDataPadraoUs(dataInicial), formatarDataPadraoUs(dataFinal)]);

    var operacoes = <Operacao>[];

    for (var operacao in response) {
      var produtoHistorico = await getProductHistoricoById(operacao['id_produto_historico'] as int);
      var produto = await getProduto(produtoHistorico!.idProduto);
      var pessoa = await getPessoa(operacao['id_pessoa'] as int);

      var novaOperacao = Map<String, dynamic>.from(operacao);

      novaOperacao['produto'] = produto;
      novaOperacao['pessoa'] = pessoa;

      operacoes.add(Operacao.fromMap(novaOperacao));
    }

    return operacoes;
  }

  Future<Operacao> getOperacaoByPersonProductDate({required int idPessoa, required int idProduto, required DateTime data}) async {
    final db = await database;
    final response = await db
        .query('operacao', where: 'id_pessoa = ? AND id_produto_historico = ? AND data = ?', whereArgs: [idPessoa, idProduto, formatarDataPadraoUs(data)]);
    return Operacao.fromMap(response.first);
  }

  Future<List<LinhaOperacaoDto>> getPessoaOperacoesByDateRange({required DateTime dataInicial, required DateTime dataFinal, required Pessoa pessoa}) async {
    final db = await database;

    final produtosPrecosResponse = await getProdutosPrecosByDateRange(dataInicial: dataInicial, dataFinal: dataFinal);

    List<LinhaOperacaoDto> operacoes = [];

    for (var produtoPreco in produtosPrecosResponse.values.first) {
      operacoes.add(LinhaOperacaoDto(
        id: 0,
        produto: Produto(id: produtoPreco.idProduto, nome: produtoPreco.nome, medida: ""),
        pessoa: pessoa,
        quantidade: 0,
        preco: pessoa.tipo == PessoaType.cliente.name ? produtoPreco.precoVenda : produtoPreco.precoCompra,
        desconto: 0,
        total: 0,
        pago: false,
      ));
    }

    final response = await db.rawQuery('''
      SELECT 
        O.id as id,
        O.quantidade as quantidade,
        O.desconto as desconto,
        O.comentario as comentario,
        O.pago as pago,
        PR.id as id_produto,
        PR.nome as nome_produto,
        PR.medida as medida_produto,
        P.nome as nome_pessoa
      FROM operacao AS O
      JOIN produto_historico AS PH ON PH.id = O.id_produto_historico
      JOIN produto AS PR ON PR.id = PH.id_produto
      JOIN pessoa AS P ON P.id = O.id_pessoa
      WHERE O.id_pessoa = ? AND O.data BETWEEN ? AND ?
    ''', [pessoa.id, formatarDataPadraoUs(dataInicial), formatarDataPadraoUs(dataFinal)]);

    for (var operacao in response) {
      final index = operacoes.indexWhere((element) => element.produto.nome == operacao['nome_produto']);
      operacoes[index] = operacoes[index].copyWith(
        id: operacao['id'] as int,
        quantidade: operacao['quantidade'] as double,
        preco: operacoes[index].preco,
        desconto: operacao['desconto'] as double,
        total: operacoes[index].preco * (operacao['quantidade'] as double) - (operacao['desconto'] as double),
        comentario: operacao['comentario'] as String?,
        pago: operacao['pago'] == 1,
      );
    }

    return operacoes;
  }

  Future<List<LinhaOperacaoDto>> getPessoaOperacoes({required DateTime data, required Pessoa pessoa}) async {
    final db = await database;

    final produtosPrecosResponse = await getProdutosPrecos(data);
    final produtosResponse = await getProdutos();

    List<LinhaOperacaoDto> operacoes = [];

    for (var produtoPreco in produtosPrecosResponse) {
      operacoes.add(LinhaOperacaoDto(
        id: 0,
        produto: produtosResponse.firstWhere((element) => element.id == produtoPreco.idProduto),
        pessoa: pessoa,
        quantidade: 0,
        preco: pessoa.tipo == PessoaType.cliente.name ? produtoPreco.precoVenda : produtoPreco.precoCompra,
        desconto: 0,
        total: 0,
        pago: false,
      ));
    }

    final response = await db.rawQuery('''
      SELECT 
        O.id as id,
        O.quantidade as quantidade,
        O.desconto as desconto,
        O.comentario as comentario,
        O.pago as pago,
        PR.id as id_produto,
        PR.nome as nome_produto,
        PR.medida as medida_produto,
        P.nome as nome_pessoa
      FROM operacao AS O
      JOIN produto_historico AS PH ON PH.id = O.id_produto_historico
      JOIN produto AS PR ON PR.id = PH.id_produto
      JOIN pessoa AS P ON P.id = O.id_pessoa
      WHERE O.id_pessoa = ? AND O.data = ?
    ''', [pessoa.id, formatarDataPadraoUs(data)]);

    for (var operacao in response) {
      final index = operacoes.indexWhere((element) => element.produto.nome == operacao['nome_produto']);
      operacoes[index] = operacoes[index].copyWith(
        id: operacao['id'] as int,
        quantidade: operacao['quantidade'] as double,
        preco: operacoes[index].preco,
        desconto: operacao['desconto'] as double,
        total: operacoes[index].preco * (operacao['quantidade'] as double) - (operacao['desconto'] as double),
        comentario: operacao['comentario'] as String?,
        pago: operacao['pago'] == 1,
      );
    }
    return operacoes;
  }

  // Na v2 vamos buscar apenas pelas operacoes que ja existem
  Future<List<LinhaOperacaoDto>> getPessoaOperacoesV2({required DateTime data, required Pessoa pessoa}) async {
    final db = await database;

    final produtosResponse = await getProdutos();
    final produtosPrecosResponse = await getProdutosPrecos(data);

    final response = await db.rawQuery('''
      SELECT 
        O.id as id,
        O.quantidade as quantidade,
        O.desconto as desconto,
        O.comentario as comentario,
        O.pago as pago,
        PR.id as id_produto,
        PR.nome as nome_produto,
        PR.medida as medida_produto,
        P.nome as nome_pessoa
      FROM operacao AS O
      JOIN produto_historico AS PH ON PH.id = O.id_produto_historico
      JOIN produto AS PR ON PR.id = PH.id_produto
      JOIN pessoa AS P ON P.id = O.id_pessoa
      WHERE O.id_pessoa = ? AND O.data = ?
    ''', [pessoa.id, formatarDataPadraoUs(data)]);

    final operacoes = response.map((operacao) {
      final produto = produtosResponse.firstWhere((element) => element.id == operacao['id_produto']);
      final precoProduto = produtosPrecosResponse.firstWhere((element) => element.idProduto == produto.id);
      final preco = pessoa.tipo == PessoaType.cliente.name ? precoProduto.precoVenda : precoProduto.precoCompra;
      return LinhaOperacaoDto(
        id: operacao['id'] as int,
        produto: produto,
        pessoa: pessoa,
        quantidade: operacao['quantidade'] as double,
        preco: preco,
        desconto: operacao['desconto'] as double,
        total: preco * (operacao['quantidade'] as double) - (operacao['desconto'] as double),
        comentario: operacao['comentario'] as String?,
        pago: operacao['pago'] == 1,
      );
    }).toList();

    return operacoes;
  }

  Future<List<Operacao>> getOperacoesByDate({required DateTime data, required String tipo}) async {
    final db = await database;

    const operacaosByDateQuery = '''
      SELECT 
        O.*,
        P.nome as pessoa_nome,
        P.tipo as pessoa_tipo,
        P.ativo as pessoa_ativo,
        PR.id as produto_id,
        PR.nome as produto_nome,
        PR.tipo as produto_medida
      FROM operacao AS O
      JOIN pessoa AS P ON p.id = O.id_pessoa
      JOIN produto_historico AS PH ON ph.id = O.id_produto_historico
      JOIN produto AS PR ON pr.id = ph.id_produto
      WHERE V.data = ? AND P.tipo = ?
    ''';

    List<Map<String, dynamic>> operacaosResponse = await db.rawQuery(operacaosByDateQuery, [formatarDataPadraoUs(data), tipo]);

    return operacaosResponse.map((operacao) {
      final pessoa = Pessoa(id: operacao['id_pessoa'], nome: operacao['pessoa_nome'], tipo: operacao['pessoa_tipo'], ativo: operacao['pessoa_ativo']);
      final produto = Produto(id: operacao['produto_id'], nome: operacao['produto_nome'], medida: operacao['produto_medida']);

      return Operacao(
        id: operacao['id'],
        idProdutoHistorico: operacao['id_produto_historico'],
        idPessoa: operacao['id_pessoa'],
        tipo: operacao['tipo'],
        quantidade: operacao['quantidade'],
        preco: operacao['preco'],
        desconto: operacao['desconto'],
        data: operacao['data'],
        pago: operacao['pago'] == 1,
        pessoa: pessoa,
        produto: produto,
      );
    }).toList();
  }

  Future<Operacao?> getOperacao({required int idProduto, required int idPessoa, required String tipoOperacao, required DateTime data}) async {
    final db = await database;

    final produtoHistorico = await getProdutoHistorico(idProduto: idProduto, tipoProdutoHistorico: tipoOperacao, data: data);

    final response = await db.query('operacao', where: 'id_produto_historico = ? AND id_pessoa = ? AND tipo = ? AND data = ?', whereArgs: [
      produtoHistorico.id,
      idPessoa,
      tipoOperacao,
      formatarDataPadraoUs(data),
    ]);

    if (response.isEmpty) return null;

    return Operacao.fromMap(response.first);
  }

  Future<int> insertOperacao({
    required int idPessoa,
    required int idProduto,
    required String tipoOperacao,
    required double quantidade,
    required DateTime data,
    double desconto = 0,
    String? comentario,
  }) async {
    final db = await database;

    String dataFormatada = formatarDataPadraoUs(data);

    const lastProdutoHistoricoByDateQuery = '''
      SELECT * 
      FROM produto_historico 
      WHERE id_produto = ? AND tipo = ? AND data <= ? ORDER BY data DESC LIMIT 1
    ''';
    List<Map<String, dynamic>> produtoHistoricoResponse = await db.rawQuery(lastProdutoHistoricoByDateQuery, [idProduto, tipoOperacao, dataFormatada]);

    if (produtoHistoricoResponse.isEmpty) {
      throw Exception('Nenhum produto com preço até a data informada');
    }

    final produtoHistorico = ProdutoHistorico.fromMap(produtoHistoricoResponse.first);

    final operacaoResponse = await db.query('operacao', where: 'id_produto_historico = ? AND id_pessoa = ? AND data = ? AND tipo = ?', whereArgs: [
      produtoHistorico.id,
      idPessoa,
      dataFormatada,
      tipoOperacao,
    ]);

    if (operacaoResponse.isNotEmpty) {
      return await db.update(
          'operacao',
          {
            'quantidade': quantidade,
            'desconto': desconto,
            'comentario': comentario,
          },
          where: 'id = ?',
          whereArgs: [operacaoResponse.first['id']]);
    }

    return await db.insert('operacao', {
      'id_produto_historico': produtoHistorico.id,
      'id_pessoa': idPessoa,
      'tipo': tipoOperacao,
      'quantidade': quantidade,
      'preco': produtoHistorico.preco,
      'desconto': desconto,
      'data': dataFormatada,
    });
  }

  Future<int> updateOperacao({required int id, required double quantidade, required double desconto}) async {
    final db = await database;

    // Tem que verficar se o id_produto_historico da operacao é o mais proximo da data informada, pois pode ser que o produto tenha mudado de preço

    return await db.update('operacao', {'quantidade': quantidade, 'desconto': desconto}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateOperacaoQuantidade({required int id, required double quantidade}) async {
    final db = await database;
    return await db.update('operacao', {'quantidade': quantidade}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateOperacaoDesconto({required int id, required double desconto}) async {
    final db = await database;
    return await db.update('operacao', {'desconto': desconto}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateOperacaoPago({required int id, required bool pago}) async {
    final db = await database;
    return await db.update('operacao', {'pago': pago ? 1 : 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteOperacao(int id) async {
    final db = await database;
    return await db.delete('operacao', where: 'id = ?', whereArgs: [id]);
  }
//#endregion
}
