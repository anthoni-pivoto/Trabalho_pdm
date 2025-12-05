<?php
// ============================================================================
// CONFIGURAÇÃO CRÍTICA: DESATIVAR ERROS VISUAIS
// ============================================================================
// Isso impede que Warnings do PHP (ex: <br />...) apareçam e quebrem o JSON do Flutter.
ini_set('display_errors', 0); 
error_reporting(E_ALL); // Continua a registar erros no log do servidor (arquivo de log).

header("Content-Type: application/json; charset=utf-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

// ============================================================================
// FUNÇÃO AUXILIAR: CONVERTER TUDO PARA UTF-8 (BLINDADA)
// ============================================================================
// Garante que acentos vindos do banco (Latin1) sejam transformados em UTF-8 válido.
function utf8ize($d) {
    if (is_array($d)) {
        foreach ($d as $k => $v) {
            $d[$k] = utf8ize($v);
        }
    } else if (is_string ($d)) {
        // Tenta usar mb_convert_encoding (Melhor opção)
        if (function_exists('mb_convert_encoding')) {
            return mb_convert_encoding($d, 'UTF-8', 'ISO-8859-1');
        } 
        // Fallback para utf8_encode (Caso o servidor não tenha mbstring)
        else {
            return utf8_encode($d);
        }
    }
    return $d;
}

// 1. CARREGA OS MODELS COM VERIFICAÇÃO
$models = [
    '/../model/Questionario.php',
    '/../model/Pergunta.php',
    '/../model/Alternativa.php'
];

foreach ($models as $model) {
    if (file_exists(__DIR__ . $model)) {
        require_once __DIR__ . $model;
    } else {
        http_response_code(500);
        die(json_encode(["erro" => "Arquivo em falta no servidor: $model"]));
    }
}

// 2. CARREGA BANCO E CONTROLLER
if (!file_exists(__DIR__ . '/../config/Banco.php')) {
    http_response_code(500);
    die(json_encode(["erro" => "Arquivo Banco.php não encontrado"]));
}
require_once __DIR__ . '/../config/Banco.php';

if (!file_exists(__DIR__ . '/../controller/QuestionarioController.php')) {
    http_response_code(500);
    die(json_encode(["erro" => "Arquivo QuestionarioController.php não encontrado"]));
}
require_once __DIR__ . '/../controller/QuestionarioController.php';

// 3. INICIA O CONTROLLER
try {
    $controller = new QuestionarioController();
} catch (Exception $e) {
    http_response_code(500);
    die(json_encode(["erro" => "Falha ao iniciar Controller (Verifique sintaxe ou conexão): " . $e->getMessage()]));
}

$method = $_SERVER["REQUEST_METHOD"];

switch ($method) {
    case "POST":
        try {
            $data = json_decode(file_get_contents("php://input"));

            if (!empty($data->id_curso) && !empty($data->nm_questionario) && !empty($data->perguntas)) {
                $questionario = new Questionario();
                $questionario->id_curso = $data->id_curso;
                $questionario->nm_questionario = $data->nm_questionario;
                $questionario->perguntas = [];

                foreach ($data->perguntas as $p) {
                    $pergunta = new Pergunta();
                    $pergunta->ds_pergunta = $p->ds_pergunta;
                    $pergunta->alternativas = [];

                    foreach ($p->alternativas as $a) {
                        $alternativa = new Alternativa();
                        $alternativa->ds_alternativa = $a->ds_alternativa;
                        $alternativa->correta = $a->correta;
                        $pergunta->alternativas[] = $alternativa;
                    }
                    $questionario->perguntas[] = $pergunta;
                }

                if ($controller->criarQuestionario($questionario)) {
                    http_response_code(201);
                    echo json_encode(["status" => "success", "message" => "Questionário criado com sucesso"]);
                } else {
                    http_response_code(500);
                    echo json_encode(["status" => "error", "message" => "Erro ao criar questionário"]);
                }
            } else {
                http_response_code(400);
                echo json_encode(["status" => "error", "message" => "Dados incompletos"]);
            }

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "error", "message" => $e->getMessage()]);
        }
        break;

    case "GET":
        // --------------------------------------------------------------------
        // A. CARREGAR QUESTÕES COMPLETAS (APP - TELA DE PROVA)
        // --------------------------------------------------------------------
        if (isset($_GET['acao']) && $_GET['acao'] == 'carregar_questoes' && isset($_GET['id_questionario'])) {
            $idQuest = $_GET['id_questionario'];
            
            // Busca dados (que podem vir em Latin1 do banco)
            $dados = $controller->buscarCompleto($idQuest);
            
            // Converte para UTF-8 e envia
            echo json_encode(utf8ize($dados));
        }
        
        // --------------------------------------------------------------------
        // B. BUSCA NOME DO QUESTIONARIO PELA ETAPA (APP - TELA ANTERIOR)
        // --------------------------------------------------------------------
        elseif (isset($_GET['id_etapa'])) {
            $idEtapa = $_GET['id_etapa'];
            try {
                $banco = new Banco();
                $conn = $banco->conectar();
                
                // VACINA: Garante que o banco não tenta converter caracteres e falhar
                $conn->exec("SET client_encoding='ISO-8859-1'"); 

                $sql = "SELECT 
                            e.id_etapa,
                            e.id_questionario,
                            COALESCE(q.nm_questionario, 'Sem questionário vinculado') as nm_questionario
                        FROM tb_etapa e
                        LEFT JOIN tb_questionario q ON e.id_questionario = q.id_questionario
                        WHERE e.id_etapa = :id_etapa";

                $stmt = $conn->prepare($sql);
                $stmt->bindParam(':id_etapa', $idEtapa, PDO::PARAM_INT);
                $stmt->execute();
                $resultado = $stmt->fetch(PDO::FETCH_ASSOC);

                if ($resultado) {
                    echo json_encode(utf8ize($resultado));
                } else {
                    echo json_encode(["nm_questionario" => "Etapa não encontrada", "id_questionario" => 0]);
                }

            } catch (PDOException $e) {
                http_response_code(500);
                echo json_encode(["erro" => "Erro SQL: " . $e->getMessage()]);
            }
        } 
        
        // --------------------------------------------------------------------
        // C. LISTA TODOS (LEGADO/ADMIN)
        // --------------------------------------------------------------------
        else {
            $lista = $controller->listarQuestionarios();
            echo json_encode(utf8ize($lista));
        }
        break;

    default:
        http_response_code(405);
        echo json_encode(["erro" => "Método não permitido"]);
        break;
}
?>