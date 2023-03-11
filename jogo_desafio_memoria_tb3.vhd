--------------------------------------------------------------------------
-- Arquivo   : jogo_desafio_memoria_tb3.vhd
-- Projeto   : Experiencia 06 - Projeto Base do Jogo do Desafio da Memória
--------------------------------------------------------------------------
-- Descricao : testbench para simulação com ModelSim
--
--             Cenário: Timeout na 1ª jogada da 2ª rodada
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
      seleciona : in  std_logic;
      botoes    : in  std_logic_vector(11 downto 0);
      leds      : out std_logic_vector(11 downto 0); --saida 
      pronto    : out std_logic;
      ganhou    : out std_logic;
      perdeu    : out std_logic;
        -- acrescentar saidas de depuracao
        db_rodada                : out std_logic_vector(6 downto 0);
        db_contagem              : out std_logic_vector(6 downto 0);
        db_memoria               : out std_logic_vector(11 downto 0);
        db_estado                : out std_logic_vector(6 downto 0)
    );
  end component;
  
  ---- Declaracao de sinais de entrada para conectar o componente
  signal clk_in     : std_logic := '0';
  signal rst_in     : std_logic := '0';
  signal iniciar_in : std_logic := '0';
  signal botoes_in  : std_logic_vector(11 downto 0) := "000000000000";

  ---- Declaracao dos sinais de saida
  signal ganhou_out     : std_logic := '0';
  signal perdeu_out     : std_logic := '0';
  signal pronto_out     : std_logic := '0';
  signal leds_out       : std_logic_vector(11 downto 0);
  signal seleciona_in   : std_logic;
  signal clock_out      : std_logic := '0';
  signal contagem_out   : std_logic_vector(6 downto 0) := "0000000";
  signal memoria_out    : std_logic_vector(11 downto 0);
  signal estado_out     : std_logic_vector(6 downto 0) := "0000000";
  signal db_rodada      : std_logic_vector(6 downto 0);

  -- Configurações do clock
  signal keep_simulating: std_logic := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod : time := 20 ns;     -- frequencia 50MHz

  -- Array de testes
  type   test_vector is array(0 to 15) of std_logic_vector(11 downto 0);
  signal tests : test_vector := (
                                   --C_Major ? (AINDA EM DEBATE)
                                   "000000000001", --G5 (783.99 Hz)
                                   "000000000010", --F5
                                   "000000000100", --E5
                                   "000000001000", --D5
                                   "000000010000", --C5 (523.25 Hz)
                                   "000000100000", --B5
                                   "000001000000", --A5
                                   "000010000000", --G4
                                   "000100000000", --F4
                                   "001000000000", --E4
                                   "010000000000", --D4
                                   "100000000000", --C4 (261.63 Hz) 
                                   "010000000000", --D4
                                   "001000000000", --E4
                                   "000100000000", --F4
                                   "000010000000");
  
begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período especificado. 
  -- Quando keep_simulating=0, clock é interrompido, bem como a simulação de eventos
  clk_in <= (not clk_in) and keep_simulating after clockPeriod/2;
  
  ---- DUT para Simulacao
  DUT: jogo_desafio_memoria
       port map
       (
          clock           => clk_in,
          reset           => rst_in,
          iniciar         => iniciar_in,
          botoes          => botoes_in,
          ganhou          => ganhou_out,
          perdeu          => perdeu_out,
          pronto          => pronto_out,
          leds            => leds_out,
          seleciona       => seleciona_in,
          db_contagem     => contagem_out,
          db_memoria      => memoria_out,
          db_estado       => estado_out,
          db_rodada       => db_rodada
       );

  stimulus: process is
  begin

    -- inicio da simulacao
    assert false report "inicio da simulacao" severity note;
    keep_simulating <= '1';  -- inicia geracao do sinal de clock

    seleciona_in <= '0';
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
    seleciona_in          <= '1';
    botoes_in(3 downto 0) <= "0001";
    wait for 2*clockPeriod;
    seleciona_in <= '0'; 
    botoes_in           <= "000000000000";
    wait for 1005*clockPeriod;
    assert leds_out     = "000000000001" report "bad led = " & integer'image(to_integer(unsigned(leds_out))) severity error;
    assert pronto_out   = '0'    report "bad initial pronto"                      severity error;
    assert ganhou_out   = '0'    report "bad initial ganhou"                      severity error;
    assert perdeu_out   = '0'    report "bad initial perdeu"                      severity error;
    wait for 1000*clockPeriod;
    
    -- Cada iteração corresponde a uma rodada
    for i in 0 to 1 loop
      assert false report "Rodada " & integer'image(i) severity note;
      -- Cada iteração corresponde a uma jogada
      -- Escrita pós-jogada
      for k in 0 to i + 1 loop
        -- Timeout na 1ª jogada da 2ª rodada
        if(i = 1 and k = 0) then
          wait for clockPeriod;
          assert leds_out     = "000000000000"   report "bad led = " & integer'image(to_integer(unsigned(leds_out))) severity error;
          assert pronto_out   = '0'      report "bad  pronto"                             severity error;
          assert ganhou_out   = '0'      report "bad  ganhou"                             severity error;
          assert perdeu_out   = '0'      report "bad  perdeu"                             severity error;
          wait for 4999*clockPeriod;
          assert leds_out     = "000000000000"   report "bad led = " & integer'image(to_integer(unsigned(leds_out))) severity error;
          assert pronto_out   = '1'      report "bad  pronto"                             severity error;
          assert ganhou_out   = '0'      report "bad  ganhou"                             severity error;
          assert perdeu_out   = '1'      report "bad  perdeu"                             severity error;
        elsif(i = 1) then
          wait for clockPeriod;
          assert leds_out     = "000000000000"   report "bad led = " & integer'image(to_integer(unsigned(leds_out))) severity error;
          assert pronto_out   = '1'      report "bad  pronto"                             severity error;
          assert ganhou_out   = '0'      report "bad  ganhou"                             severity error;
          assert perdeu_out   = '1'      report "bad  perdeu"                             severity error; 
        else         
          botoes_in  <= tests(k);
          wait for clockPeriod;
          assert leds_out     = tests(k) report "bad led = " & integer'image(to_integer(unsigned(leds_out))) severity error;
          assert pronto_out   = '0'      report "bad  pronto"                             severity error;
          assert ganhou_out   = '0'      report "bad  ganhou"                             severity error;
          assert perdeu_out   = '0'      report "bad  perdeu"                             severity error;
          wait for 9*clockPeriod;
          botoes_in  <= "000000000000";
          wait for clockPeriod;
          assert leds_out     = "000000000000"   report "bad led = " & integer'image(to_integer(unsigned(leds_out))) severity error;
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