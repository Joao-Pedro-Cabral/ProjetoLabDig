--------------------------------------------------------------------------
-- Arquivo   : jogo_desafio_memoria_tb2.vhd
-- Projeto   : Experiencia 06 - Projeto Base do Jogo do Desafio da Memória
--------------------------------------------------------------------------
-- Descricao : testbench para simulação com ModelSim
--
--             Cenário: Jogador vence
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
entity jogo_desafio_memoria_tb2 is
end entity;

architecture tb of jogo_desafio_memoria_tb2 is

  -- Componente a ser testado (Device Under Test -- DUT)
  component jogo_desafio_memoria is
    port (
        clock   : in  std_logic;
        reset   : in  std_logic;
        iniciar : in  std_logic;
        botoes  : in  std_logic_vector(3 downto 0);
        leds    : out std_logic_vector(3 downto 0);
        pronto  : out std_logic;
        ganhou  : out std_logic;
        perdeu  : out std_logic;
        -- acrescentar saidas de depuracao
        db_clock                 : out std_logic;
        db_rodada                : out std_logic_vector(6 downto 0);
        db_contagem              : out std_logic_vector(6 downto 0);
        db_memoria               : out std_logic_vector(6 downto 0);
        db_jogada_feita          : out std_logic_vector(6 downto 0);
        db_estado                : out std_logic_vector(6 downto 0)
    );
  end component;
  
  ---- Declaracao de sinais de entrada para conectar o componente
  signal clk_in     : std_logic := '0';
  signal rst_in     : std_logic := '0';
  signal iniciar_in : std_logic := '0';
  signal botoes_in  : std_logic_vector(3 downto 0) := "0000";

  ---- Declaracao dos sinais de saida
  signal ganhou_out     : std_logic := '0';
  signal perdeu_out     : std_logic := '0';
  signal pronto_out     : std_logic := '0';
  signal leds_out       : std_logic_vector(3 downto 0) := "0000";
  signal clock_out      : std_logic := '0';
  signal contagem_out   : std_logic_vector(6 downto 0) := "0000000";
  signal memoria_out    : std_logic_vector(6 downto 0) := "0000000";
  signal estado_out     : std_logic_vector(6 downto 0) := "0000000";
  signal jogada_out     : std_logic_vector(6 downto 0) := "0000000";
  signal db_rodada      : std_logic_vector(6 downto 0);

  -- Configurações do clock
  signal keep_simulating: std_logic := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod : time := 20 ns;     -- frequencia 100MHz

  -- Array de testes
  type   test_vector is array(0 to 15) of std_logic_vector(3 downto 0);
  signal tests : test_vector := (
                                  "0001",
                                  "0010",
                                  "0100",
                                  "1000",
                                  "0100",
                                  "0010",
                                  "0001",
                                  "0001",
                                  "0010",
                                  "0010",
                                  "0100",
                                  "0100",
                                  "1000",
                                  "1000",
                                  "0001",
                                  "0100" );
  
begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período especificado. 
  -- Quando keep_simulating=0, clock é interrompido, bem como a simulação de eventos
  clk_in <= (not clk_in) and keep_simulating after clockPeriod/2;
  
  ---- DUT para Simulacao
  dut: jogo_desafio_memoria
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
          db_contagem     => contagem_out,
          db_memoria      => memoria_out,
          db_estado       => estado_out,
          db_jogada_feita => jogada_out,  
          db_clock        => clock_out,
          db_rodada       => db_rodada
       );
 
  ---- Gera sinais de estimulo para a simulacao
  -- Cenario de Teste : acerta as primeiras 4 jogadas
  --                    e erra a 10a jogada
  stimulus: process is
  begin

    -- inicio da simulacao
    assert false report "inicio da simulacao" severity note;
    keep_simulating <= '1';  -- inicia geracao do sinal de clock

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
    wait for 1005*clockPeriod;
    assert leds_out     = "0001" report "bad led = " & integer'image(to_integer(unsigned(leds_out))) severity error;
    assert pronto_out   = '0'    report "bad initial pronto"                      severity error;
    assert ganhou_out   = '0'    report "bad initial ganhou"                      severity error;
    assert perdeu_out   = '0'    report "bad initial perdeu"                      severity error;
    wait for 1000*clockPeriod;
    
    -- Cada iteração corresponde a uma rodada
    for i in tests'range loop
      assert false report "Rodada " & integer'image(i) severity note;
      -- Cada iteração corresponde a uma jogada
      -- Última rodada -> sem escrita
      if(i = 15) then
        for k in 0 to i loop 
          botoes_in  <= tests(k);
          wait for clockPeriod;
          assert leds_out = tests(k) report "bad led = " & integer'image(to_integer(unsigned(leds_out))) severity error;
          -- última jogada da última rodada -> ganhou!
            assert pronto_out   = '0'  report "bad pronto"                          severity error;
            assert ganhou_out   = '0'  report "bad ganhou"                          severity error;
            assert perdeu_out   = '0'  report "bad perdeu"                          severity error;
            wait for 9*clockPeriod;
            botoes_in  <= "0000";
            wait for clockPeriod;
            assert leds_out     = "0000"   report "bad led = " & integer'image(to_integer(unsigned(leds_out))) severity error;
            if(k = 15) then
              assert pronto_out   = '1'  report "bad pronto"  severity error;
              assert ganhou_out   = '1'  report "bad ganhou"  severity error;
              assert perdeu_out   = '0'  report "bad perdeu"  severity error;
            else
              assert pronto_out   = '0' report "bad pronto"   severity error;
              assert ganhou_out   = '0' report "bad ganhou"   severity error;
              assert perdeu_out   = '0' report "bad perdeu"   severity error;
            end if;
            wait for 9*clockPeriod;
        end loop;
      -- Demais rodadas -> escrita pós-jogada
      else
        for k in 0 to i + 1 loop 
          botoes_in  <= tests(k);
          wait for clockPeriod;
          assert leds_out     = tests(k) report "bad led = " & integer'image(to_integer(unsigned(leds_out))) severity error;
          assert pronto_out   = '0'      report "bad  pronto"                             severity error;
          assert ganhou_out   = '0'      report "bad  ganhou"                             severity error;
          assert perdeu_out   = '0'      report "bad  perdeu"                             severity error;
          wait for 9*clockPeriod;
          botoes_in  <= "0000";
          wait for clockPeriod;
          assert leds_out     = "0000"   report "bad led = " & integer'image(to_integer(unsigned(leds_out))) severity error;
          assert pronto_out   = '0'      report "bad  pronto"                             severity error;
          assert ganhou_out   = '0'      report "bad  ganhou"                             severity error;
          assert perdeu_out   = '0'      report "bad  perdeu"                             severity error;
          wait for 9*clockPeriod;
        end loop;
      end if;
    end loop;

    ---- final do testbench
    assert false report "fim da simulacao" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: processo aguarda indefinidamente
  end process;

end architecture;