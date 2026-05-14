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
  final Color _primaryColor = const Color(0xFFE67E22);
  final Color _secondaryColor = const Color(0xFF34495E);

  String _nome = "";
  String _categoria = "";
  String _origem = "";
  String _instrucoes = "Traduzindo conteúdo...";
  bool _estaTraduzindo = true;
  String? _idFavoritoExistente;

  @override
  void initState() {
    super.initState();
    _inicializarDados();
  }

  Future<void> _inicializarDados() async {
    if (widget.meal['strInstructions'] == null ||
        widget.meal['strInstructions'].isEmpty) {
      setState(() {
        _nome = widget.meal['strMeal'] ?? "";
        _categoria = widget.meal['strCategory'] ?? "";
        _origem = widget.meal['strArea'] ?? "";
        _instrucoes = widget.meal['strInstructions'] ?? "Sem modo de preparo.";
      });
      await _verificarSeEhFavorito();
      return;
    }

    await _traduzirTudo();
    await _verificarSeEhFavorito();
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

  Future<void> _verificarSeEhFavorito() async {
    final user = FirebaseAuth.instance.currentUser;
    final String idBusca =
        widget.meal['idMeal']?.toString() ??
        widget.meal['id']?.toString() ??
        '';

    if (user == null || idBusca.isEmpty) return;

    final query = await FirebaseFirestore.instance
        .collection('favoritos')
        .where('userId', isEqualTo: user.uid)
        .where('idMeal', isEqualTo: idBusca)
        .get();

    if (query.docs.isNotEmpty && mounted) {
      setState(() {
        _idFavoritoExistente = query.docs.first.id;
      });
    }
  }

  Future<void> _alternarFavorito() async {
    final user = FirebaseAuth.instance.currentUser;

    if (_idFavoritoExistente != null) {
      try {
        await FirebaseFirestore.instance
            .collection('favoritos')
            .doc(_idFavoritoExistente)
            .delete();

        if (mounted) {
          setState(() => _idFavoritoExistente = null);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Removido dos favoritos!"),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Erro ao remover: $e"),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
      return;
    }

    try {
      final docRef = await FirebaseFirestore.instance
          .collection('favoritos')
          .add({
            'nome': _nome,
            'imagem': widget.meal['strMealThumb'],
            'categoria': _categoria,
            'origem': _origem,
            'instrucoes': _instrucoes,
            'idMeal': widget.meal['idMeal'],
            'userId': user?.uid,
            'data_favorito': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        setState(() => _idFavoritoExistente = docRef.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Salvo nos favoritos!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao salvar: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
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
      backgroundColor: const Color(0xFFFDFBFA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: _secondaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _estaTraduzindo ? "Carregando..." : _nome,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black)],
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
                        colors: [Colors.transparent, Colors.black87],
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
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildInfoChip(Icons.restaurant, _categoria),
                        const SizedBox(width: 10),
                        _buildInfoChip(Icons.public, _origem),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Icon(Icons.menu_book, color: _primaryColor),
                        const SizedBox(width: 10),
                        Text(
                          "Modo de Preparo",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _secondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(),
                    ),
                    _estaTraduzindo
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Text(
                            _instrucoes,
                            textAlign: TextAlign.justify,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                          ),
                    const SizedBox(height: 40),
                    const Divider(thickness: 1.5),
                    const SizedBox(height: 20),
                    SecaoAvaliacao(receitaId: receitaId),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _idFavoritoExistente != null
            ? Colors.redAccent
            : _primaryColor,
        onPressed: _alternarFavorito,
        label: Text(
          _idFavoritoExistente != null ? "REMOVER FAVORITO" : "SALVAR RECEITA",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        icon: Icon(
          _idFavoritoExistente != null ? Icons.favorite_border : Icons.favorite,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _primaryColor),
          const SizedBox(width: 6),
          Text(
            _estaTraduzindo ? "..." : label,
            style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
          ),
        ],
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
  final Color _primaryColor = const Color(0xFFE67E22);
  final Color _secondaryColor = const Color(0xFF34495E);

  void _enviarAvaliacao() async {
    if (_comentarioController.text.isEmpty) return;
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user?.uid)
          .get();
      final dadosUsuario = userDoc.data() as Map<String, dynamic>?;
      final nomeReal = dadosUsuario != null
          ? dadosUsuario['nome']
          : "Cozinheiro";

      await FirebaseFirestore.instance.collection('avaliacoes').add({
        'nota': _nota,
        'comentario': _comentarioController.text,
        'data': FieldValue.serverTimestamp(),
        'userId': user?.uid,
        'userName': nomeReal,
        'receitaId': widget.receitaId,
      });

      _comentarioController.clear();
      setState(() => _nota = 5);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Avaliação enviada!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao enviar: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Avaliações",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _secondaryColor,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () => setState(() => _nota = index + 1.0),
              child: Icon(
                index < _nota ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 35,
              ),
            );
          }),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _comentarioController,
          decoration: InputDecoration(
            labelText: "Escreva sua opinião...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: _primaryColor, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _enviarAvaliacao,
          style: ElevatedButton.styleFrom(
            backgroundColor: _secondaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text("Postar Avaliação"),
        ),
        const SizedBox(height: 25),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('avaliacoes')
              .where('receitaId', isEqualTo: widget.receitaId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox();
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _primaryColor,
                      child: Text(
                        doc['nota'].toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      doc['userName'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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
