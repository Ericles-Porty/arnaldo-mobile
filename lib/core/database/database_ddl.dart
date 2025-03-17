import 'package:sqflite/sqflite.dart';

Future<void> databaseDdl(Database db, int version) async {
  // Produto
  // Medida: kg, saco
  await db.execute('''
      CREATE TABLE produto(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        medida TEXT CHECK(medida IN ('kg', 'saco'))
      )
    ''');

  // Pessoa
  // Tipo: cliente, fornecedor
  await db.execute('''
      CREATE TABLE pessoa(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        tipo TEXT CHECK(tipo IN ('cliente', 'fornecedor')),
        ativo INTEGER DEFAULT 1
      )
    ''');

  // Produto histórico
  // Tipo: compra, venda
  await db.execute('''
      CREATE TABLE produto_historico(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_produto INTEGER,
        preco REAL,
        tipo TEXT CHECK(tipo IN ('compra', 'venda')),
        data TEXT,
        FOREIGN KEY (id_produto) REFERENCES produto (id) ON DELETE CASCADE
      )
    ''');

  // Operacao
  // Tipo: compra, venda
  await db.execute('''
      CREATE TABLE operacao(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_produto_historico INTEGER,
        id_pessoa INTEGER,
        quantidade REAL,
        preco REAL,
        data TEXT,   
        tipo TEXT CHECK(tipo IN ('compra', 'venda')),
        desconto REAL DEFAULT 0,
        pago INTEGER DEFAULT 0,
        comentario TEXT,
        FOREIGN KEY (id_produto_historico) REFERENCES produto_historico (id),
        FOREIGN KEY (id_pessoa) REFERENCES pessoa (id) ON DELETE CASCADE
      )
    ''');

  //Indíces
  await db.execute('CREATE INDEX index_pessoa_tipo ON pessoa (tipo);');
  await db.execute('CREATE INDEX index_produto_historico_id_produto_e_data ON produto_historico (id_produto, data);');
  await db.execute('CREATE INDEX index_operacao_id_pessoa_e_data ON operacao (id_pessoa, data);');
}
