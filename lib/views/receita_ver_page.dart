import 'package:flutter/material.dart';
import 'nova_receita_page.dart';
import '../models/receita_model.dart';

class ReceitaVerPage extends StatelessWidget {
  final Map<String, dynamic> dados;
  const ReceitaVerPage({super.key, required this.dados});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFE67E22);

    return Scaffold(
      appBar: AppBar(
        title: Text(dados['nome']),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: primaryColor),
            onPressed: () {
              final receita = Receita(
                id: dados['id'],
                nome: dados['nome'],
                categoria: dados['categoria'],
                tempoPreparo: dados['tempoPreparo'] ?? 0,
                ingredientes: dados['ingredientes'],
                modoPreparo: dados['modoPreparo'],
                userId: dados['userId'],
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      NovaReceitaPage(receitaParaEdicao: receita),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection("Ingredientes", dados['ingredientes']),
            const Divider(height: 40),
            _buildInfoSection("Modo de Preparo", dados['modoPreparo']),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String? content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF34495E),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          content ?? "Não informado",
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ],
    );
  }
}
