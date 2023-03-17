--------------------------------------------------------------------
-- Arquivo   : jogo_desafio_memoria.vhd
-- Projeto   : Experiencia 6 - Projeto do Jogo do Desafio da Memória
--------------------------------------------------------------------
-- Descricao : circuito da atividade 1 para Exp. 5 
--
--             
--
-- 
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor              Descricao
--     10/02/2023  1.0     Pedro H. Turini    versao inicial
--------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;

entity jogo_desafio_memoria is
    port (
        clock     : in  std_logic;
        reset     : in  std_logic;
        iniciar   : in  std_logic;
        ativar    : in  std_logic;
        botoes    : in  std_logic_vector(3 downto 0);
        leds      : out std_logic_vector(3 downto 0);
        pronto    : out std_logic;
        ganhou    : out std_logic;
        perdeu    : out std_logic;
        db_jogada                : out std_logic_vector(6 downto 0);
        db_rodada                : out std_logic_vector(6 downto 0);
        db_contagem              : out std_logic_vector(6 downto 0);
        db_memoria               : out std_logic_vector(6 downto 0);
        db_estado                : out std_logic_vector(6 downto 0)
    );
   end entity;

architecture inicial of jogo_desafio_memoria is

    component fluxo_dados is
        port (
              clock                    : in  std_logic;
              contaCR                  : in  std_logic;
              zeraCR                   : in  std_logic;
              contaE                   : in  std_logic;
              zeraE                    : in  std_logic;
              contaI                   : in  std_logic;
              escreve                  : in  std_logic;
              ativar                   : in  std_logic;
              chaves                   : in  std_logic_vector(3 downto 0);
              registraRC               : in  std_logic;
              limpaRC                  : in  std_logic;
              registraModo             : in  std_logic;
              registraSel              : in  std_logic;
              escreve_aleatorio        : in  std_logic;
              zeraT                    : in  std_logic;
              contaT                   : in  std_logic;
        --Saidas
              db_rodada                : out std_logic_vector(3 downto 0);
              enderecoIgualRodada      : out std_logic;
              db_contagem              : out std_logic_vector(3 downto 0);
              db_memoria               : out std_logic_vector(3 downto 0);
              jogada_correta           : out std_logic;
              jogada                   : out std_logic;
              fimL                     : out std_logic;
              fimE                     : out std_logic;
              fimT                     : out std_logic;
              fimI                     : out std_logic           
        );
    end component;

    component unidade_controle is 
        port ( 
            clock                : in  std_logic; 
            reset                : in  std_logic; 
            iniciar              : in  std_logic;
            fimL                 : in  std_logic;
            fimI                 : in  std_logic;  
            jogada               : in  std_logic;
            seleciona            : in  std_logic;
            enderecoIgualRodada  : in  std_logic;
            jogada_correta       : in  std_logic;
            timeout              : in  std_logic;
            zeraCR               : out std_logic;
            contaCR              : out std_logic;
            contaI               : out std_logic;
            limpaRC              : out std_logic;
            contaE               : out std_logic;
            zeraE                : out std_logic;
            zeraT                : out std_logic;
            registraRC           : out std_logic;
            registraSel          : out std_logic;
            ganhou               : out std_logic;
            perdeu               : out std_logic;
            pronto               : out std_logic;
			escreve				 : out std_logic;
            db_estado            : out std_logic_vector(3 downto 0)
        );
    end component;

component hexa7seg is
    port (
        hexa : in  std_logic_vector(3 downto 0);
        sseg : out std_logic_vector(6 downto 0)
    );
end component;

signal  db_jogada_s, db_estado_s, db_memoria_s, db_rodada_s, db_contagem_s : std_logic_vector(3 downto 0);
signal  modo, escreve_aleatorio, registraSel, fimI, contaI, fimL, escreve, enderecoIgualRodada, jogada_correta, fimT, zeraCR, contaCR, limpaRC, contaE, zeraE, zeraT, registraRC, jogada : std_logic;
signal  registraModo : std_logic_vector(1 downto 0);

begin

UC : unidade_controle
port map(
        clock     => clock,           
        reset       => reset,        
        iniciar    => iniciar,          
        fimL      => fimL,                  
        jogada        => jogada,
        enderecoIgualRodada  => enderecoIgualRodada,
        jogada_correta =>  jogada_correta,  
        timeout   => fimT,
        zeraCR    => zeraCR,        
        contaCR    =>contaCR,         
        limpaRC    => limpaRC,          
        contaE     => contaE,
        zeraE           => zeraE,   
        zeraT            => zeraT,
        seleciona        => seleciona,
        registraRC           =>registraRC,
        registraSel         => registraSel,
        ganhou       => ganhou,       
        perdeu       => perdeu,      
        pronto      => pronto,
		escreve     => escreve,
        db_estado => db_estado_s,
        fimI     => fimI
); 


DF : fluxo_dados
port map(
    clock      => clock,              
    contaCR          => contaCR,            
    zeraCR         => zeraCR,             
    contaE           => contaE,           
    zeraE            => zeraE,           
    escreve           => escreve, 
    ativar    => ativar,
    chaves          => botoes,             
    registraRC        => registraRC,         
    limpaRC          => limpaRC, 
    zeraT            => zeraT,         
    contaT            => '1', 
    contaI              => '1',         
    db_rodada               => db_rodada_s ,     
    enderecoIgualRodada      => enderecoIgualRodada,    
    db_contagem             => db_contagem_s,     
    db_memoria             => db_memoria_s, 
    db_jogada              => db_jogada_s,     
    jogada_correta         =>jogada_correta, 
    registraModo        => registraModo,
    modo                => modo,
    escreve_aleatorio   => escreve_aleatorio,
    registraSel         => registraSel,
    jogada              => jogada,          
    fimL                   => fimL,    
    fimE       => open,                  
    fimT     => fimT,
    fimI     => fimI
);

leds       <= db_jogada_s when (db_estado_s="0001" and db_rodada_s="0000")  else botoes;
db_memoria <= db_memoria_s;

hex0: hexa7seg
    port map(
        hexa => db_jogada_s,
        sseg => db_jogada
    );

hex3: hexa7seg
    port map(
        hexa => db_contagem_s,
        sseg => db_contagem
    );

hex4: hexa7seg
    port map(
        hexa => db_rodada_s,
        sseg => db_rodada
    );

hex5: hexa7seg
    port map(
        hexa => db_estado_s,
        sseg => db_estado
    );

end architecture;