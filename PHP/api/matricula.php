<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, DELETE");
header("Access-Control-Allow-Headers: Content-Type");

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require_once __DIR__ . '/../controller/MatriculaController.php';
require_once __DIR__ . '/../model/Matricula.php';

$controller = new MatriculaController();
$method = $_SERVER["REQUEST_METHOD"];

switch ($method) {

    case "POST":
        try {
            $data = json_decode(file_get_contents("php://input"));
	
            if (!empty($data->id_usuario) && !empty($data->id_curso)) {

                $matricula = new Matricula(
                    $data->id_usuario,
                    $data->id_curso,
                    null
                );
		
                if ($controller->criarMatricula($matricula)) {
                    echo json_encode([
                        "status" => "success",
                        "message" => "Matrícula criada com sucesso"
                    ]);
                } else {
                    http_response_code(500);
                    echo json_encode([
                        "status" => "error",
                        "message" => "Erro ao criar matrícula"
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
                "message" => "Erro ao criar matrícula: " . $e->getMessage()
            ]);
        }
        break;
    case "GET":
        try {
            if (isset($_GET["id_curso"])) {
                $matriculas = $controller->listarMatriculasPorCurso($_GET["id_curso"]);
                echo json_encode($matriculas);
                break;
            }
            if (isset($_GET["id_usuario"])) {
                $matriculas = $controller->listarMatriculasPorUsuario($_GET["id_usuario"]);
                echo json_encode($matriculas);
                break;
            }
            echo json_encode($controller->listarMatriculas());

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                "status" => "error",
                "message" => "Erro ao buscar matrículas: " . $e->getMessage()
            ]);
        }
        break;
    case "DELETE":
        try {
            if (!empty($_GET["id_usuario"]) && !empty($_GET["id_curso"])) {

                if ($controller->deletarMatricula($_GET["id_usuario"], $_GET["id_curso"])) {
                    echo json_encode([
                        "status" => "success",
                        "message" => "Matrícula excluída com sucesso"
                    ]);
                } else {
                    http_response_code(500);
                    echo json_encode([
                        "status" => "error",
                        "message" => "Erro ao excluir matrícula"
                    ]);
                }

            } else {
                http_response_code(400);
                echo json_encode([
                    "status" => "error",
                    "message" => "Parâmetros id_usuario e id_curso são obrigatórios"
                ]);
            }

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                "status" => "error",
                "message" => "Erro ao excluir matrícula: " . $e->getMessage()
            ]);
        }
        break;
    default:
        http_response_code(405);
        echo json_encode([
            "status" => "error",
            "message" => "Método não permitido"
        ]);
        break;
}
