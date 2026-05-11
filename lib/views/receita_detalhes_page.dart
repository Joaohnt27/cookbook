import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReceitaDetalhesPage extends StatefulWidget {
  final dynamic meal;

  const ReceitaDetalhesPage({super.key, required this.meal});

  @override
  State<ReceitaDetalhesPage> createState() => _ReceitaDetalhesPageState();
}

class _ReceitaDetalhesPageState extends State<ReceitaDetalhesPage> {
  final translator = GoogleTranslator();

  String _nome = "";
  String _categoria = "";
  String _origem = "";
  String _instrucoes = "Traduzindo conteúdo...";
  bool _estaTraduzindo = true;

  @override
  void initState() {
    super.initState();
    _traduzirTudo();
  }

  Future<void> _traduzirTudo() async {
    try {
      var tradNome = await translator.translate(
        widget.meal['strMeal'],
        from: 'en',
        to: 'pt',
      );
      var tradCat = await translator.translate(
        widget.meal['strCategory'],
        from: 'en',
        to: 'pt',
      );
      var tradArea = await translator.translate(
        widget.meal['strArea'],
        from: 'en',
        to: 'pt',
      );
      var tradInst = await translator.translate(
        widget.meal['strInstructions'],
        from: 'en',
        to: 'pt',
      );

      if (mounted) {
        setState(() {
          _nome = tradNome.text;
          _categoria = tradCat.text;
          _origem = tradArea.text;
          _instrucoes = tradInst.text;
          _estaTraduzindo = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _nome = widget.meal['strMeal'];
          _categoria = widget.meal['strCategory'];
          _origem = widget.meal['strArea'];
          _instrucoes = widget.meal['strInstructions'];
          _estaTraduzindo = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String receitaId =
        widget.meal['idMeal']?.toString() ??
        widget.meal['id']?.toString() ??
        'temp_id';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _estaTraduzindo ? "Carregando..." : _nome,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(widget.meal['strMealThumb'], fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Chip(
                          avatar: const Icon(Icons.restaurant, size: 16),
                          label: Text(_estaTraduzindo ? "..." : _categoria),
                        ),
                        Chip(
                          avatar: const Icon(Icons.public, size: 16),
                          label: Text(_estaTraduzindo ? "..." : _origem),
                          backgroundColor: Colors.orange[100],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Icon(Icons.description, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          "Modo de Preparo",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    _estaTraduzindo
                        ? const Center(child: CircularProgressIndicator())
                        : Text(
                            _instrucoes,
                            textAlign: TextAlign.justify,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                          ),

                    const Divider(height: 50, thickness: 2),

                    SecaoAvaliacao(receitaId: receitaId),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.orange[700],
        onPressed: () async {
          final user = FirebaseAuth.instance.currentUser;
          try {
            await FirebaseFirestore.instance.collection('favoritos').add({
              'nome': _nome,
              'imagem': widget.meal['strMealThumb'],
              'categoria': _categoria,
              'origem': _origem,
              'userId': user?.uid,
              'data_favorito': FieldValue.serverTimestamp(),
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Salvo nos favoritos!"),
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Erro ao salvar: $e"),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        label: const Text(
          "SALVAR RECEITA",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.favorite),
      ),
    );
  }
}

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

  void _enviarAvaliacao() async {
    if (_comentarioController.text.isEmpty) return;

    try {
      final user = FirebaseAuth.instance.currentUser;

      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user?.uid)
          .get();

      final dadosUsuario = userDoc.data() as Map<String, dynamic>?;

      final nomeReal = dadosUsuario != null
          ? dadosUsuario['nome']
          : "Cozinheiro";

      final dadosParaSalvar = {
        'nota': _nota,
        'comentario': _comentarioController.text,
        'data': FieldValue.serverTimestamp(),
        'userId': user?.uid,
        'userName': nomeReal,
        'receitaId': widget.receitaId,
      };

      await FirebaseFirestore.instance
          .collection('avaliacoes')
          .add(dadosParaSalvar);

      _comentarioController.clear();
      setState(() => _nota = 5);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Avaliação enviada!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Erro detalhado: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao enviar: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Avaliações e Comentários",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(5, (index) {
            return IconButton(
              onPressed: () => setState(() => _nota = index + 1.0),
              icon: Icon(
                index < _nota ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 32,
              ),
            );
          }),
        ),
        TextField(
          controller: _comentarioController,
          decoration: const InputDecoration(
            labelText: "Escreva sua opinião...",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _enviarAvaliacao,
          child: const Text("Postar Avaliação"),
        ),
        const SizedBox(height: 20),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('avaliacoes')
              .where('receitaId', isEqualTo: widget.receitaId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError)
              return const Text("Erro ao carregar avaliações.");
            if (snapshot.connectionState == ConnectionState.waiting)
              return const CircularProgressIndicator();

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(doc['nota'].toString())),
                    title: Text(doc['userName']),
                    subtitle: Text(doc['comentario']),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
