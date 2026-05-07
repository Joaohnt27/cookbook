import 'package:cloud_firestore/cloud_firestore.dart';

class Receita {
  String id;
  String nome;
  String ingredientes;
  String modoPreparo;
  int tempoPreparo;
  String categoria;
  String userId;

  Receita({
    required this.id,
    required this.nome,
    required this.ingredientes,
    required this.modoPreparo,
    required this.tempoPreparo,
    required this.categoria,
    required this.userId,
  });

  // Converte DocumentSnapshot do Firestore para o objeto Receita
  factory Receita.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Receita(
      id: doc.id,
      nome: data['nome'] ?? '',
      ingredientes: data['ingredientes'] ?? '',
      modoPreparo: data['modoPreparo'] ?? '',
      tempoPreparo: data['tempoPreparo'] ?? 0,
      categoria: data['categoria'] ?? 'Geral',
      userId: data['userId'] ?? '',
    );
  }

  // Converte objeto Receita para Map (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'ingredientes': ingredientes,
      'modoPreparo': modoPreparo,
      'tempoPreparo': tempoPreparo,
      'categoria': categoria,
      'userId': userId,
    };
  }
}
