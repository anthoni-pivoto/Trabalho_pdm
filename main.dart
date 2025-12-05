import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final id = prefs.getInt("id_usuario");

  runApp(MyApp(isLogged: id != null));
}

class MyApp extends StatelessWidget {
  final bool isLogged;

  const MyApp({super.key, required this.isLogged});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: isLogged ? HomePage() : LoginPage(),
    );
  }
}

class PesquisaScreen extends StatefulWidget {
  const PesquisaScreen({Key? key}) : super(key: key);

  @override
  State<PesquisaScreen> createState() => _PesquisaScreenState();
}

class _PesquisaScreenState extends State<PesquisaScreen> {
  List cursos = [];
  bool carregando = false;

  Future<void> openWhatsApp({
    required String phone,
    String? text,
  }) async {
    final String encodedText = Uri.encodeComponent(text ?? "");
    final Uri url = Uri.parse("https://wa.me/$phone?text=$encodedText");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw "Não foi possível abrir o WhatsApp";
    }
  }

  Future<void> buscarCursos(String query) async {
    if (query.isEmpty) {
      setState(() => cursos = []);
      return;
    }

    setState(() => carregando = true);
    final url = Uri.parse(
      "http://200.19.1.19/usuario02/api/curso.php?search=$query",
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          cursos = jsonDecode(response.body);
          carregando = false;
        });
      } else {
        setState(() {
          cursos = [];
          carregando = false;
        });
      }
    } catch (e) {
      setState(() {
        cursos = [];
        carregando = false;
      });
    }
  }

  Widget buildCourseItem({
    required String titulo,
    required String descricao,
    required VoidCallback onIngresso,
    required VoidCallback onConversar,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  "https://cdn-icons-png.flaticon.com/128/2901/2901131.png",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descricao,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onIngresso,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                      255,
                      214,
                      214,
                      214,
                    ), // Cor cinza
                    elevation: 4, // Elevação (sombra)
                    shadowColor: Colors.black, // Cor da sombra
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        4,
                      ), // Bordas quadradas
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 24,
                    ),
                  ),
                  child: const Text(
                    "Ingressar",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton(
                  onPressed: onConversar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                      255,
                      214,
                      214,
                      214,
                    ), // Cor cinza
                    elevation: 4, // Elevação (sombra)
                    shadowColor: Colors.black, // Cor da sombra
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        4,
                      ), // Bordas quadradas
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 24,
                    ),
                  ),
                  child: const Text(
                    "Conversar",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. O AppBar (barra preta superior)
      // 1. O AppBar (barra preta superior)
      // 1. O AppBar (barra preta superior)
      // 1. O AppBar (barra preta superior)
      // 1. O AppBar (barra preta superior)
      // Usamos PreferredSize para customizar a altura e a forma
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0), // Altura do AppBar
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.black, // Cor de fundo preta
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(24), // Bordas arredondadas
            ),
          ),
          // Usamos SafeArea para evitar a barra de status do celular
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  // Botão de voltar
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      // Se esta tela foi 'pushReplacement' do login,
                      // o 'pop' pode não funcionar como esperado.
                      // Mas se foi 'push', está correto.
                      if (Navigator.canPop(context)) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  const SizedBox(width: 8.0),
                  // Título
                  const Text(
                    'Pesquisar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // 2. O Corpo da Tela (fundo branco)
      // 2. O Corpo da Tela (fundo branco)

      // 2. O Corpo da Tela (fundo branco)

      // 2. O Corpo da Tela (fundo branco)

      // 2. O Corpo da Tela (fundo branco)
      // 2. O Corpo da Tela (fundo branco)
      backgroundColor: Colors.white, // Fundo branco como na imagem
      body: Column(
        children: [
          // 3. A Barra de Pesquisa (TextField)
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
            child: TextField(
              onChanged: (value) => buscarCursos(value),
              decoration: InputDecoration(
                hintText: 'Pesquisar...', // Texto de sugestão
                // Ícone da lupa dentro da barra
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.grey[200], // Fundo cinza claro
                contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                // Bordas arredondadas sem linha de contorno
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 4. O Texto Central (ocupa o resto da tela)
          Expanded(
            child: carregando
                ? const Center(child: CircularProgressIndicator())
                : cursos.isEmpty
                ? Center(
                    child: Text(
                      'Pesquise por um curso\npara exibir os resultados',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cursos.length,
                    itemBuilder: (context, index) {
                      final curso = cursos[index];

                      return buildCourseItem(
                        titulo: curso['s_nm_curso'],
                        descricao: curso['s_descricao_curso'],
                        onIngresso: () {
                          print("Ingressou no curso ${curso['id_curso']}");
                        },
                        onConversar: () async {
                          final uriProfessor = Uri.parse("http://200.19.1.19/usuario02/api/usuario.php?id_usuario=${int.parse(curso['id_usuario'].toString())}");
                          final response = await http.get(uriProfessor);
                          if (response.statusCode != 200) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Erro ao conectar com professor')),
                            );
                            return;
                          }
                          final professor = jsonDecode(response.body);
                          final telefone = professor['i_numero_telefone'].toString();
                          if (telefone.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Professor não possui telefone cadastrado')),
                            );
                            return;
                          } 
                          openWhatsApp(
                            phone: telefone,
                            text: "Olá! Gostaria de saber mais informações.",
                          );
                          print("Conversar sobre o curso ${curso['id_curso']}");
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

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = "";
  String userEmail = "";
  String userPhone = "";
  String userPhotoUrl = "";
  @override
  void initState() {
    super.initState();
    carregarDadosUsuario();
  }

  void carregarDadosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final int? idUsuario = prefs.getInt("id_usuario");
    if (idUsuario == null) return;
    final int? idMidia = prefs.getInt("id_midia");
    if (idMidia != null && idMidia > 0) {
      final uriProfilePic =
      Uri.parse("http://200.19.1.19/usuario02/api/arquivo.php?id_midia=$idMidia");
      final response = await http.get(uriProfilePic);
      if (response.statusCode == 200) {
        String caminho = jsonDecode(response.body)["s_caminho"];
        setState(() {
          userPhotoUrl = "http://200.19.1.19/usuario02/$caminho";
        });
      }
    }
    setState(() {
      userName = prefs.getString("nm_usuario") ?? "";
      userEmail = prefs.getString("email_usuario") ?? "";
      userPhone = prefs.getInt("i_numero_telefone").toString();
    });
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("id_usuario");
    await prefs.remove("nm_usuario");
    await prefs.remove("email_usuario");
    await prefs.remove("i_numero_telefone");
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0), // Altura do AppBar
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.black, // Cor de fundo preta
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(24), // Bordas arredondadas
            ),
          ),
          // Usamos SafeArea para evitar a barra de status do celular
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  // Botão de voltar
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      // Se esta tela foi 'pushReplacement' do login,
                      // o 'pop' pode não funcionar como esperado.
                      // Mas se foi 'push', está correto.
                      if (Navigator.canPop(context)) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  const SizedBox(width: 8.0),
                  // Título
                  const Text(
                    'Perfil',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar grande
            CircleAvatar(
              radius: 70,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: userPhotoUrl.isNotEmpty
                  ? NetworkImage(userPhotoUrl)
                  : null,
              child: userPhotoUrl.isEmpty
                  ? const Icon(Icons.person, size: 80, color: Colors.black54)
                  : null,
            ),

            const SizedBox(height: 24),

            // Nome
            _buildProfileInfo(icon: Icons.person, label: userName),

            // Email do usuário
            _buildProfileInfo(icon: Icons.email, label: userEmail),

            // Telefone (com botão editar)
            _buildProfileInfo(
              icon: Icons.phone,
              label: userPhone,
              showEdit: true,
            ),

            const SizedBox(height: 30),

            // Botão logout
            ElevatedButton(
              onPressed: logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Sair"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo({
    required IconData icon,
    required String label,
    bool showEdit = false,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: Colors.black87),
            const SizedBox(width: 12),

            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),

            if (showEdit) Icon(Icons.edit, size: 20, color: Colors.black87),
          ],
        ),

        const SizedBox(height: 6),

        // Linha fina de separação
        Container(height: 1, color: Colors.black54),

        const SizedBox(height: 12),
      ],
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    PesquisaScreen(),
    AlunoScreen(),
    ProfessorScreen(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[400],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Pesquisar"),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: "Cursos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_work_outlined),
            label: "Aulas",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Perfil",
          ),
        ],
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  var usuario = {};

  Future<void> _login() async {
    const String apiUrl = 'http://200.19.1.19/usuario02/api/usuario.php';

    setState(() {
      _isLoading = true;
    });

    try {
      final body = {
        'email_usuario': _emailController.text,
        'pwd_usuario': _passwordController.text,
        'action': 'login',
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        usuario = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();

        await prefs.setInt("id_usuario", usuario['id_usuario']);
        await prefs.setString("nm_usuario", usuario['s_nome'] ?? "");
        await prefs.setString("email_usuario", usuario['s_email'] ?? "");
        await prefs.setInt(
          "i_numero_telefone",
          usuario['i_numero_telefone'] ?? "",
        );
        await prefs.setInt("id_midia", usuario['id_midia']);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login realizado com sucesso!')),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Falha no login: ${response.body}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao conectar: $e')));
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tela de Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'ex: maria@gmail.com',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
              ),
              const SizedBox(height: 32.0),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text('Entrar'),
                    ),
              const SizedBox(height: 20.0),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CadastroPage(),
                    ),
                  );
                },
                child: const Text('Não tem conta? Cadastre-se'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _cadastrar() async {
    const String apiUrl = 'http://200.19.1.19/usuario02/api/usuario.php';

    setState(() {
      _isLoading = true;
    });

    try {
      final body = {
        'nm_usuario': _nomeController.text,
        'email_usuario': _emailController.text,
        'pwd_usuario': _passwordController.text,
        'action': 'register',
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cadastro realizado com sucesso!')),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Falha no cadastro: ${response.body}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao conectar: $e')));
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Usuário'),
        // O botão de "voltar" é adicionado automaticamente pelo Navigator
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Campo de Nome
              TextField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  hintText: 'ex: Maria da Silva',
                ),
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16.0),
              // Campo de Email
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'ex: maria@gmail.com',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16.0),
              // Campo de Senha
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
              ),
              const SizedBox(height: 32.0),
              // Botão de Cadastrar
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _cadastrar,
                      child: const Text('Cadastrar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfessorScreen extends StatefulWidget {
  const ProfessorScreen({Key? key}) : super(key: key);

  @override
  State<ProfessorScreen> createState() => _ProfessorScreenState();
}

class _ProfessorScreenState extends State<ProfessorScreen> {
  List cursos = [];
  bool carregando = true;

  // 🔥 estado do modal
  bool modalAberto = false;

  // 🔥 controllers dos campos
  TextEditingController nmCursoController = TextEditingController();
  TextEditingController dsCursoController = TextEditingController();

  bool salvando = false;

  @override
  void initState() {
    super.initState();
    buscarCursosUsuario();
  }

  // 🔥 BUSCAR CURSOS DO USUARIO
  Future<void> buscarCursosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final int? idUsuario = prefs.getInt("id_usuario");

    if (idUsuario == null) {
      setState(() {
        carregando = false;
      });
      return;
    }

    final url = Uri.parse(
      "http://200.19.1.19/usuario02/api/curso.php?id_usuario=$idUsuario",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          cursos = jsonDecode(response.body);
          carregando = false;
        });
      } else {
        setState(() {
          cursos = [];
          carregando = false;
        });
      }
    } catch (e) {
      setState(() {
        cursos = [];
        carregando = false;
      });
    }
  }

  // 🔥 SALVAR NOVO CURSO (POST)
  Future<void> salvarCurso() async {
    final prefs = await SharedPreferences.getInstance();
    final int? idUsuario = prefs.getInt("id_usuario");

    if (idUsuario == null) return;

    setState(() => salvando = true);

    final url = Uri.parse("http://200.19.1.19/usuario02/api/curso.php");

    final body = {
      "id_usuario": idUsuario,
      "nm_curso": nmCursoController.text,
      "ds_curso": dsCursoController.text,
    };

    try {
      final response = await http.post(
        url,
        body: {
          "id_usuario": idUsuario.toString(),
          "nm_curso": nmCursoController.text,
          "ds_curso": dsCursoController.text,
        },
      );
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        // fecha modal
        setState(() {
          modalAberto = false;
          nmCursoController.clear();
          dsCursoController.clear();
        });

        // recarrega cursos
        buscarCursosUsuario();
      }
    } catch (e) {
      print("Erro ao  curso: $e");
    } finally {
      setState(() => salvando = false);
    }
  }

  // 🔥 ITEM DA LISTA
  Widget buildCourseItem({required String titulo, required String descricao}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              "https://cdn-icons-png.flaticon.com/128/2901/2901131.png",
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descricao,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 MODAL DE CRIAÇÃO DE CURSO
  Widget modalAdicionarCurso() {
    if (!modalAberto) return const SizedBox.shrink();

    return Stack(
      children: [
        // Fundo escuro
        GestureDetector(
          onTap: () => setState(() => modalAberto = false),
          child: Container(color: Colors.black.withOpacity(0.4)),
        ),

        // Modal central
        Center(
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Novo Curso",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: nmCursoController,
                  decoration: const InputDecoration(
                    labelText: "Nome do curso",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: dsCursoController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Descrição",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    print("BOTÃO SALVAR FOI CLICADO");
                    salvarCurso();
                  },
                  child: salvando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Salvar"),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(100.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: const SafeArea(
                child: Row(
                  children: [
                    SizedBox(width: 16),
                    Text(
                      "Professor Cursos",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          backgroundColor: Colors.white,

          // 🔥 LISTA OU LOADING
          body: carregando
              ? const Center(child: CircularProgressIndicator())
              : cursos.isEmpty
              ? Center(
                  child: Text(
                    "Você ainda não possui cursos.",
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cursos.length,
                  itemBuilder: (context, index) {
                    final curso = cursos[index];
                    return buildCourseItem(
                      titulo: curso['s_nm_curso'],
                      descricao: curso['s_descricao_curso'],
                    );
                  },
                ),

          // 🔥 Botão flutuante
          floatingActionButton: FloatingActionButton(
            onPressed: () => setState(() => modalAberto = true),
            backgroundColor: Colors.black,
            child: const Icon(Icons.add, size: 32, color: Colors.white),
          ),
        ),

        // 🔥 Overlay do modal
        modalAdicionarCurso(),
      ],
    );
  }
}


// ============================================================================
// TELA 1: LISTA DE CURSOS (AlunoScreen)
// ============================================================================
class AlunoScreen extends StatefulWidget {
  const AlunoScreen({super.key});

  @override
  State<AlunoScreen> createState() => _AlunoScreenState();
}

class _AlunoScreenState extends State<AlunoScreen> {
  final String apiUrl = "http://200.19.1.19/usuario02/api/curso.php"; 
  final String idUsuario = "1"; 

  late Future<List<dynamic>> _cursosFuture;

  @override 
  void initState() {
    super.initState();
    _cursosFuture = fetchCursos();
  }

  Future<List<dynamic>> fetchCursos() async {
    try {
      final uri = Uri.parse("$apiUrl?id_usuario=$idUsuario");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Falha ao carregar cursos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Meus cursos",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _cursosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("Erro: ${snapshot.error}", style: const TextStyle(color: Colors.red)),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Nenhum curso encontrado."));
                } else {
                  final cursos = snapshot.data!;
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: cursos.length,
                    itemBuilder: (context, index) {
                      final curso = cursos[index];

                      final idCurso = curso["id_curso"]?.toString() ?? "0"; 
                      
                      final titulo = curso["s_nm_curso"]?.toString() 
                                  ?? curso["nm_curso"]?.toString() 
                                  ?? "Sem título"; 
                                  
                      final descricao = curso["s_descricao_curso"]?.toString() 
                                     ?? curso["ds_curso"]?.toString() 
                                     ?? "Sem descrição";

                      return _buildCourseItem(context, idCurso, titulo, descricao); 
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseItem(BuildContext context, String id, String title, String subtitle) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EtapasCursoScreen(idCurso: id, tituloCurso: title),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20.0, top: 10.0),
          child: Row(
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.view_in_ar, color: Colors.lightBlueAccent, size: 30),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// TELA 2: LISTA DE ETAPAS (EtapasCursoScreen)
// ============================================================================
class EtapasCursoScreen extends StatefulWidget {
  final String idCurso;
  final String tituloCurso;

  const EtapasCursoScreen({
    super.key, 
    required this.idCurso, 
    required this.tituloCurso
  });

  @override
  State<EtapasCursoScreen> createState() => _EtapasCursoScreenState();
}

class _EtapasCursoScreenState extends State<EtapasCursoScreen> {
  final String apiUrl = "http://200.19.1.19/usuario02/api/etapa.php"; 

  late Future<List<dynamic>> _etapasFuture;

  @override
  void initState() {
    super.initState();
    _etapasFuture = fetchEtapas();
  }

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFF1A1A1A),
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: 
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          const Text(
            "Aluno",
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
  Future<List<dynamic>> fetchEtapas() async {
    try {
      final uri = Uri.parse("$apiUrl?id_curso=${widget.idCurso}");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao carregar etapas');
      }
    } catch (e) {
      throw Exception('Erro de conexão');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.tituloCurso,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  
                  Expanded(
                    child: FutureBuilder<List<dynamic>>(
                      future: _etapasFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text("Erro: ${snapshot.error}"));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text("Nenhuma etapa disponível.");
                        }

                        final etapas = snapshot.data!;
                        
                        return ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: etapas.length,
                          itemBuilder: (context, index) {
                            final etapa = etapas[index];
                            
                            String idDaEtapa = etapa["id_etapa"]?.toString() ?? "${index + 1}";
                            String titulo = "Etapa $idDaEtapa";
                            
                            String descricaoVisual = etapa["s_descricao"]?.toString() 
                                          ?? etapa["ds_tipo"]?.toString() 
                                          ?? "";

                           String idTipoEtapa = (etapa["id_tipo_etapa"] ?? "0").toString();

                            return _buildEtapaItem(idDaEtapa, titulo, descricaoVisual, idTipoEtapa);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      
    );
  }

  Widget _buildEtapaItem(String idEtapa, String titulo, String descricao, String idTipoEtapa) {
    if (titulo.isEmpty) return const SizedBox.shrink(); 

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConteudoEtapaScreen(
                idEtapa: idEtapa,   
                tituloEtapa: titulo,
                idTipoEtapa: idTipoEtapa, 
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              if (descricao.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  descricao,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// TELA 3: VISUALIZADOR DE CONTEÚDO (ConteudoEtapaScreen)
// ============================================================================
class ConteudoEtapaScreen extends StatefulWidget {
  final String idEtapa;
  final String tituloEtapa;
  final String idTipoEtapa; 

  const ConteudoEtapaScreen({
    super.key, 
    required this.idEtapa, 
    required this.tituloEtapa, 
    required this.idTipoEtapa
  });

  @override
  State<ConteudoEtapaScreen> createState() => _ConteudoEtapaScreenState();
}

class _ConteudoEtapaScreenState extends State<ConteudoEtapaScreen> {
  final String apiUrlArquivo = "http://200.19.1.19/usuario02/api/arquivo.php";
  final String apiUrlQuestionario = "http://200.19.1.19/usuario02/api/questionario.php"; 

  bool _isLoading = true;
  String _mensagemErro = "";
  
  Map<String, dynamic>? _dadosArquivo;
  String? _nomeQuestionario;
  String? _idQuestionarioReal;

  // VARIÁVEL PARA CONTROLE LOCAL DE CONCLUSÃO
  bool _concluido = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _isLoading = true;
      _mensagemErro = "";
    });

    try {
      if (widget.idTipoEtapa == "1") {
        await _fetchQuestionario();
      } else {
        await _fetchArquivo();
      }
    } catch (e) {
      setState(() {
        _mensagemErro = "Erro: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Busca o Nome do Questionário
 Future<void> _fetchQuestionario() async {
    final uri = Uri.parse("$apiUrlQuestionario?id_etapa=${widget.idEtapa}");
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _nomeQuestionario = data["nm_questionario"]?.toString() ?? "Questionário";
        _idQuestionarioReal = data["id_questionario"]?.toString(); 
      });
    } else {
      throw Exception("${response.body}");
    }
  }

  Future<void> _fetchArquivo() async {
    final uri = Uri.parse("$apiUrlArquivo?id_etapa=${widget.idEtapa}");
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      setState(() {
        _dadosArquivo = json.decode(response.body);
      });
    } else {
      _dadosArquivo = null; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.tituloEtapa, style: const TextStyle(color: Colors.white)),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_mensagemErro.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_mensagemErro, 
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red)
          ),
        )
      );
    }

    if (widget.idTipoEtapa == "1") {
      return _buildTelaQuestionario();
    }

    return _buildTelaArquivo();
  }

  Widget _buildTelaQuestionario() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.quiz, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 20),
            const Text(
              "Questionário Disponível:",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              _nomeQuestionario ?? "Carregando...",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold, 
                color: Colors.black87
              ),
            ),
            const SizedBox(height: 40),
           ElevatedButton(
              onPressed: () {
                if (_idQuestionarioReal != null && _idQuestionarioReal != "0") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TelaResolverQuestionario(
                          idQuestionario: _idQuestionarioReal!,
                          nomeQuestionario: _nomeQuestionario ?? "Questionário",
                        ),
                      ),
                    );
                } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Erro: ID do questionário não encontrado."))
                    );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text("INICIAR", style: TextStyle(color: Colors.white, fontSize: 18)),
            )
          ],
        ),
      ),
    );
  }

  // --- TELA DE ARQUIVO COM A OPÇÃO DE CONCLUIR ---
  Widget _buildTelaArquivo() {
    if (_dadosArquivo == null) {
      return const Center(child: Text("Nenhum conteúdo encontrado."));
    }

    final urlArquivo = _dadosArquivo!["s_caminho"]?.toString() 
                    ?? _dadosArquivo!["ds_caminho"]?.toString() 
                    ?? "";
    
    final tipoArquivo = _dadosArquivo!["id_tipo_etapa"]?.toString() 
                     ?? _dadosArquivo!["ds_tipo"]?.toString() 
                     ?? "";

    return Column(
      children: [
        // Parte superior com Título e Arquivo (Expansível)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Text(
                  "Conteúdo Anexado",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                Expanded(child: _buildVisualizador(urlArquivo, tipoArquivo)),
              ],
            ),
          ),
        ),
        
        // --- NOVA OPÇÃO DE MARCAR COMO CONCLUÍDO (Fixa embaixo) ---
        _buildOpcaoConclusao(),
      ],
    );
  }

  Widget _buildOpcaoConclusao() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: _concluido, 
            activeColor: Colors.green,
            onChanged: (bool? novoValor) {
              setState(() {
                _concluido = novoValor ?? false;
              });
              
              if (_concluido) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Etapa marcada como concluída!"),
                    duration: Duration(seconds: 1),
                  )
                );
              }
            }
          ),
          const Expanded(
            child: Text(
              "Marcar como concluído",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualizador(String url, String tipo) {
    if (url.isEmpty) {
      return const Center(child: Text("Esta etapa não possui arquivo anexado."));
    }

    String urlLimpa = url.trim();
    String nomeArquivo = urlLimpa.replaceAll("files/", "").replaceAll("/", "");
    String urlFinal = "http://200.19.1.19/usuario02/api/arquivo.php?ver_imagem=$nomeArquivo";

    if (tipo.toLowerCase().contains("imagem") || 
        nomeArquivo.toLowerCase().endsWith(".jpg") || 
        nomeArquivo.toLowerCase().endsWith(".png") ||
        nomeArquivo.toLowerCase().endsWith(".jpeg")) {
      
      return Image.network(
        urlFinal,
        headers: const {"Cache-Control": "no-cache"}, 
        errorBuilder: (context, error, stackTrace) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.broken_image, size: 50, color: Colors.grey),
            Text("Erro ao carregar imagem"),
          ],
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      );
    } 
    else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.insert_drive_file, size: 100, color: Colors.blue),
          const SizedBox(height: 20),
          Text(
            "Arquivo disponível: $nomeArquivo",
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text("Formato não suportado para visualização no app.", 
            style: TextStyle(fontSize: 11, color: Colors.grey)
          ),
        ],
      );
    }
  }
}

// ============================================================================
// TELA 4: RESOLUÇÃO DE QUESTÕES
// ============================================================================
class TelaResolverQuestionario extends StatefulWidget {
  final String idQuestionario;
  final String nomeQuestionario;

  const TelaResolverQuestionario({
    super.key,
    required this.idQuestionario,
    required this.nomeQuestionario,
  });

  @override
  State<TelaResolverQuestionario> createState() => _TelaResolverQuestionarioState();
}

class _TelaResolverQuestionarioState extends State<TelaResolverQuestionario> {
  bool _isLoading = true;
  List<dynamic> _questoes = [];
  
  final Map<int, int> _respostasSelecionadas = {};

  @override
  void initState() {
    super.initState();
    _carregarQuestoes();
  }

  Future<void> _carregarQuestoes() async {
    final url = "http://200.19.1.19/usuario02/api/questionario.php?acao=carregar_questoes&id_questionario=${widget.idQuestionario}";
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _questoes = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception("Erro: ${response.body}");
      }
    } catch (e) {
      print("Erro: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nomeQuestionario),
        backgroundColor: const Color(0xFF1A1A1A),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _questoes.isEmpty
              ? const Center(child: Text("Este questionário está vazio."))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _questoes.length,
                        itemBuilder: (context, index) {
                          return _buildQuestaoCard(_questoes[index], index + 1);
                        },
                      ),
                    ),
                    _buildBotaoEnviar(),
                  ],
                ),
    );
  }

  Widget _buildQuestaoCard(dynamic questao, int numero) {
    int idPergunta = int.parse(questao["id_pergunta"].toString());
    List<dynamic> alternativas = questao["alternativas"] ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$numero. ${questao["ds_pergunta"]}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...alternativas.map((alt) {
              int idAlternativa = int.parse(alt["id_alternativa"].toString());
              String textoAlternativa = alt["ds_alternativa"];

              bool estaMarcada = _respostasSelecionadas[idPergunta] == idAlternativa;

              return CheckboxListTile(
                title: Text(textoAlternativa),
                value: estaMarcada,
                activeColor: Colors.blue,
                controlAffinity: ListTileControlAffinity.leading, 
                onChanged: (bool? valor) {
                  setState(() {
                    if (valor == true) {
                      _respostasSelecionadas[idPergunta] = idAlternativa;
                    } else {
                      _respostasSelecionadas.remove(idPergunta);
                    }
                  });
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // Lógica de retorno ao clicar em enviar
  Widget _buildBotaoEnviar() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      color: Colors.white,
      child: ElevatedButton(
        onPressed: () {
          // Simula envio
          print("Respostas do Aluno: $_respostasSelecionadas");
          
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text("Respostas enviadas! Voltando para a lista..."))
          );

          // Aguarda e volta para a lista de etapas
          Future.delayed(const Duration(milliseconds: 1500), () {
            Navigator.of(context).pop(); 
            Navigator.of(context).pop(); 
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: const Text("ENVIAR RESPOSTAS", style: TextStyle(fontSize: 16)),
      ),
    );
  }
}