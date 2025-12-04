<?php
require_once __DIR__ . '/../config/Banco.php';
require_once __DIR__ . '/../model/Matricula.php';

class MatriculaController {

    private $conn;

    public function __construct() {
        $banco = new Banco();
        $this->conn = $banco->conectar();
    }

    public function criarMatricula(Matricula $matricula) {
        try {
            $sql = "INSERT INTO tb_matricula 
                    (id_usuario, id_curso)
                    VALUES (:id_usuario, :id_curso)";

            $stmt = $this->conn->prepare($sql);

            $stmt->bindValue(":id_usuario", $matricula->id_usuario);
            $stmt->bindValue(":id_curso", $matricula->id_curso);

            return $stmt->execute();

        } catch (PDOException $e) {
            echo json_encode(["erro" => "Falha ao criar matrícula: " . $e->getMessage()]);
            return false;
        }
    }

    public function listarMatriculas() {
        try {
            $sql = "SELECT * FROM tb_matricula ORDER BY s_matricula";
            $stmt = $this->conn->query($sql);
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            echo json_encode(["erro" => "Falha ao listar matrículas: " . $e->getMessage()]);
            return [];
        }
    }

    public function listarMatriculasPorCurso($id_curso) {
        try {
            $sql = "SELECT * FROM tb_matricula 
                    WHERE id_curso = :id_curso
                    ORDER BY s_matricula";

            $stmt = $this->conn->prepare($sql);
            $stmt->bindValue(":id_curso", $id_curso, PDO::PARAM_INT);
            $stmt->execute();

            return $stmt->fetchAll(PDO::FETCH_ASSOC);

        } catch (PDOException $e) {
            echo json_encode(["erro" => "Falha ao listar matrículas: " . $e->getMessage()]);
            return [];
        }
    }

    public function listarMatriculasPorUsuario($id_usuario) {
        try {
            $sql = "SELECT * FROM tb_matricula 
                    WHERE id_usuario = :id_usuario
                    ORDER BY s_matricula";

            $stmt = $this->conn->prepare($sql);
            $stmt->bindValue(":id_usuario", $id_usuario, PDO::PARAM_INT);
            $stmt->execute();

            return $stmt->fetchAll(PDO::FETCH_ASSOC);

        } catch (PDOException $e) {
            echo json_encode(["erro" => "Falha ao listar matrículas: " . $e->getMessage()]);
            return [];
        }
    }

    public function buscarMatricula($id_usuario, $id_curso) {
        try {
            $sql = "SELECT * FROM tb_matricula 
                    WHERE id_usuario = :id_usuario
                    AND id_curso = :id_curso";

            $stmt = $this->conn->prepare($sql);
            $stmt->bindValue(":id_usuario", $id_usuario, PDO::PARAM_INT);
            $stmt->bindValue(":id_curso", $id_curso, PDO::PARAM_INT);
            $stmt->execute();

            return $stmt->fetch(PDO::FETCH_ASSOC);

        } catch (PDOException $e) {
            echo json_encode(["erro" => "Falha ao buscar matrícula: " . $e->getMessage()]);
            return null;
        }
    }

    public function deletarMatricula($id_usuario, $id_curso) {
        try {
            $sql = "DELETE FROM tb_matricula 
                    WHERE id_usuario = :id_usuario
                    AND id_curso = :id_curso";

            $stmt = $this->conn->prepare($sql);
            $stmt->bindValue(":id_usuario", $id_usuario, PDO::PARAM_INT);
            $stmt->bindValue(":id_curso", $id_curso, PDO::PARAM_INT);
            $stmt->execute();

            return $stmt->rowCount() > 0;

        } catch (PDOException $e) {
            echo json_encode(["erro" => "Falha ao deletar matrícula: " . $e->getMessage()]);
            return false;
        }
    }
}
