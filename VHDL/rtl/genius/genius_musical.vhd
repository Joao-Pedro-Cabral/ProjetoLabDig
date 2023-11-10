--------------------------------------------------------------------
-- Arquivo   : genius_musical.vhd
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

entity genius_musical is
    port (
        clock                    : in  std_logic;
        reset                    : in  std_logic;
        iniciar                  : in  std_logic;
        ativar                   : in  std_logic;
        chaves                   : in  std_logic_vector(5 downto 0);
        echo                     : in  std_logic;
        sel_db                   : in  std_logic;
        trigger                  : out std_logic;
        pwm                      : out std_logic;
        pwm2                     : out std_logic;
        notas                    : out std_logic_vector(3 downto 0); -- simulacao
        jogador                  : out std_logic;
        ganhou                   : out std_logic;
        perdeu                   : out std_logic;
        db_hex0                  : out std_logic_vector(6 downto 0);
        db_hex1                  : out std_logic_vector(6 downto 0);
        db_hex2                  : out std_logic_vector(6 downto 0);
        db_hex3                  : out std_logic_vector(6 downto 0);
        db_hex4                  : out std_logic_vector(6 downto 0);
        db_hex5                  : out std_logic_vector(6 downto 0);
        db_modo                  : out std_logic_vector(1 downto 0)
    );
   end entity;

architecture inicial of genius_musical is

    component fluxo_dados is
        port(
            clock                    : in  std_logic;
            ativar                   : in  std_logic;
            chaves                   : in  std_logic_vector(5 downto 0);
            echo                     : in  std_logic;
            zeraCR                   : in  std_logic;
            zeraI                    : in  std_logic;
            zeraE                    : in  std_logic;
            zeraT                    : in  std_logic;
            limpa                    : in  std_logic;
            contaCR                  : in  std_logic;
            contaI                   : in  std_logic;
            contaE                   : in  std_logic;
            contaT                   : in  std_logic;
            medir_nota               : in  std_logic;
            escreve                  : in  std_logic;
            escreve_aleatorio        : in  std_logic;
            registraRC               : in  std_logic;
            registraConfig           : in  std_logic;
            notaSel                  : in  std_logic;
            ganhou                   : in  std_logic;
            perdeu                   : in  std_logic;
            trigger                  : out std_logic;
            pwm                      : out std_logic;
            pwm2                     : out std_logic;
            notas                    : out std_logic_vector(3 downto 0);
            modo                     : out std_logic_vector(1 downto 0);
            enderecoIgualRodada      : out std_logic;
            jogada_correta           : out std_logic;
            jogada                   : out std_logic;
            configurado              : out std_logic;
            jogador                  : out std_logic;
            fimL                     : out std_logic;
            fimE                     : out std_logic;
            fimT                     : out std_logic;
            fimI                     : out std_logic;
            db_rodada                : out std_logic_vector(3 downto 0);
            db_jogada                : out std_logic_vector(3 downto 0);
            db_contagem              : out std_logic_vector(3 downto 0);
            db_memoria               : out std_logic_vector(3 downto 0);
            db_sensor                : out std_logic_vector(3 downto 0);
            db_medida                : out std_logic_vector(11 downto 0)
        );
    end component;

    component unidade_controle is
        port ( 
            clock                : in  std_logic;
            reset                : in  std_logic;
            iniciar              : in  std_logic;
            jogada               : in  std_logic;
            configurado          : in  std_logic;
            jogada_correta       : in  std_logic;
            enderecoIgualRodada  : in  std_logic;
            modo                 : in  std_logic_vector(1 downto 0);
            fimL                 : in  std_logic;
            fimI                 : in  std_logic;
            timeout              : in  std_logic;
            limpa                : out std_logic;
            zeraCR               : out std_logic;
            zeraE                : out std_logic;
            zeraI                : out std_logic;
            zeraT                : out std_logic;
            contaCR              : out std_logic;
            contaE               : out std_logic;
            medir_nota           : out std_logic;
            registraRC           : out std_logic;
            escreve              : out std_logic;
            escreve_aleatorio    : out std_logic;
            registraConfig       : out std_logic;
            notaSel              : out std_logic;
            ganhou               : out std_logic;
            perdeu               : out std_logic;
            db_estado            : out std_logic_vector(4 downto 0)
        );
    end component;

  component hexa7seg is
    port (
        hexa : in  std_logic_vector(4 downto 0);
        sseg : out std_logic_vector(6 downto 0)
    );
  end component;

signal  db_sensor_s, db_notas_s, db_medida0_s, db_medida1_s, db_medida2_s, db_estado_s, db_jogada_s, db_memoria_s, db_rodada_s, db_contagem_s : std_logic_vector(4 downto 0);
signal  db_sensor, db_notas, db_medida0, db_medida1, db_medida2, db_estado, db_jogada, db_memoria, db_rodada, db_contagem : std_logic_vector(6 downto 0);
signal  s_ganhou, s_perdeu, configurado, medir_nota, zeraI, limpa, notaSel, escreve_aleatorio, registraConfig, fimI, contaI, fimL, escreve, enderecoIgualRodada, jogada_correta, fimT, zeraCR, contaCR, contaE, zeraE, zeraT, registraRC, jogada : std_logic;
signal  modo : std_logic_vector(1 downto 0);
signal  db_medida_s: std_logic_vector(11 downto 0);

begin

UC : unidade_controle
  port map(
    clock                => clock,
    reset                => reset,
    iniciar              => iniciar,
    jogada               => jogada,
    jogada_correta       => jogada_correta,
    enderecoIgualRodada  => enderecoIgualRodada,
    modo                 => modo,
    fimL                 => fimL,
    fimI                 => fimI,
    timeout              => fimT,
    limpa                => limpa,
    zeraCR               => zeraCR,
    zeraE                => zeraE,
    zeraI                => zeraI,
    zeraT                => zeraT,
    contaCR              => contaCR,
    contaE               => contaE,
    configurado          => configurado,
    medir_nota           => medir_nota,
    registraRC           => registraRC,
    escreve              => escreve,
    escreve_aleatorio    => escreve_aleatorio,
    registraConfig       => registraConfig,
    notaSel              => notaSel,
    ganhou               => s_ganhou,
    perdeu               => s_perdeu,
    db_estado            => db_estado_s
); 


DF : fluxo_dados
  port map(
    clock               => clock,
    ativar              => ativar,
    chaves              => chaves,
    echo                => echo,
    zeraCR              => zeraCR,
    zeraI               => zeraI,
    zeraE               => zeraE,
    zeraT               => zeraT,
    limpa               => limpa,
    contaCR             => contaCR,
    contaI              => '1',
    contaE              => contaE,
    contaT              => '1',
    medir_nota          => medir_nota,
    escreve             => escreve,
    escreve_aleatorio   => escreve_aleatorio,
    registraRC          => registraRC,
    registraConfig      => registraConfig,
    configurado         => configurado,
    notaSel             => notaSel,
    ganhou              => s_ganhou,
    perdeu              => s_perdeu,
    trigger             => trigger,
    pwm                 => pwm,
    pwm2                => pwm2,
    notas               => notas, -- simulacao
    -- notas               => db_notas_s(3 downto 0), -- quartus
    modo                => modo,
    enderecoIgualRodada => enderecoIgualRodada,
    jogada_correta      => jogada_correta,
    jogada              => jogada,
    jogador             => jogador,
    fimL                => fimL,
    fimE                => open,
    fimT                => fimT,
    fimI                => fimI,
    db_rodada           => db_rodada_s(3 downto 0),
    db_jogada           => db_jogada_s(3 downto 0),
    db_contagem         => db_contagem_s(3 downto 0),
    db_memoria          => db_memoria_s(3 downto 0),
    db_sensor           => db_sensor_s(3 downto 0),
    db_medida           => db_medida_s
  );

  ganhou <= s_ganhou;
  perdeu <= s_perdeu;

  -- debug
  db_jogada_s(4)   <= '0';
  db_memoria_s(4)  <= '0';
  db_contagem_s(4) <= '0';
  db_rodada_s(4)   <= '0';
  db_notas_s(4)    <= '0';
  db_sensor_s(4)   <= '0';
  db_notas_s(3 downto 0) <= "0000"; -- simulacao 
  db_medida0_s     <= '0' & db_medida_s(3 downto 0);
  db_medida1_s     <= '0' & db_medida_s(7 downto 4);
  db_medida2_s     <= '0' & db_medida_s(11 downto 8);

hex0: hexa7seg
    port map(
        hexa => db_jogada_s,
        sseg => db_jogada
    );

hex01: hexa7seg
    port map(
        hexa => db_medida0_s,
        sseg => db_medida0
    );

hex1: hexa7seg
    port map(
        hexa => db_memoria_s,
        sseg => db_memoria
    );

hex11: hexa7seg
    port map(
        hexa => db_medida1_s,
        sseg => db_medida1
    );


hex2: hexa7seg
    port map(
        hexa => db_notas_s,
        sseg => db_notas
    );

hex21: hexa7seg
    port map(
        hexa => db_medida2_s,
        sseg => db_medida2
    );

hex3: hexa7seg
    port map(
        hexa => db_contagem_s,
        sseg => db_contagem
    );

hex31: hexa7seg
    port map(
        hexa => db_sensor_s,
        sseg => db_sensor
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

  db_hex0    <= db_jogada  when sel_db = '0' else db_medida0;
  db_hex1    <= db_memoria when sel_db = '0' else db_medida1;
  db_hex2    <= db_notas   when sel_db = '0' else db_medida2;
  db_hex3    <= db_contagem when sel_db = '0' else db_sensor;
  db_hex4    <= db_rodada;
  db_hex5    <= db_estado;
  db_modo    <= modo;

end architecture;