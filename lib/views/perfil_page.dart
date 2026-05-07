import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final user = FirebaseAuth.instance.currentUser;
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  bool _editando = false;

  // Função para Atualizar Dados
  void _atualizarPerfil() async {
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user!.uid)
          .update({
            'nome': _nomeController.text,
            'telefone': _telefoneController.text,
          });

      setState(() => _editando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Perfil atualizado!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Feedback em caso de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao atualizar: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meu Perfil")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user?.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Usuário não encontrado."));
          }

          var dados = snapshot.data!.data() as Map<String, dynamic>;

          if (!_editando) {
            _nomeController.text = dados['nome'] ?? '';
            _telefoneController.text = dados['telefone'] ?? '';
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
                const SizedBox(height: 20),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Divider(),

                TextField(
                  controller: _nomeController,
                  enabled: _editando,
                  decoration: const InputDecoration(labelText: "Nome"),
                ),
                TextField(
                  controller: _telefoneController,
                  enabled: _editando,
                  decoration: const InputDecoration(labelText: "Telefone"),
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 30),
                _editando
                    ? ElevatedButton(
                        onPressed: _atualizarPerfil,
                        child: const Text("Salvar Alterações"),
                      )
                    : ElevatedButton(
                        onPressed: () => setState(() => _editando = true),
                        child: const Text("Editar Perfil"),
                      ),

                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  child: const Text(
                    "Sair da Conta",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
