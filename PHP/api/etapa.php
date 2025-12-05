<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

require_once __DIR__ . '/../config/Banco.php';
require_once __DIR__ . '/../controller/EtapaController.php';
require_once __DIR__ . '/../model/Etapa.php';

$controller = new EtapaController();
$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        // ====================================================================
        // LISTAR ETAPAS DE UM CURSO
        // ====================================================================
        if (isset($_GET['id_curso'])) {
            $idCurso = $_GET['id_curso'];
            
            try {
                $banco = new Banco();
                $conn = $banco->conectar();

                // QUERY CORRIGIDA COM AS COLUNAS QUE VOCЪ INFORMOU:
                // 1. Buscamos todas as IDs da tabela tb_etapa (alias 'e')
                // 2. Buscamos a descriчуo da tabela tb_tipo_etapa (alias 't')
                // 3. O INNER JOIN liga as duas pelo id_tipo_etapa
                
                $sql = "SELECT 
                            e.id_etapa, 
                            e.id_curso, 
                            e.id_tipo_etapa, 
                            e.id_questionario, 
                            e.id_midia,
                            t.s_descricao
                        FROM tb_etapa e
                        INNER JOIN tb_tipo_etapa t ON e.id_tipo_etapa = t.id_tipo_etapa
                        WHERE e.id_curso = :id_curso";

                $stmt = $conn->prepare($sql);
                $stmt->bindParam(':id_curso', $idCurso, PDO::PARAM_INT);
                $stmt->execute();
                $resultado = $stmt->fetchAll(PDO::FETCH_ASSOC);

                echo json_encode($resultado);

            } catch (PDOException $e) {
                http_response_code(500);
                echo json_encode(["erro" => "Erro SQL: " . $e->getMessage()]);
            }
        } 
        // LISTAR TUDO (LEGADO)
        else {
            echo json_encode($controller->listar());
        }
        break;

    case 'POST':
        $dados = json_decode(file_get_contents("php://input"));
        if (isset($dados->id_curso) && isset($dados->id_tipo_etapa)) {
            $etapa = new Etapa($dados->id_curso, $dados->id_tipo_etapa);
            if ($controller->criar($etapa)) {
                http_response_code(201); 
                echo json_encode(["sucesso" => true]);
            } else {
                http_response_code(500);
            }
        } else {
            http_response_code(400); 
            echo json_encode(["erro" => "Dados incompletos"]);
        }
        break;

    case 'DELETE':
        $dados = json_decode(file_get_contents("php://input"));
        $id_etapa = $dados->id_etapa ?? $_GET['id_etapa'] ?? null;
        if ($id_etapa) {
            if ($controller->deletar($id_etapa)) {
                echo json_encode(["sucesso" => true]);
            } else {
                http_response_code(500);
            }
        } else {
            echo json_encode(["erro" => "Informe o ID"]);
        }
        break;

    default:
        http_response_code(405);
        echo json_encode(["erro" => "Mщtodo nуo permitido"]);
}
?>