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
        fimL                 : in  std_logic;
        fimI                 : in  std_logic;
        jogada               : in  std_logic;
        enderecoIgualRodada  : in  std_logic;
        jogada_correta       : in  std_logic;
        modo                 : in  std_logic_vector(1 downto 0);
        timeout              : in  std_logic;
        zeraCR               : out std_logic;
        contaCR              : out std_logic;
        limpaRC              : out std_logic;
        contaE               : out std_logic;
        zeraE                : out std_logic;
        zeraT                : out std_logic;
        registraRC           : out std_logic;
        ganhou               : out std_logic;
        perdeu               : out std_logic;
        pronto               : out std_logic;
		escreve				 : out std_logic;
        registraSel          : out std_logic;
        escreve_aleatório    : out std_logic;
        zeraI                : out std_logic;
        ledSel               : out std_logic;
        db_estado            : out std_logic_vector(4 downto 0)
    );
end entity;

architecture fsm of unidade_controle is
    type t_estado is (inicial, espera_dificuldade, registra_dificuldade, inicializa_elementos, inicio_rodada, proxima_rodada, ultima_rodada, espera_jogada, registra_jogada, compara_jogada, proxima_jogada, fim_ganhou, fim_perdeu, fim_timeout, escreve_jogada, espera_nova_jogada, mostra_jogada, espera_mostra_jogada, registra_modo, espera_modo);
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
        inicial                   when  Eatual=inicial and iniciar='0' else
        espera_modo               when  Eatual=inicial and iniciar='1' else
        espera_modo               when  Eatual=espera_modo and jogada='0' else
        registra_modo             when  Eatual=espera_modo and jogada='1' else
        espera_dificuldade        when  Eatual=registra_modo else
        espera_dificuldade        when  Eatual=espera_dificuldade and jogada='0' else
        registra_dificuldade      when  Eatual=espera_dificuldade and jogada = '0' else
        inicializa_elementos      when  Eatual=registra_dificuldade else
        inicializa_elementos      when  Eatual=inicializa_elementos and fimI = '0' else
        inicio_rodada             when  Eatual=inicializa_elementos and fimI = '1' else
        espera_jogada             when  Eatual=inicio_rodada else 
        espera_jogada             when  Eatual=espera_jogada and jogada='0' and timeout = '0' else
        registra_jogada           when  Eatual=espera_jogada and jogada='1' and timeout = '0' else
        fim_timeout               when  Eatual=espera_jogada and timeout = '1' else
        compara_jogada            when  Eatual=registra_jogada else
        proxima_jogada            when  Eatual=compara_jogada and (enderecoIgualRodada='0' and jogada_correta = '1') else
        ultima_rodada             when  Eatual=compara_jogada and (enderecoIgualRodada='1' and jogada_correta = '1') else
        fim_perdeu                when  Eatual=compara_jogada and jogada_correta = '0' else
        espera_jogada             when  Eatual=proxima_jogada else
        espera_nova_jogada        when  Eatual=ultima_rodada and fimL = '0' and modo="10" else
        fim_ganhou                when  Eatual=ultima_rodada and fimL = '1' else
		espera_nova_jogada        when  Eatual=espera_nova_jogada and jogada = '0' else
		escreve_jogada            when  Eatual=espera_nova_jogada and jogada = '1' else

        espera_mostra_jogada      when  Eatual=ultima_rodada and fimL='0' and modo!="10" else
        espera_mostra_jogada      when  Eatual=espera_mostra_jogada and jogada='1' else
        mostra_jogada             when  Eatual=espera_mostra_jogada and jogada='0' else
        mostra_jogada             when  Eatual=mostra_jogada and fimI='0' else
		proxima_rodada			  when  Eatual=escreve_jogada else
        proxima_rodada            when  Eatual=mostra_jogada and fimI='1' else   
        inicio_rodada             when  Eatual=proxima_rodada else
        fim_perdeu                when  Eatual=fim_perdeu and iniciar='0' else
        espera_dificuldade        when  Eatual=fim_perdeu and iniciar='1' else
        fim_ganhou                when  Eatual=fim_ganhou and iniciar='0' else
        espera_dificuldade        when  Eatual=fim_ganhou and iniciar='1' else
        fim_timeout               when  Eatual=fim_timeout and iniciar='0' else
        espera_dificuldade        when  Eatual=fim_timeout and iniciar='1' else
        inicial; 

    -- logica de saída (maquina de Moore)
    with Eatual select
        zeraCR <=      '1' when inicializa_elementos,
                       '0' when others;
    
    with Eatual select
        limpaRC <=  '1' when inicial,
                    '0' when others;
                    
    with Eatual select
        zeraE <=      '1' when inicio_rodada,
                      '0' when others;

    with Eatual select
        registraRC <=  '1' when registra_jogada | espera_nova_jogada,
                       '0' when others;

    with Eatual select
        contaCR <=     '1' when proxima_rodada,
                       '0' when others;
    
    with Eatual select
        contaE <=     '1' when proxima_jogada | ultima_rodada,
                      '0' when others;

    with Eatual select
        pronto <=     '1' when fim_ganhou | fim_perdeu | fim_timeout,
                      '0' when others;

    with Eatual select
        ganhou <=      '1' when fim_ganhou,
                       '0' when others;

    with Eatual select
        perdeu  <=    '1' when fim_perdeu | fim_timeout,
                      '0' when others;

    with Eatual select
        zeraT   <=  '1' when inicio_rodada | proxima_jogada,
                    '0' when others;
					  
	 with Eatual select
		escreve <=  '1' when escreve_jogada | espera_mostra_jogada,
					'0' when others;

    with Eatual select
        registraSel    <=   '1' when registra_dificuldade,
                            '0' when others;

    with Eatual select 
        ledSel <= '1' when espera_mostra_jogada,
                '0' when others;

    with Eatual select 
        zeraI <= '1' when espera_mostra_jogada | registra_dificuldade,
                '0' when others;  

    -- saida de depuracao (db_estado)
    with Eatual select
        db_estado <= "00000" when inicial,              -- 0
                     "00001" when inicializa_elementos, -- 1
                     "00010" when inicio_rodada,        -- 2
                     "00011" when ultima_rodada,        -- 3
                     "00100" when registra_jogada,      -- 4
                     "00101" when compara_jogada,       -- 5
                     "00110" when proxima_jogada,       -- 6
                     "00111" when proxima_rodada,       -- 7
					 "01000" when espera_nova_jogada,   -- 8
					 "01001" when escreve_jogada,       -- 9
                     "01010" when espera_dificuldade,   -- A
                     "01011" when registra_dificuldade, -- B
                     "01100" when fim_ganhou,           -- C
                     "01101" when fim_perdeu,           -- D
                     "01110" when fim_timeout,          -- E
                     "01111" when espera_jogada,        -- F
                     "10000" when espera_modo,          --10 
                     "10001" when registra_modo,        --11
                     "10010" when mostra_jogada,        --12
                     "10011" when espera_mostra_jogada, --13
                     "00000" when others;

end architecture fsm;