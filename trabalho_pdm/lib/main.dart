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
    Center(child: Text("Aulas em breve")),
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
