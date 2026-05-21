import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/telefone_input_formatter.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final user = FirebaseAuth.instance.currentUser;
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _cidadeController = TextEditingController();
  bool _editando = false;

  final Color _primaryColor = const Color(0xFFE67E22);
  final Color _secondaryColor = const Color(0xFF34495E);

  void _atualizarPerfil() async {
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user!.uid)
          .update({
            'nome': _nomeController.text,
            'telefone': _telefoneController.text,
            'cidade': _cidadeController.text,
          });

      setState(() => _editando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Perfil atualizado com sucesso!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao atualizar: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _mostrarSobre() {
    showAboutDialog(
      context: context,
      applicationName: "CookBook",
      applicationVersion: "2.0.26",
      applicationIcon: Icon(
        Icons.restaurant_menu,
        color: _primaryColor,
        size: 40,
      ),
      children: [
        const Text("Especificações do Projeto:"),
        const SizedBox(height: 10),
        const Text("• Autenticação e Registro via Firebase (RF001/RF002)"),
        const Text("• Inserção em 4 coleções Firestore (RF003)"),
        const Text("• Atualização e Recuperação em Tempo Real (RF004/RF005)"),
        const Text("• Pesquisa Case-Insensitive e Ordenação (RF006)"),
        const Text("• Consumo de API REST externa (RF007)"),
        const SizedBox(height: 10),
        const Text("Desenvolvido para Avaliação Final de Flutter."),
      ],
    );
  }

  void _confirmarSaida(BuildContext context) {
    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog(
        title: const Text("Sair da conta?"),
        content: const Text(
          "Tem certeza que deseja fechar seu livro de receitas agora?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(innerContext),
            child: const Text("CANCELAR"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              if (context.mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login_page', (route) => false);
              }
            },
            child: const Text("SAIR", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _primaryColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      enabled: _editando,
      filled: !_editando,
      fillColor: _editando ? Colors.transparent : Colors.grey[100],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFA),
      appBar: AppBar(
        title: Text(
          "Meu Perfil",
          style: TextStyle(color: _secondaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: _primaryColor),
            onPressed: _mostrarSobre,
          ),
        ],
      ),
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
            _cidadeController.text = dados['cidade'] ?? '';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: _primaryColor.withValues(alpha: 0.1),
                      child: Icon(Icons.person, size: 70, color: _primaryColor),
                    ),
                    if (!_editando)
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: _secondaryColor,
                        child: IconButton(
                          icon: const Icon(
                            Icons.edit,
                            size: 18,
                            color: Colors.white,
                          ),
                          onPressed: () => setState(() => _editando = true),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    color: _secondaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _nomeController,
                  decoration: _inputStyle("Nome", Icons.badge_outlined),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _telefoneController,
                  decoration: _inputStyle(
                    "Telefone",
                    Icons.phone_android_outlined,
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [TelefoneInputFormatter()],
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _cidadeController,
                  decoration: _inputStyle("Cidade", Icons.location_city),
                ),
                const SizedBox(height: 40),
                if (_editando)
                  ElevatedButton(
                    onPressed: _atualizarPerfil,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "SALVAR ALTERAÇÕES",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(height: 15),
                TextButton.icon(
                  onPressed: () => _confirmarSaida(context),
                  icon: const Icon(Icons.exit_to_app, color: Colors.red),
                  label: const Text(
                    "Sair da Conta",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
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
