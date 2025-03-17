import 'package:arnaldo/models/pessoa.dart';
import 'package:arnaldo/models/produto.dart';

class LinhaOperacaoDto {
  final int id;
  final Produto produto;
  final Pessoa pessoa;
  final double quantidade;
  final double preco;
  final double desconto;
  final double total;
  final bool pago;
  final String? comentario;

  LinhaOperacaoDto({
    required this.id,
    required this.produto,
    required this.pessoa,
    required this.quantidade,
    required this.preco,
    required this.desconto,
    required this.total,
    required this.pago,
    this.comentario,
  });

  factory LinhaOperacaoDto.fromMap(Map<String, dynamic> map) {
    return LinhaOperacaoDto(
      id: map['id'],
      produto: Produto(id: map['id_produto'], nome: map['nome_produto'], medida: map['medida_produto']),
      pessoa: Pessoa(id: map['id_pessoa'], nome: map['nome_pessoa'], tipo: map['tipo_pessoa'], ativo: map['ativo_pessoa']),
      quantidade: map['quantidade'],
      preco: map['preco'],
      desconto: map['desconto'],
      total: map['total'],
      comentario: map['comentario'],
      pago: map['pago'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_produto': produto.id,
      'nome_produto': produto.nome,
      'medida_produto': produto.medida,
      'id_pessoa': pessoa.id,
      'nome_pessoa': pessoa.nome,
      'tipo_pessoa': pessoa.tipo,
      'ativo_pessoa': pessoa.ativo,
      'quantidade': quantidade,
      'preco': preco,
      'desconto': desconto,
      'total': total,
      'comentario': comentario,
      'pago': pago ? 1 : 0,
    };
  }

  LinhaOperacaoDto copyWith({
    int? id,
    Produto? produto,
    Pessoa? pessoa,
    double? quantidade,
    double? preco,
    double? desconto,
    double? total,
    String? comentario,
    bool? pago,
  }) {
    return LinhaOperacaoDto(
      id: id ?? this.id,
      produto: produto ?? this.produto,
      pessoa: pessoa ?? this.pessoa,
      quantidade: quantidade ?? this.quantidade,
      preco: preco ?? this.preco,
      desconto: desconto ?? this.desconto,
      total: total ?? this.total,
      comentario: comentario ?? this.comentario,
      pago: pago ?? this.pago,
    );
  }
}
