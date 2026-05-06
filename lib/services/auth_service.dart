import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> registrar({
    required String email,
    required String password,
    required String nome,
    required String telefone,
  }) async {
    try {
      // Cria o usuário no Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Salva os dados adicionais no Firestore
      await _db.collection('usuarios').doc(userCredential.user!.uid).set({
        'nome': nome,
        'telefone': telefone,
        'email': email,
        'data_cadastro': FieldValue.serverTimestamp(),
      });

      return null; // Sucesso
    } on FirebaseAuthException catch (e) {
      return e.message; // msg de erro
    } catch (e) {
      return e.toString();
    }
  }

  // Login com e-mail e senha
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Sucesso
    } on FirebaseAuthException catch (e) {
      return e.message; // msg de erro
    }
  }

  // Recuperação de senha
  Future<String?> recuperarSenha(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
