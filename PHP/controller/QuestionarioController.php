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
    }

 public function criarQuestionario(Questionario $questionario) {
    // Recomendo garantir que o PDO lance exceções:
    $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $this->conn->beginTransaction();

    try {
        // Inserir questionário (deixando o DB cuidar da sequence)
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

        // Se perguntas não existir ou não for iterável, foreach lança warning/exception naturalmente
        foreach ($questionario->perguntas as $pergunta) {
            $ds_pergunta = $pergunta->ds_pergunta ?? null;

            // inserir pergunta
            $stmtPerg->bindValue(":id_questionario", $id_questionario, PDO::PARAM_INT);
            $stmtPerg->bindValue(":ds_pergunta", $ds_pergunta, PDO::PARAM_STR);
            $stmtPerg->execute();
            $rowPerg = $stmtPerg->fetch(PDO::FETCH_ASSOC);
            $id_pergunta = (int)$rowPerg['id_pergunta'];

            foreach ($pergunta->alternativas as $alternativa) {
                $ds_alternativa = $alternativa->ds_alternativa ?? null;
                $correta_raw = $alternativa->correta ?? false;

                // converte para 0/1
                $correta_val = filter_var($correta_raw, FILTER_VALIDATE_BOOLEAN, FILTER_NULL_ON_FAILURE);
                if ($correta_val === null) {
                    $correta_val = (bool)$correta_raw;
                }
                $correta_int = $correta_val ? 1 : 0;

                $stmtAlt->bindValue(":id_pergunta", $id_pergunta, PDO::PARAM_INT);
                $stmtAlt->bindValue(":ds_alternativa", $ds_alternativa, PDO::PARAM_STR);
                $stmtAlt->bindValue(":correta", $correta_int, PDO::PARAM_INT);
                $stmtAlt->execute();
            }
        }

        $this->conn->commit();
        return true;

    } catch (\Exception $e) {
        // rollback e re-lança — assim o erro "aparece naturalmente" pra camada que chamou
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
            echo json_encode(["erro" => "Falha ao listar questionários: " . $e->getMessage()]);
            return [];
        }
    }
}