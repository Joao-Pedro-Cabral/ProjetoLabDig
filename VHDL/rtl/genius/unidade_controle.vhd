--------------------------------------------------------------------
-- Arquivo   : unidade_controle.vhd
-- Projeto   : Experiencia 6 - Projeto do Jogo do Desafio da Memória
--------------------------------------------------------------------
-- Descricao : unidade de controle 
--
--             1) codificação VHDL (maquina de Moore)
--
--             2) definicao de valores da saida de depuracao
--                db_estado
-- 
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     20/01/2022  1.0     Edson Midorikawa  versao inicial
--     22/01/2023  1.1     Edson Midorikawa  revisao
--     27/01/2023  1.2     João Pedro C. M.  versão desafio
--     01/02/2023  1.3     Pedro H. Turini   adição do estado espera
--     06/02/2022  1.4     João Pedro C.M.   versão desafio
--     08/02/2023  1.5     João Pedro C.M.   exp5
--     17/03/2023  1.6     Adaptacao 
--------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;

entity unidade_controle is 
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
        enviar_config        : out std_logic;
        enviar_jogada        : out std_logic;
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
end entity;

architecture fsm of unidade_controle is
    type t_estado is (inicial, espera_config, registra_config, envia_config, toca_nota_inicial, inicio_rodada, proxima_rodada,
                      ultima_rodada, espera_jogada, registra_jogada, compara_jogada, envia_jogada, proxima_jogada,
                      envia_fim_ganhou, fim_ganhou, envia_fim_perdeu, fim_perdeu, envia_fim_timeout, fim_timeout,
                      envia_ultima_jogada, checa_modo, escreve_jogada, envia_nova_jogada, inicia_nova_jogada,
                      espera_nova_jogada, registra_nova_jogada, inicia_mostra_jogada, mostra_jogada, espera_mostra_jogada,
                      espera_iniciar, envia_mostra_jogada);
    signal Eatual, Eprox: t_estado;
begin

    -- memoria de estado
    process (clock,reset)
    begin
        if reset='1' then
            Eatual <= inicial;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

    -- logica de proximo estado
    Eprox <=
        espera_iniciar            when  Eatual=inicial else
        espera_iniciar            when  Eatual=espera_iniciar and iniciar='0' else
        espera_config             when  Eatual=espera_iniciar and iniciar='1' else
        espera_config             when  Eatual=espera_config and configurado='0' else
        registra_config           when  Eatual=espera_config and configurado='1' else
        envia_config              when  Eatual=registra_config else
        toca_nota_inicial         when  Eatual=envia_config else
        toca_nota_inicial         when  Eatual=toca_nota_inicial and fimI = '0' else
        inicio_rodada             when  Eatual=toca_nota_inicial and fimI = '1' else
        espera_jogada             when  Eatual=inicio_rodada else 
        espera_jogada             when  Eatual=espera_jogada and jogada='0' and timeout = '0' else
        registra_jogada           when  Eatual=espera_jogada and jogada='1' and timeout = '0' else
        envia_fim_timeout         when  Eatual=espera_jogada and timeout = '1' else
        compara_jogada            when  Eatual=registra_jogada else
        envia_jogada              when  Eatual=compara_jogada and (enderecoIgualRodada='0' and jogada_correta = '1') else
        ultima_rodada             when  Eatual=compara_jogada and (enderecoIgualRodada='1' and jogada_correta = '1') else
        envia_fim_perdeu          when  Eatual=compara_jogada and jogada_correta = '0' else
        proxima_jogada            when  Eatual=envia_jogada else
        espera_jogada             when  Eatual=proxima_jogada else
        envia_fim_ganhou          when  Eatual=ultima_rodada and fimL = '1' else
        envia_ultima_jogada       when  Eatual=ultima_rodada and fimL = '0' else
        checa_modo                when  Eatual=envia_ultima_jogada else
        inicia_nova_jogada        when  Eatual=checa_modo and modo="10" else
        espera_mostra_jogada      when  Eatual=checa_modo and (not (modo(0) = '0' and modo(1) = '1')) else
        espera_nova_jogada        when  Eatual=inicia_nova_jogada else
        espera_nova_jogada        when  Eatual=espera_nova_jogada and jogada = '0' else
        registra_nova_jogada      when  Eatual=espera_nova_jogada and jogada = '1' else
        escreve_jogada            when  Eatual=registra_nova_jogada else
        envia_nova_jogada         when  Eatual=escreve_jogada else
        proxima_rodada            when  Eatual=envia_nova_jogada else
        inicio_rodada             when  Eatual=proxima_rodada else
        espera_mostra_jogada      when  Eatual=espera_mostra_jogada and fimI = '0' else
        inicia_mostra_jogada      when  Eatual=espera_mostra_jogada and fimI = '1' else
        envia_mostra_jogada       when  Eatual=inicia_mostra_jogada else
        mostra_jogada             when  Eatual=envia_mostra_jogada else
        mostra_jogada             when  Eatual=mostra_jogada and fimI='0' else
        proxima_rodada            when  Eatual=mostra_jogada and fimI='1' else
        fim_perdeu                when  Eatual=envia_fim_perdeu else
        fim_perdeu                when  Eatual=fim_perdeu  and iniciar='0' else
        espera_config             when  Eatual=fim_perdeu  and iniciar='1' else
        fim_ganhou                when  Eatual=envia_fim_ganhou else
        fim_ganhou                when  Eatual=fim_ganhou  and iniciar='0' else
        espera_config             when  Eatual=fim_ganhou  and iniciar='1' else
        fim_timeout               when  Eatual=envia_fim_timeout else
        fim_timeout               when  Eatual=fim_timeout and iniciar='0' else
        espera_config             when  Eatual=fim_timeout and iniciar='1' else
        inicial; 

    -- logica de saída (maquina de Moore)
    with Eatual select
        zeraCR <=      '1' when registra_config,
                       '0' when others;
    
    with Eatual select
        limpa   <=  '1' when inicial,
                    '0' when others;
                    
    with Eatual select
        zeraE <=      '1' when inicio_rodada,
                      '0' when others;

    with Eatual select
        registraRC <=  '1' when registra_jogada | registra_nova_jogada,
                       '0' when others;

    with Eatual select
        contaCR <=     '1' when proxima_rodada,
                       '0' when others;
    
    with Eatual select
        contaE <=     '1' when proxima_jogada | checa_modo,
                      '0' when others;

    with Eatual select
        ganhou <=      '1' when fim_ganhou | envia_fim_ganhou,
                       '0' when others;

    with Eatual select
        perdeu  <=    '1' when fim_perdeu | envia_fim_perdeu | fim_timeout | envia_fim_timeout,
                      '0' when others;

    with Eatual select
        zeraT   <=  '1' when inicio_rodada | proxima_jogada,
                    '0' when others;

  with Eatual select
        escreve <=  '1' when escreve_jogada | inicia_mostra_jogada | registra_config,
                    '0' when others;

    with Eatual select
        registraConfig   <= '1' when registra_config,
                            '0' when others;

    with Eatual select 
        notaSel     <=  '1' when envia_config | envia_mostra_jogada | toca_nota_inicial | mostra_jogada,
                        '0' when others;

    with Eatual select 
        zeraI <= '1' when inicia_mostra_jogada | envia_config | checa_modo,
                 '0' when others;

    with Eatual select 
        escreve_aleatorio <= '1' when registra_config,
                             '0' when others;

    with Eatual select
        medir_nota <= '1' when inicio_rodada | inicia_nova_jogada | proxima_jogada,
                      '0' when others;

    with Eatual select
        enviar_config <= '1' when envia_config,
                         '0' when others;

    with Eatual select
        enviar_jogada <= '1' when envia_fim_timeout | envia_fim_perdeu | envia_fim_ganhou | envia_jogada |
                                  envia_nova_jogada | envia_mostra_jogada | envia_ultima_jogada,
                         '0' when others;

    -- saida de depuracao (db_estado)
    with Eatual select
        db_estado <= "00000" when inicial,              -- 0
                     "00001" when toca_nota_inicial,    -- 1
                     "00010" when inicio_rodada,        -- 2
                     "00011" when ultima_rodada,        -- 3
                     "00100" when registra_jogada,      -- 4
                     "00101" when compara_jogada,       -- 5
                     "00110" when proxima_jogada,       -- 6
                     "00111" when proxima_rodada,       -- 7
                     "01000" when espera_nova_jogada,   -- 8
                     "01001" when escreve_jogada,       -- 9
                     "01010" when espera_config,        -- A
                     "01011" when registra_config,      -- B
                     "01100" when fim_ganhou,           -- C
                     "01101" when fim_perdeu,           -- D
                     "01110" when fim_timeout,          -- E
                     "01111" when espera_jogada,        -- F
                     "10000" when envia_config,         -- 10
                     "10001" when checa_modo,           -- 11
                     "10010" when mostra_jogada,        -- 12
                     "10011" when espera_mostra_jogada, -- 13
                     "10100" when inicia_mostra_jogada, -- 14
                     "10101" when inicia_nova_jogada,   -- 15
                     "10110" when registra_nova_jogada, -- 16
                     "10111" when envia_jogada,         -- 17
                     "11000" when envia_fim_timeout,    -- 18
                     "11001" when envia_fim_perdeu,     -- 19
                     "11010" when envia_fim_ganhou,     -- 1A
                     "11011" when envia_ultima_jogada,  -- 1B
                     "11100" when envia_mostra_jogada,  -- 1C
                     "11101" when envia_nova_jogada,    -- 1D
                     "11110" when espera_iniciar,       -- 1E
                     "00000" when others;

end architecture fsm;