# CookBook

Aplicativo Flutter desenvolvido para o projeto prático da disciplina de Mobile II. O CookBook permite que usuários criem uma conta, façam login, salvem suas próprias receitas, pesquisem receitas cadastradas, favoritem receitas externas, avaliem preparos e consumam uma API pública de receitas.

## Alunos: <br> 
Arthur Vital Fontana - 839832 <br>
João Henrique Nazar Tavares - 839463

## Tema do aplicativo

O projeto é um livro de receitas digital integrado ao Firebase. Cada usuário possui seu próprio espaço para cadastrar receitas, manter favoritos e atualizar seus dados de perfil.

## Tecnologias utilizadas

- Flutter SDK
- Dart
- Firebase Authentication
- Cloud Firestore
- Firebase Hosting
- TheMealDB API
- Pacotes principais: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `http`, `translator`, `rxdart` e `device_preview`

## Funcionalidades

- Cadastro de usuários com e-mail, senha segura, nome, telefone e cidade.
- Login com Firebase Authentication.
- Recuperação de senha por e-mail.
- Cadastro, edição, visualização e exclusão de receitas próprias.
- Perfil do usuário com edição de nome, telefone e cidade.
- Listagem em tempo real de receitas próprias e receitas favoritadas.
- Pesquisa case-insensitive de receitas cadastradas pelo usuário.
- Ordenação dos resultados por ordem alfabética ou data de atualização.
- Consumo da API pública TheMealDB para explorar receitas externas.
- Tradução de informações das receitas externas para português.
- Salvamento e remoção de receitas externas nos favoritos.
- Avaliação de receitas com nota e comentário.
- Interface com navegação inferior entre Explorar, Meu Livro e Perfil.

## Requisitos do projeto

| Requisito | Implementação no CookBook | Arquivos principais |
| --- | --- | --- |
| RF001 - Autenticação de usuários | Login por e-mail e senha com Firebase Authentication, feedback de carregamento/erro e recuperação de senha. | `lib/views/login_page.dart`, `lib/views/esqueceu_senha_page.dart`, `lib/services/auth_service.dart` |
| RF002 - Registro de usuários | Registro com e-mail, senha segura, nome, telefone e cidade. Dados adicionais salvos na coleção `usuarios`. | `lib/views/registro_page.dart`, `lib/services/auth_service.dart`, `lib/widgets/telefone_input_formatter.dart` |
| RF003 - Inserção de dados | Inserção nas coleções `usuarios`, `receitas`, `favoritos` e `avaliacoes`, com pelo menos cinco campos nas coleções principais e identificação por usuário. | `lib/services/auth_service.dart`, `lib/views/nova_receita_page.dart`, `lib/views/receita_detalhes_page.dart` |
| RF004 - Atualização de dados | Atualização de receitas cadastradas e dados do perfil do usuário no Firestore, com feedback em caso de sucesso ou falha. | `lib/views/nova_receita_page.dart`, `lib/views/receita_ver_page.dart`, `lib/views/perfil_page.dart` |
| RF005 - Recuperação de dados | Recuperação em tempo real com `StreamBuilder` e `ListView` para receitas, favoritos e avaliações. | `lib/views/home_page.dart`, `lib/views/pesquisa_receitas_page.dart`, `lib/views/receita_detalhes_page.dart` |
| RF006 - Pesquisa de dados | Tela exclusiva de pesquisa na coleção `receitas`, busca sem diferenciar maiúsculas/minúsculas e ordenação por A-Z ou data. | `lib/views/pesquisa_receitas_page.dart` |
| RF007 - Consumo de API | Consumo da API REST pública TheMealDB para busca e exibição de receitas externas. | `lib/services/api_service.dart`, `lib/views/receitas_api_page.dart`, `lib/views/receita_detalhes_page.dart` |

## Coleções do Firestore

### `usuarios`

Armazena os dados complementares do usuário autenticado.

- `nome`
- `telefone`
- `cidade`
- `email`
- `data_cadastro`

### `receitas`

Armazena receitas criadas pelo usuário.

- `nome`
- `ingredientes`
- `modoPreparo`
- `tempoPreparo`
- `categoria`
- `userId`
- `ultimaAtualizacao`

### `favoritos`

Armazena receitas externas salvas pelo usuário.

- `nome`
- `imagem`
- `categoria`
- `origem`
- `instrucoes`
- `idMeal`
- `userId`
- `data_favorito`

### `avaliacoes`

Armazena avaliações feitas pelos usuários em receitas.

- `nota`
- `comentario`
- `data`
- `userId`
- `userName`
- `receitaId`

## Estrutura principal

```text
lib/
  main.dart
  firebase_options.dart
  models/
    receita_model.dart
  services/
    api_service.dart
    auth_service.dart
  views/
    login_page.dart
    registro_page.dart
    esqueceu_senha_page.dart
    navigation_wrapper.dart
    receitas_api_page.dart
    home_page.dart
    nova_receita_page.dart
    receita_ver_page.dart
    receita_detalhes_page.dart
    pesquisa_receitas_page.dart
    perfil_page.dart
  widgets/
    telefone_input_formatter.dart
    secao_avaliacao.dart
```

## Como executar o projeto

1. Instale o Flutter SDK e configure um emulador ou dispositivo físico.
2. Clone este repositório.

```bash
git clone https://github.com/Joaohnt27/cookbook.git
```
3. Instale as dependências:

```bash
flutter pub get
```

4. Entrar na Pasta:

```bash
cd cookbook
```

5. Confira se os arquivos de configuração do Firebase estão presentes:

- `lib/firebase_options.dart`
- `android/app/google-services.json`

6. Execute o aplicativo:

```bash
flutter run
```

## Build para web e Firebase Hosting

O projeto está configurado para publicar a versão web em `build/web`, conforme o arquivo `firebase.json`.

```bash
flutter build web
firebase deploy
```

## API externa

O aplicativo consome a API pública TheMealDB:

```text
https://www.themealdb.com/api/json/v1/1/search.php?s={termo}
```

Essa integração é usada na tela Explorar Receitas para buscar receitas externas e abrir seus detalhes.

## Dados da entrega

- Link do Firebase Hosting: https://cookbook-27d6c.web.app
