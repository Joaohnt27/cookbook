import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _authService = AuthService();
  bool _carregando = false;

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFFE67E22)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFE67E22), width: 2),
      ),
    );
  }

  void _registrar() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _carregando = true);

      String? erro = await _authService.registrar(
        email: _emailController.text,
        password: _senhaController.text,
        nome: _nomeController.text,
        telefone: _telefoneController.text,
      );

      setState(() => _carregando = false);

      if (erro == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Chef cadastrado com sucesso!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(erro),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFA),
      appBar: AppBar(
        title: const Text(
          "Criar sua Conta",
          style: TextStyle(color: Color(0xFF34495E)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFE67E22)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(
                  Icons.assignment_ind_outlined,
                  size: 80,
                  color: Color(0xFFE67E22),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Junte-se ao CookBook",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF34495E),
                  ),
                ),
                const SizedBox(height: 30),

                TextFormField(
                  controller: _nomeController,
                  decoration: _inputStyle(
                    "Nome Completo",
                    Icons.person_outline,
                  ),
                  validator: (val) => val!.isEmpty ? "Informe seu nome" : null,
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: _telefoneController,
                  decoration: _inputStyle(
                    "Telefone",
                    Icons.phone_android_outlined,
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (val) =>
                      val!.isEmpty ? "Informe seu telefone" : null,
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: _emailController,
                  decoration: _inputStyle("E-mail", Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) =>
                      val!.contains("@") ? null : "E-mail inválido",
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: _senhaController,
                  decoration: _inputStyle("Senha Segura", Icons.lock_outline),
                  obscureText: true,
                  validator: (val) {
                    if (val!.length < 6) return "Mínimo 6 caracteres";
                    if (!val.contains(RegExp(r'[A-Z]')))
                      return "Deve conter letra maiúscula";
                    return null;
                  },
                ),
                const SizedBox(height: 35),

                _carregando
                    ? const CircularProgressIndicator(color: Color(0xFFE67E22))
                    : ElevatedButton(
                        onPressed: _registrar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE67E22),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          "COMEÇAR A COZINHAR",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
