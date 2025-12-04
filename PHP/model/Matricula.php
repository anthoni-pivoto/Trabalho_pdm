<?php
class Matricula {
    public $id_usuario;
    public $id_curso;
    public $s_matricula;

    function __construct($id_usuario, $id_curso, $s_matricula) {
        $this->id_usuario = $id_usuario;
        $this->id_curso = $id_curso;
        $this->s_matricula = $s_matricula;
    }
}