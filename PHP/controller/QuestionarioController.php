<?php
require_once __DIR__ . '/../config/Banco.php';
require_once __DIR__ . '/../model/Questionario.php';
require_once __DIR__ . '/../model/Pergunta.php';
require_once __DIR__ . '/../model/Alternativa.php';

class QuestionarioController {
    private $conn;

    public function __construct() {
        $banco = new Banco();
        $this->conn = $banco->conectar();
        
        // --- CORREÇÃO CRÍTICA DE CODIFICAÇÃO ---
        // Força o banco a entregar os dados "como estão" (Latin1) sem tentar validar UTF-8.
        // Isso evita o erro SQLSTATE[22021] Invalid Byte Sequence.
        $this->conn->exec("SET client_encoding='ISO-8859-1'");
    }

    public function criarQuestionario(Questionario $questionario) {
        $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $this->conn->beginTransaction();

        try {
            // Inserir questionário
            $sql = "INSERT INTO tb_questionario (id_questionario, id_curso, nm_questionario)
                    VALUES (nextval('tb_questionario_id_questionario_seq'),:id_curso, :nm_questionario) RETURNING id_questionario";
            $stmt = $this->conn->prepare($sql);
            $stmt->bindValue(":id_curso", (int)$questionario->id_curso, PDO::PARAM_INT);
            $stmt->bindValue(":nm_questionario", $questionario->nm_questionario, PDO::PARAM_STR);
            $stmt->execute();
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            $id_questionario = (int)$row['id_questionario'];

            // Preparar statements
            $sqlPergunta = "INSERT INTO tb_pergunta (id_pergunta, id_questionario, ds_pergunta)
                            VALUES (nextval('tb_pergunta_id_pergunta_seq'),:id_questionario, :ds_pergunta) RETURNING id_pergunta";
            $stmtPerg = $this->conn->prepare($sqlPergunta);

            $sqlAlternativa = "INSERT INTO tb_alternativa (id_alternativa ,id_pergunta, ds_alternativa, correta)
                               VALUES (nextval('tb_alternativa_id_alternativa_seq'),:id_pergunta, :ds_alternativa, :correta)";
            $stmtAlt = $this->conn->prepare($sqlAlternativa);

            foreach ($questionario->perguntas as $pergunta) {
                $ds_pergunta = $pergunta->ds_pergunta ?? null;

                $stmtPerg->bindValue(":id_questionario", $id_questionario, PDO::PARAM_INT);
                $stmtPerg->bindValue(":ds_pergunta", $ds_pergunta, PDO::PARAM_STR);
                $stmtPerg->execute();
                $rowPerg = $stmtPerg->fetch(PDO::FETCH_ASSOC);
                $id_pergunta = (int)$rowPerg['id_pergunta'];

                foreach ($pergunta->alternativas as $alternativa) {
                    $ds_alternativa = $alternativa->ds_alternativa ?? null;
                    $correta = $alternativa->correta ? 1 : 0;

                    $stmtAlt->bindValue(":id_pergunta", $id_pergunta, PDO::PARAM_INT);
                    $stmtAlt->bindValue(":ds_alternativa", $ds_alternativa, PDO::PARAM_STR);
                    $stmtAlt->bindValue(":correta", $correta, PDO::PARAM_INT);
                    $stmtAlt->execute();
                }
            }

            $this->conn->commit();
            return true;

        } catch (Exception $e) {
            $this->conn->rollBack();
            throw $e;
        }
    }

    public function listarQuestionarios() {
        try {
            $sql = "SELECT * FROM tb_questionario ORDER BY id_questionario";
            $stmt = $this->conn->query($sql);
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            // Em caso de erro, retorna array vazio para não quebrar JSON
            return [];
        }
    }

    public function buscarCompleto($id_questionario) {
        try {
            $sql = "SELECT 
                        p.id_pergunta, 
                        p.ds_pergunta, 
                        a.id_alternativa, 
                        a.ds_alternativa, 
                        a.correta
                    FROM tb_pergunta p
                    LEFT JOIN tb_alternativa a ON p.id_pergunta = a.id_pergunta
                    WHERE p.id_questionario = :id
                    ORDER BY p.id_pergunta, a.id_alternativa";

            $stmt = $this->conn->prepare($sql);
            $stmt->bindValue(":id", $id_questionario, PDO::PARAM_INT);
            $stmt->execute();
            $linhas = $stmt->fetchAll(PDO::FETCH_ASSOC);

            $resultado = [];
            
            foreach ($linhas as $linha) {
                $idPerg = $linha['id_pergunta'];
                
                if (!isset($resultado[$idPerg])) {
                    $resultado[$idPerg] = [
                        'id_pergunta' => $idPerg,
                        'ds_pergunta' => $linha['ds_pergunta'],
                        'alternativas' => []
                    ];
                }

                if ($linha['id_alternativa']) { 
                    $resultado[$idPerg]['alternativas'][] = [
                        'id_alternativa' => $linha['id_alternativa'],
                        'ds_alternativa' => $linha['ds_alternativa'],
                        'correta'        => $linha['correta'] 
                    ];
                }
            }

            return array_values($resultado);

        } catch (PDOException $e) {
            return ["erro" => "Erro ao buscar detalhes: " . $e->getMessage()];
        }
    }
}
?>