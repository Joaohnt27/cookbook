import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SecaoAvaliacao extends StatefulWidget {
  final String receitaId;
  const SecaoAvaliacao({super.key, required this.receitaId});

  @override
  State<SecaoAvaliacao> createState() => _SecaoAvaliacaoState();
}

class _SecaoAvaliacaoState extends State<SecaoAvaliacao> {
  final _comentarioController = TextEditingController();
  double _nota = 5;
  final user = FirebaseAuth.instance.currentUser;

  void _enviarAvaliacao(String? avaliacaoId) async {
    final dados = {
      'nota': _nota,
      'comentario': _comentarioController.text,
      'data': FieldValue.serverTimestamp(),
      'userId': user?.uid,
      'userName': user?.displayName ?? "Usuário",
      'receitaId': widget.receitaId,
    };

    try {
      if (avaliacaoId == null) {
        await FirebaseFirestore.instance.collection('avaliacoes').add(dados);
      } else {
        await FirebaseFirestore.instance
            .collection('avaliacoes')
            .doc(avaliacaoId)
            .update(dados);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Avaliação salva!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Avalie esta receita",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Slider(
          value: _nota,
          min: 1,
          max: 5,
          divisions: 4,
          label: _nota.toString(),
          onChanged: (v) => setState(() => _nota = v),
        ),
        TextField(
          controller: _comentarioController,
          decoration: const InputDecoration(
            labelText: "Seu comentário",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _enviarAvaliacao(null),
          child: const Text("Enviar Avaliação"),
        ),
        const Divider(),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('avaliacoes')
              .where('receitaId', isEqualTo: widget.receitaId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LinearProgressIndicator();
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                return ListTile(
                  title: Text("${doc['nota']} estrelas - ${doc['userName']}"),
                  subtitle: Text(doc['comentario']),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
