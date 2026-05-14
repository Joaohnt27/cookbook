import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'nova_receita_page.dart';
import '../models/receita_model.dart';

class ReceitaVerPage extends StatelessWidget {
  final Map<String, dynamic> dados;
  const ReceitaVerPage({super.key, required this.dados});

  void _confirmarExclusao(BuildContext context) {
    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog(
        title: const Text("Excluir Receita?"),
        content: const Text(
          "Tem certeza que deseja apagar esta receita permanentemente do seu livro?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(innerContext),
            child: const Text("CANCELAR"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('receitas')
                    .doc(dados['id'])
                    .delete();

                if (context.mounted) {
                  Navigator.pop(innerContext); // Fecha o modal
                  Navigator.pop(context); // Volta para a HomePage
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Receita excluída com sucesso!"),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Erro ao excluir: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text("EXCLUIR", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFE67E22);
    const secondaryColor = Color(0xFF34495E);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFA),
      appBar: AppBar(
        title: Text(
          dados['nome'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _confirmarExclusao(context),
          ),
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection(
              "Ingredientes",
              dados['ingredientes'],
              secondaryColor,
            ),
            const Divider(height: 40),
            _buildInfoSection(
              "Modo de Preparo",
              dados['modoPreparo'],
              secondaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String? content, Color titleColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content ?? "Não informado",
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
