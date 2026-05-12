import 'package:cookbook/views/nova_receita_page.dart';
import 'package:cookbook/views/pesquisa_receitas_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'receita_ver_page.dart';
import 'receita_detalhes_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    const primaryColor = Color(0xFFE67E22);
    const secondaryColor = Color(0xFF34495E);

    final streamCriadas = FirebaseFirestore.instance
        .collection('receitas')
        .where('userId', isEqualTo: user?.uid)
        .snapshots();

    final streamFavoritos = FirebaseFirestore.instance
        .collection('favoritos')
        .where('userId', isEqualTo: user?.uid)
        .snapshots();

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFA),
      appBar: AppBar(
        title: const Text(
          "Meu CookBook",
          style: TextStyle(color: secondaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: primaryColor),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PesquisaReceitasPage(),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<QuerySnapshot>>(
        stream: CombineLatestStream.list([streamCriadas, streamFavoritos]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          final criadas = snapshot.data![0].docs;
          final curtidas = snapshot.data![1].docs;

          return ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              if (criadas.isNotEmpty) ...[
                _buildSectionHeader("Minhas Criações", Icons.auto_stories),
                ...criadas.map(
                  (doc) => _buildRecipeTile(context, doc, isCriada: true),
                ),
              ],
              if (curtidas.isNotEmpty) ...[
                _buildSectionHeader("Receitas Curtidas", Icons.favorite),
                ...curtidas.map(
                  (doc) => _buildRecipeTile(context, doc, isCriada: false),
                ),
              ],
              if (criadas.isEmpty && curtidas.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Text(
                      "Seu livro está vazio!\nComece a adicionar receitas.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        elevation: 4,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NovaReceitaPage()),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFFE67E22)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF34495E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeTile(
    BuildContext context,
    DocumentSnapshot doc, {
    required bool isCriada,
  }) {
    final data = doc.data() as Map<String, dynamic>;
    const primaryColor = Color(0xFFE67E22);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: primaryColor.withOpacity(0.1),
          child: Icon(
            isCriada ? Icons.restaurant : Icons.favorite,
            color: primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          data['nome'] ?? 'Sem nome',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF34495E),
          ),
        ),
        subtitle: Text(data['categoria'] ?? 'Geral'),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          if (isCriada) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ReceitaVerPage(dados: {...data, 'id': doc.id}),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReceitaDetalhesPage(
                  meal: {
                    'idMeal': data['idMeal'] ?? data['id'],
                    'strMeal': data['nome'],
                    'strMealThumb': data['imagem'],
                    'strCategory': data['categoria'],
                    'strArea': data['origem'],
                    'strInstructions': data['instrucoes'] ?? '',
                  },
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
