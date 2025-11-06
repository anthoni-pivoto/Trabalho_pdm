<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST");
header("Access-Control-Allow-Headers: Content-Type");

require_once __DIR__ . '/../controller/QuestionarioController.php';
require_once __DIR__ . '/../model/Questionario.php';
require_once __DIR__ . '/../model/Pergunta.php';
require_once __DIR__ . '/../model/Alternativa.php';

$controller = new QuestionarioController();
$method = $_SERVER["REQUEST_METHOD"];

switch ($method) {
    case "POST":
        try {
            // Lê o JSON enviado no corpo da requisição
            $data = json_decode(file_get_contents("php://input"));

            // Verifica campos obrigatórios
            if (!empty($data->id_curso) && !empty($data->nm_questionario) && !empty($data->perguntas)) {

                // Instancia o questionário
                $questionario = new Questionario();
                $questionario->id_curso = $data->id_curso;
                $questionario->nm_questionario = $data->nm_questionario;
                $questionario->perguntas = [];

                // Monta as perguntas e alternativas
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

                // Chama o controller para inserir no banco
                if ($controller->criarQuestionario($questionario)) {
                    echo json_encode([
                        "status" => "success",
                        "message" => "Questionário criado com sucesso"
                    ]);
                } else {
                    http_response_code(500);
                    echo json_encode([
                        "status" => "error",
                        "message" => "Erro ao criar questionário"
                    ]);
                }
            } else {
                http_response_code(400);
                echo json_encode([
                    "status" => "error",
                    "message" => "Dados incompletos"
                ]);
            }

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                "status" => "error",
                "message" => $e->getMessage()
            ]);
        }
        break;

    case "GET":
        echo json_encode($controller->listarQuestionarios());
        break;

    default:
        http_response_code(405);
        echo json_encode(["status" => "error", "message" => "Método não permitido"]);
        break;
}