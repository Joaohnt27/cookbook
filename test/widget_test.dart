import 'package:cookbook/models/receita_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Receita.toMap serializa os campos principais', () {
    final ultimaAtualizacao = DateTime(2026, 5, 21);
    final receita = Receita(
      id: 'receita-1',
      nome: 'Bolo de cenoura',
      ingredientes: 'cenoura, ovos, farinha',
      modoPreparo: 'Misture tudo e asse.',
      tempoPreparo: 45,
      categoria: 'Sobremesa',
      userId: 'usuario-1',
      ultimaAtualizacao: ultimaAtualizacao,
    );

    expect(receita.toMap(), {
      'nome': 'Bolo de cenoura',
      'ingredientes': 'cenoura, ovos, farinha',
      'modoPreparo': 'Misture tudo e asse.',
      'tempoPreparo': 45,
      'categoria': 'Sobremesa',
      'userId': 'usuario-1',
      'ultimaAtualizacao': ultimaAtualizacao,
    });
  });
}
