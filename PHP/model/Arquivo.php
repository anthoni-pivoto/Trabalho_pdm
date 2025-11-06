<?php

class Arquivo
{
    public $id_midia;
    public $s_caminho;
    public $hash;
    public $s_nome_arquivo;

    public function __construct($id_midia, $s_caminho, $hash, $s_nome_arquivo)
    {
        $this->id_midia = $id_midia;
        $this->s_caminho = $s_caminho;
        $this->hash = $hash;
        $this->s_nome_arquivo = $s_nome_arquivo;
    }

}