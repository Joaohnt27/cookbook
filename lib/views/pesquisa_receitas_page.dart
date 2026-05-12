import 'package:cookbook/views/nova_receita_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/receita_model.dart';

class PesquisaReceitasPage extends StatefulWidget {
  const PesquisaReceitasPage({super.key});

  @override
  State<PesquisaReceitasPage> createState() => _PesquisaReceitasPageState();
}

class _PesquisaReceitasPageState extends State<PesquisaReceitasPage> {
  String _query = "";
  bool _ordemAZ = true;
  final user = FirebaseAuth.instance.currentUser;

  final Color _primaryColor = const Color(0xFFE67E22);
  final Color _secondaryColor = const Color(0xFF34495E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: _primaryColor),
        title: Text(
          "Pesquisar Receitas",
          style: TextStyle(color: _secondaryColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: _ordemAZ
                ? "Mudar para Ordenação por Data"
                : "Mudar para Ordem Alfabética",
            icon: Icon(
              _ordemAZ ? Icons.sort_by_alpha : Icons.calendar_today_outlined,
            ),
            onPressed: () {
              setState(() => _ordemAZ = !_ordemAZ);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _ordemAZ ? "Ordenando de A-Z" : "Ordenando por Data",
                  ),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) =>
                  setState(() => _query = value.toLowerCase()),
              decoration: InputDecoration(
                labelText: "Qual ingrediente ou prato busca?",
                labelStyle: TextStyle(color: _secondaryColor),
                prefixIcon: Icon(Icons.search, color: _primaryColor),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: _primaryColor, width: 2),
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('receitas')
                  .where('userId', isEqualTo: user?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return const Center(child: Text("Erro ao carregar dados"));
                if (!snapshot.hasData)
                  return Center(
                    child: CircularProgressIndicator(color: _primaryColor),
                  );

                List<Receita> receitas = snapshot.data!.docs
                    .map((doc) => Receita.fromFirestore(doc))
                    .where((r) => r.nome.toLowerCase().contains(_query))
                    .toList();

                if (_ordemAZ) {
                  receitas.sort((a, b) => a.nome.compareTo(b.nome));
                } else {
                  receitas.sort((a, b) => b.id.compareTo(a.id));
                }

                if (receitas.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 60,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Nenhuma receita encontrada.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: receitas.length,
                  itemBuilder: (context, index) {
                    final r = receitas[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 1,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _primaryColor.withOpacity(0.1),
                          child: Icon(
                            Icons.restaurant,
                            color: _primaryColor,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          r.nome,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _secondaryColor,
                          ),
                        ),
                        subtitle: Text(
                          "${r.categoria} • ${r.tempoPreparo} min",
                        ),
                        trailing: const Icon(
                          Icons.edit_outlined,
                          color: Colors.grey,
                          size: 20,
                        ),

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NovaReceitaPage(receitaParaEdicao: r),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
