import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/receita_model.dart';

class NovaReceitaPage extends StatefulWidget {
  final Receita? receitaParaEdicao;

  const NovaReceitaPage({super.key, this.receitaParaEdicao});

  @override
  State<NovaReceitaPage> createState() => _NovaReceitaPageState();
}

class _NovaReceitaPageState extends State<NovaReceitaPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _ingredientesController;
  late TextEditingController _preparoController;
  late TextEditingController _tempoController;
  String _categoriaSelecionada = 'Almoço';
  bool _carregando = false;

  final Color _primaryColor = const Color(0xFFE67E22);
  final Color _secondaryColor = const Color(0xFF34495E);

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(
      text: widget.receitaParaEdicao?.nome ?? "",
    );
    _ingredientesController = TextEditingController(
      text: widget.receitaParaEdicao?.ingredientes ?? "",
    );
    _preparoController = TextEditingController(
      text: widget.receitaParaEdicao?.modoPreparo ?? "",
    );
    _tempoController = TextEditingController(
      text: widget.receitaParaEdicao != null
          ? widget.receitaParaEdicao!.tempoPreparo.toString()
          : "",
    );

    if (widget.receitaParaEdicao != null) {
      _categoriaSelecionada = widget.receitaParaEdicao!.categoria;
    }
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _primaryColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: _primaryColor, width: 2),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _ingredientesController.dispose();
    _preparoController.dispose();
    _tempoController.dispose();
    super.dispose();
  }

  void _processarDados() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _carregando = true);

      try {
        final user = FirebaseAuth.instance.currentUser;
        final Map<String, dynamic> dadosReceita = {
          'nome': _nomeController.text,
          'ingredientes': _ingredientesController.text,
          'modoPreparo': _preparoController.text,
          'tempoPreparo': int.parse(_tempoController.text),
          'categoria': _categoriaSelecionada,
          'userId': user?.uid,
          'ultimaAtualizacao': FieldValue.serverTimestamp(),
        };

        if (widget.receitaParaEdicao == null) {
          await FirebaseFirestore.instance
              .collection('receitas')
              .add(dadosReceita);
        } else {
          await FirebaseFirestore.instance
              .collection('receitas')
              .doc(widget.receitaParaEdicao!.id)
              .update(dadosReceita);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.receitaParaEdicao == null
                    ? "Sua nova receita foi salva! 👨‍🍳"
                    : "Receita atualizada com sucesso!",
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao processar: $e"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        if (mounted) setState(() => _carregando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String titulo = widget.receitaParaEdicao == null
        ? "Nova Receita"
        : "Editar Receita";

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFA),
      appBar: AppBar(
        title: Text(
          titulo,
          style: TextStyle(color: _secondaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: _primaryColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: _inputStyle(
                  "Nome da Receita",
                  Icons.restaurant_menu,
                ),
                validator: (val) => val!.isEmpty ? "Informe o nome" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _ingredientesController,
                maxLines: 3,
                decoration: _inputStyle("Ingredientes", Icons.list_alt),
                validator: (val) =>
                    val!.isEmpty ? "Informe os ingredientes" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _preparoController,
                maxLines: 4,
                decoration: _inputStyle(
                  "Modo de Preparo",
                  Icons.description_outlined,
                ),
                validator: (val) => val!.isEmpty ? "Informe o preparo" : null,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tempoController,
                      decoration: _inputStyle(
                        "Tempo (min)",
                        Icons.timer_outlined,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (val) => val!.isEmpty ? "Obrigatório" : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _categoriaSelecionada,
                      decoration: InputDecoration(
                        labelText: "Categoria",
                        prefixIcon: Icon(
                          Icons.category_outlined,
                          color: _primaryColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      items: ['Almoço', 'Jantar', 'Sobremesa', 'Lanche']
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c, overflow: TextOverflow.ellipsis),
                            ),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _categoriaSelecionada = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              _carregando
                  ? CircularProgressIndicator(color: _primaryColor)
                  : ElevatedButton(
                      onPressed: _processarDados,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        widget.receitaParaEdicao == null
                            ? "SALVAR RECEITA"
                            : "ATUALIZAR RECEITA",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
