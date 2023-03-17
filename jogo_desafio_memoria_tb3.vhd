--------------------------------------------------------------------------
-- Arquivo   : jogo_desafio_memoria_tb3.vhd
-- Projeto   : Experiencia 06 - Projeto Base do Jogo do Desafio da Memória
--------------------------------------------------------------------------
-- Descricao : testbench para simulação com ModelSim
--
--             Cenário: Jogador perde por timeout
--             
--------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     01/02/2020  1.0     João Pedro C.M.   criacao
--------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

-- entidade do testbench
entity jogo_desafio_memoria_tb3 is
end entity;

architecture tb of jogo_desafio_memoria_tb3 is

  -- Componente a ser testado (Device Under Test -- DUT)
  component jogo_desafio_memoria is
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
  end component;
  
  ---- Declaracao de sinais de entrada para conectar o componente
  signal clk_in     : std_logic := '0';
  signal rst_in     : std_logic := '0';
  signal iniciar_in : std_logic := '0';
  signal botoes_in  : std_logic_vector(3 downto 0) := "0000";
  signal ativar_in   : std_logic := '0';

  ---- Declaracao dos sinais de saida
  signal ganhou_out     : std_logic := '0';
  signal perdeu_out     : std_logic := '0';
  signal pronto_out     : std_logic := '0';
  signal leds_out       : std_logic_vector(3 downto 0);
  signal contagem_out   : std_logic_vector(6 downto 0) := "0000000";
  signal memoria_out    : std_logic_vector(6 downto 0);
  signal jogada_out     : std_logic_vector(6 downto 0);
  signal estado_out     : std_logic_vector(6 downto 0) := "0000000";
  signal rodada_out     : std_logic_vector(6 downto 0);

  -- Configurações do clock
  signal keep_simulating: std_logic := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod : time := 20 ns;     -- frequencia 50MHz

  -- Configuração de jogo
  constant rodada        : natural := 5; -- Nível de dificuldade
  constant modo          : natural := 2;
  constant rodada_perder : natural := 4;
  constant jogada_perder : natural := 3;

  -- Array de testes
  type   test_vector is array(0 to 15) of std_logic_vector(3 downto 0);
  signal tests : test_vector := (
                                   --C_Major ? (AINDA EM DEBATE)
                                   "0001", --G5 (783.99 Hz)
                                   "0010", --F5
                                   "0011", --E5
                                   "0100", --D5
                                   "0101", --C5 (523.25 Hz)
                                   "0110", --B5
                                   "0111", --A5
                                   "1000", --G4
                                   "1001", --F4
                                   "1010", --E4
                                   "1011", --D4
                                   "1100", --C4 (261.63 Hz) 
                                   "1011", --D4
                                   "1010", --E4
                                   "1001", --F4
                                   "1000");--G4
  
begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período especificado. 
  -- Quando keep_simulating=0, clock é interrompido, bem como a simulação de eventos
  clk_in <= (not clk_in) and keep_simulating after clockPeriod/2;
  
  ---- DUT para Simulacao
  DUT: jogo_desafio_memoria
       port map (
          clock           => clk_in,
          reset           => rst_in,
          iniciar         => iniciar_in,
          ativar          => ativar_in,
          botoes          => botoes_in,
          ganhou          => ganhou_out,
          perdeu          => perdeu_out,
          pronto          => pronto_out,
          leds            => leds_out,
          db_jogada       => jogada_out,
          db_contagem     => contagem_out,
          db_estado       => estado_out,
          db_memoria      => memoria_out,
          db_rodada       => rodada_out
       );

  stimulus: process is
  begin

    -- inicio da simulacao
    assert false report "inicio da simulacao" severity note;
    keep_simulating <= '1';  -- inicia geracao do sinal de clock

    ativar_in <= '0';
    -- gera pulso de reset (1 periodo de clock)
    rst_in <= '1';
    wait for clockPeriod;
    rst_in <= '0';

    -- espera para inicio dos testes
    wait for 10*clockPeriod;
    wait until falling_edge(clk_in);

    -- pulso do sinal de Iniciar (muda na borda de descida do clock)
    wait until falling_edge(clk_in);
    iniciar_in <= '1';
    wait until falling_edge(clk_in);
    iniciar_in <= '0';
    wait for 10*clockPeriod;
    botoes_in  <= std_logic_vector(to_unsigned(modo, 4));
    ativar_in   <= '1';
    wait for 10*clockPeriod;
    botoes_in  <= "0000";
    ativar_in   <= '0'; 
    wait for 2*clockPeriod;
    -- Escolher Dificuldade
    botoes_in  <= std_logic_vector(to_unsigned(rodada, 4));
    ativar_in   <= '1';
    wait for 2*clockPeriod;
    ativar_in   <= '0'; 
    botoes_in  <= "0000";
    wait for 1005*clockPeriod;
    tests(0) <= leds_out;
    assert pronto_out   = '0'    report "bad initial pronto"                      severity error;
    assert ganhou_out   = '0'    report "bad initial ganhou"                      severity error;
    assert perdeu_out   = '0'    report "bad initial perdeu"                      severity error;
    wait for 1000*clockPeriod;
    
    -- Cada iteração corresponde a uma rodada
    for i in 0 to rodada - 1 loop
      assert false report "Rodada " & integer'image(i) severity note;
      -- Cada iteração corresponde a uma jogada
      -- Escrita pós-jogada
      for k in 0 to i + 1 loop
        -- Timeout
        if(k = jogada_perder and i = rodada_perder) then
          wait for clockPeriod;
          assert leds_out     = "0000"   report "bad led = " & integer'image(to_integer(unsigned(leds_out))) severity error;
          assert pronto_out   = '0'      report "bad  pronto"                             severity error;
          assert ganhou_out   = '0'      report "bad  ganhou"                             severity error;
          assert perdeu_out   = '0'      report "bad  perdeu"                             severity error;
          wait for 4999*clockPeriod;
          assert leds_out     = "0000"   report "bad led = " & integer'image(to_integer(unsigned(leds_out))) severity error;
          assert pronto_out   = '1'      report "bad  pronto"                             severity error;
          assert ganhou_out   = '0'      report "bad  ganhou"                             severity error;
          assert perdeu_out   = '1'      report "bad  perdeu"                             severity error;
        -- Continua jogando até perder
        elsif(pronto_out = '0' or perdeu_out = '0') then
          if(k = i + 1) then
            -- Modo multijogador -> jogador escreve a próxima jogada
            if(modo = 3) then
              botoes_in  <= tests(k);
              ativar_in   <= '1';
            -- Demais modos -> jogador ve a jogada, determinada pela FPGA, e imita ela
            else
              tests(k) <= leds_out;
            end if;
          else
            botoes_in <= tests(k);
            ativar_in  <= '1';
          end if;
          wait for clockPeriod;
          assert leds_out     = tests(k) report "bad led = " & integer'image(to_integer(unsigned(leds_out))) severity error;
          assert pronto_out   = '0'      report "bad  pronto"                             severity error;
          assert ganhou_out   = '0'      report "bad  ganhou"                             severity error;
          assert perdeu_out   = '0'      report "bad  perdeu"                             severity error;
          wait for 9*clockPeriod;
          botoes_in  <= "0000";
          ativar_in   <= '0';
          wait for clockPeriod;
          assert leds_out     = "0000"   report "bad led = " & integer'image(to_integer(unsigned(leds_out))) severity error;
          assert pronto_out   = '0'      report "bad  pronto"                             severity error;
          assert ganhou_out   = '0'      report "bad  ganhou"                             severity error;
          assert perdeu_out   = '0'      report "bad  perdeu"                             severity error;
          wait for 9*clockPeriod;
        end if; 
      end loop;
    end loop;

    ---- final do testbench
    assert false report "fim da simulacao" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: processo aguarda indefinidamente
  end process;

end architecture;