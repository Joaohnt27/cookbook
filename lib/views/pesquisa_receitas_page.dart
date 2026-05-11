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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pesquisar no meu CookBook"),
        actions: [
          IconButton(
            icon: Icon(_ordemAZ ? Icons.sort_by_alpha : Icons.schedule),
            onPressed: () {
              setState(() => _ordemAZ = !_ordemAZ);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _ordemAZ ? "Ordenando de A-Z" : "Ordenando por Data",
                  ),
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
              decoration: InputDecoration(
                labelText: "O que você procura?",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() => _query = value.toLowerCase());
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('receitas')
                  .where('userId', isEqualTo: user?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

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
                  return const Center(
                    child: Text("Nenhuma receita encontrada."),
                  );
                }

                return ListView.builder(
                  itemCount: receitas.length,
                  itemBuilder: (context, index) {
                    final r = receitas[index];
                    return ListTile(
                      leading: const Icon(Icons.book, color: Colors.orange),
                      title: Text(r.nome),
                      subtitle: Text(r.categoria),
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
