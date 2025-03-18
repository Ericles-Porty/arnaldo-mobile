import 'package:arnaldo/models/pessoa.dart';
import 'package:arnaldo/models/produto.dart';

class Operacao {
  final int id;
  final int idProdutoHistorico;
  final int idPessoa;
  final String tipo;
  final double quantidade;
  final double preco;
  final double desconto;
  final String data;
  final bool pago;
  final String? comentario;
  final Pessoa? pessoa;
  final Produto? produto;

  Operacao(
      {required this.id,
      required this.idProdutoHistorico,
      required this.idPessoa,
      required this.tipo,
      required this.quantidade,
      required this.preco,
      required this.desconto,
      required this.data,
      required this.pago,
      this.comentario,
      this.pessoa,
      this.produto});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_produto_historico': idProdutoHistorico,
      'id_pessoa': idPessoa,
      'tipo': tipo,
      'quantidade': quantidade,
      'preco': preco,
      'desconto': desconto,
      'data': data,
      'pago': pago ? 1 : 0,
      'comentario': comentario,
    };
  }

  factory Operacao.fromMap(Map<String, dynamic> map) {
    return Operacao(
      id: map['id'],
      idProdutoHistorico: map['id_produto_historico'],
      idPessoa: map['id_pessoa'],
      tipo: map['tipo'],
      quantidade: map['quantidade'],
      preco: map['preco'],
      desconto: map['desconto'],
      data: map['data'],
      pago: map['pago'] == 1,
      comentario: map['comentario'],
      pessoa: map['pessoa'],
      produto: map['produto'],
    );
  }

  Operacao copyWith({
    int? id,
    int? idProdutoHistorico,
    int? idPessoa,
    String? tipo,
    double? quantidade,
    double? preco,
    double? desconto,
    String? data,
    bool? pago,
    String? comentario,
    Pessoa? pessoa,
    Produto? produto,
  }) {
    return Operacao(
      id: id ?? this.id,
      idProdutoHistorico: idProdutoHistorico ?? this.idProdutoHistorico,
      idPessoa: idPessoa ?? this.idPessoa,
      tipo: tipo ?? this.tipo,
      quantidade: quantidade ?? this.quantidade,
      preco: preco ?? this.preco,
      desconto: desconto ?? this.desconto,
      data: data ?? this.data,
      pago: pago ?? this.pago,
      comentario: comentario ?? this.comentario,
      pessoa: pessoa ?? this.pessoa,
      produto: produto ?? this.produto,
    );
  }
}
