import 'dart:io';

import 'package:arnaldo/core/database/database_ddl.dart';
import 'package:arnaldo/core/database/database_seed.dart';
import 'package:arnaldo/core/enums/produto_historico_type.dart';
import 'package:arnaldo/core/utils.dart';
import 'package:arnaldo/models/Dtos/linha_produto_dto.dart';
import 'package:arnaldo/models/operacao.dart';
import 'package:arnaldo/models/pessoa.dart';
import 'package:arnaldo/models/produto.dart';
import 'package:arnaldo/models/produto_historico.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String _databaseName = 'arnaldo.db';
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<String> getDatabasePath() async {
    final directory = await getDatabasesPath();
    String path = join(directory, _databaseName);
    return path;
  }

  Future<void> copyDatabase() async {
    final dbPath = await getDatabasePath();
    final file = File(dbPath);
    final directory = await getApplicationDocumentsDirectory();
    final newPath = '${directory.path}/arnaldo/arnaldo_backup.db';
    await file.copy(newPath);
  }

  Future<void> shareDatabase(String filePath) async {
    await Share.shareXFiles([XFile(filePath)]);
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

    // await db.execute('''
    // INSERT INTO produto_historico (id_produto, tipo, preco, data)
    // SELECT id, 'compra' , 50.0, '2024-09-06' FROM produto;
    // ''');
    //
    // await db.execute('''
    // INSERT INTO produto_historico (id_produto, tipo, preco, data)
    // SELECT id, 'venda' , 100.0, '2024-09-06' FROM produto;
    // ''');
  }

  Future<void> _onCreate(Database db, int version) async {
    await databaseDdl(db, version);
    await databaseSeed(db, version);
  }

  /// Pessoa
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
    return await db.delete('pessoa', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> togglePessoa(int id, bool ativo) async {
    final db = await database;
    return await db.update('pessoa', {'ativo': ativo ? 1 : 0}, where: 'id = ?', whereArgs: [id]);
  }

  /// Produto
  Future<Produto> getProduto(int id) async {
    final db = await database;
    final response = await db.query('produto', where: 'id = ?', whereArgs: [id]);
    return Produto.fromMap(response.first);
  }

  Future<List<Produto>> getProdutos() async {
    final db = await database;
    final response = await db.query('produto');
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

  /// Produto Historico

  /// Campos
  Future<List<LinhaProdutoDto>> getProdutosPrecos(DateTime dataSelecionada) async {
    final db = await database;

    const produtosPrecosQuery = '''
      SELECT 
        PR.nome,
        PH.id as id_produto_historico,
        PH.preco,
        PH.tipo
      FROM produto_historico AS PH
      JOIN produto AS PR ON PR.id = PH.id_produto
      WHERE PH.data = (SELECT MAX(data) FROM produto_historico WHERE data <= ? AND id_produto = PH.id_produto)
      GROUP BY PR.nome, PH.tipo
    ''';

    List<Map<String, dynamic>> produtosPrecosResponse = await db.rawQuery(produtosPrecosQuery, [formatarDataPadraoUs(dataSelecionada)]);

    Map<String,LinhaProdutoDto> produtosPrecos = {};



    for (var produtoHistorico in produtosPrecosResponse) {
      produtosPrecos[produtoHistorico['nome']] = LinhaProdutoDto(
        nome: produtoHistorico['nome'],
        idCompra: 0,
        idVenda: 0,
        precoCompra: 0,
        precoVenda: 0,
        tipo: ProdutoHistoricoType.values.firstWhere((e) => e.name == produtoHistorico['tipo']),
      );
    }

    for (var produtoHistorico in produtosPrecosResponse) {
      if (produtoHistorico['tipo'] == ProdutoHistoricoType.compra.name) {
        produtosPrecos[produtoHistorico['nome']]!.idCompra = produtoHistorico['id_produto_historico'];
        produtosPrecos[produtoHistorico['nome']]!.precoCompra = produtoHistorico['preco'];
      } else if  (produtoHistorico['tipo'] == ProdutoHistoricoType.venda.name) {
        produtosPrecos[produtoHistorico['nome']]!.idVenda = produtoHistorico['id_produto_historico'];
        produtosPrecos[produtoHistorico['nome']]!.precoVenda = produtoHistorico['preco'];
      }
    }

    return produtosPrecos.values.toList();
  }

  Future<ProdutoHistorico> getProdutoHistorico({required int idProduto, DateTime? data}) async {
    final db = await database;

    var query = 'SELECT * FROM produto_historico WHERE id_produto = ?';
    if (data != null) query += ' AND data <= ?';
    query += ' ORDER BY data DESC, id DESC LIMIT 1';

    final response = await db.rawQuery(query, data != null ? [idProduto, formatarDataPadraoUs(data)] : [idProduto]);

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

  Future<int> deleteProdutoHistorico(int id) async {
    final db = await database;
    return await db.delete('produto_historico', where: 'id = ?', whereArgs: [id]);
  }

  /// Operacao
  Future<List<Operacao>> getOperacoesByDate({required DateTime data, required String tipo}) async {
    final db = await database;

    const operacaosByDateQuery = '''
      SELECT 
        O.*,
        P.nome as pessoa_nome,
        P.tipo as pessoa_tipo,
        P.ativo as pessoa_ativo,
        Pr.id as produto_id,
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
        pessoa: pessoa,
        produto: produto,
      );
    }).toList();
  }

  Future<int> insertOperacao({
    required int idPessoa,
    required int idProduto,
    required String tipoOperacao,
    required double quantidade,
    required DateTime data,
    double desconto = 0,
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

  Future<int> updateOperacao(int id, double quantidade) async {
    final db = await database;
    return await db.update('operacao', {'quantidade': quantidade}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateOperacaoDesconto(int id, double desconto) async {
    final db = await database;
    return await db.update('operacao', {'desconto': desconto}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteOperacao(int id) async {
    final db = await database;
    return await db.delete('operacao', where: 'id = ?', whereArgs: [id]);
  }
}
