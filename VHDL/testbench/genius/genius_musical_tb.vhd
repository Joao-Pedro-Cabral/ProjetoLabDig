--------------------------------------------------------------------------
-- Arquivo   : genius_musical_tb.vhd
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
entity genius_musical_tb is
end entity;

architecture tb of genius_musical_tb is

  -- Componente a ser testado (Device Under Test -- DUT)
  component genius_musical is
    port (
      clock                    : in  std_logic;
      reset                    : in  std_logic;
      iniciar                  : in  std_logic;
      ativar                   : in  std_logic;
      chaves                   : in  std_logic_vector(5 downto 0);
      echo                     : in  std_logic;
      rx                       : in  std_logic;
      sel_db                   : in  std_logic;
      trigger                  : out std_logic;
      pwm                      : out std_logic;
      pwm2                     : out std_logic;
      tx                       : out std_logic;
      notas                    : out std_logic_vector(3 downto 0);
      jogador                  : out std_logic;
      ganhou                   : out std_logic;
      perdeu                   : out std_logic;
      perdeuT                  : out std_logic;
      db_hex0                  : out std_logic_vector(6 downto 0);
      db_hex1                  : out std_logic_vector(6 downto 0);
      db_hex2                  : out std_logic_vector(6 downto 0);
      db_hex3                  : out std_logic_vector(6 downto 0);
      db_hex4                  : out std_logic_vector(6 downto 0);
      db_hex5                  : out std_logic_vector(6 downto 0);
      db_modo                  : out std_logic_vector(1 downto 0);
      db_dado_tx               : out std_logic;
      db_dado_rx               : out std_logic
    );
  end component;

  component tx_serial
    port (
        clock           : in  std_logic;
        reset           : in  std_logic;
        partida         : in  std_logic;
        dados_ascii     : in  std_logic_vector(7 downto 0);
        saida_serial    : out std_logic;
        pronto          : out std_logic;
        db_partida      : out std_logic;
        db_saida_serial : out std_logic;
        db_estado       : out std_logic_vector(3 downto 0)
    );
  end component;

  ---- Declaracao de sinais de entrada para conectar o componente
  signal clk_in     : std_logic := '0';
  signal rst_in     : std_logic := '1';
  signal not_rst_in : std_logic := '0';
  signal iniciar_in : std_logic := '1';
  signal ativar_in  : std_logic := '1';
  signal chaves_in  : std_logic_vector(5 downto 0) := "000000";
  signal echo_in    : std_logic := '0';
  signal rx_in      : std_logic := '0';

  ---- Declaracao dos sinais de saida
  signal trigger_out    : std_logic := '0';
  signal pwm_out        : std_logic := '0';
  signal pwm2_out       : std_logic := '0';
  signal tx_out         : std_logic := '0';
  signal notas_out      : std_logic_vector(3 downto 0) := "0000";
  signal jogador_out    : std_logic := '0';
  signal ganhou_out     : std_logic := '0';
  signal perdeu_out     : std_logic := '0';
  signal perdeuT_out    : std_logic := '0';

  -- Configurações do clock
  signal keep_simulating: std_logic := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod : time := 20 ns;     -- frequencia 100MHz

  -- Configuração de jogo
  constant rodada : natural := 3; -- Nível de dificuldade
  constant modo   : natural := 2;

  -- Transmissor
  signal partida_in       : std_logic := '0';
  signal enviar_config_in : std_logic := '0';
  signal enviar_jogada_in : std_logic := '0';
  signal modo_in          : std_logic_vector(1 downto 0) := "00";
  signal dificuldade_in   : std_logic_vector(3 downto 0) := "0000";
  signal notas_in         : std_logic_vector(3 downto 0) := "0000";
  signal dados_tx         : std_logic_vector(7 downto 0) := "00000000";
  signal config           : std_logic_vector(7 downto 0) := "00000000";
  signal nota             : std_logic_vector(7 downto 0) := "00000000";
  signal pronto_tx        : std_logic := '0';

  -- Função para calcular a largura do echo
  function EchoLen(nota: std_logic_vector(3 downto 0) := "0000") return time is
  begin
    if nota = "0000" then
      return 0 us;
    else
      return (2*to_integer(unsigned(nota)) - 1)*(58.82 us);
    end if;
  end function;

  -- Array de testes
  type   test_vector is array(0 to 15) of std_logic_vector(3 downto 0);
  signal tests : test_vector := (
                                   --C_Major ? (AINDA EM DEBATE)
                                   "0001", -- (2.04cm, G5)
                                   "0010", -- (3,99cm, F5)
                                   "0011", -- (6,80cm, E5)
                                   "0100", -- (9,69cm, D5)
                                   "0101", -- (12,75cm, C5)
                                   "0110", -- (15,81cm, B5)
                                   "0111", -- (18,70cm, A5)
                                   "1000", -- (22,01cm, G4)
                                   "1001", -- (25,84cm, F4)
                                   "1010", -- (28,56cm, E4)
                                   "1011", -- (32,30cm, D4)
                                   "1100", -- (35,70cm, C4)
                                   "1011", -- (31,11cm, D4)
                                   "1010", -- (27,54cm, E4)
                                   "1001", -- (25,50cm, F4)
                                   "1000"  -- (23,46cm, G4)
                                );
  
begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período especificado. 
  -- Quando keep_simulating=0, clock é interrompido, bem como a simulação de eventos
  clk_in <= (not clk_in) and keep_simulating after clockPeriod/2;
  
  ---- DUT para Simulacao
  DUT: genius_musical
       port map (
          clock           => clk_in,
          reset           => rst_in,
          iniciar         => iniciar_in,
          ativar          => ativar_in,
          chaves          => chaves_in,
          echo            => echo_in,
          rx              => rx_in,
          sel_db          => '0',
          trigger         => trigger_out,
          pwm             => pwm_out,
          pwm2            => pwm2_out,
          tx              => tx_out,
          notas           => notas_out,
          jogador         => jogador_out,
          ganhou          => ganhou_out,
          perdeu          => perdeu_out,
          perdeuT         => perdeuT_out,
          db_hex0         => open,
          db_hex1         => open,
          db_hex2         => open,
          db_hex3         => open,
          db_hex4         => open,
          db_hex5         => open,
          db_modo         => open,
          db_dado_tx      => open,
          db_dado_rx      => open
       );

  transmissor: tx_serial
      port map ( 
          clock           => clk_in,
          reset           => not_rst_in,
          partida         => partida_in,
          dados_ascii     => dados_tx,
          saida_serial    => rx_in,
          pronto          => pronto_tx,
          db_partida      => open,
          db_saida_serial => open,
          db_estado       => open
     );

  not_rst_in <= not rst_in;

  modo_in        <= std_logic_vector(to_unsigned(modo, 2));
  dificuldade_in <= std_logic_vector(to_unsigned(rodada-1, 4));
  config         <= "11" & modo_in & dificuldade_in;
  nota           <= "00" & "00" & notas_in;
  partida_in     <= enviar_config_in or enviar_jogada_in;
  process(clk_in, enviar_config_in, enviar_jogada_in) is begin
    if(clk_in'event and clk_in = '1') then
      if(enviar_config_in = '1') then
        dados_tx <= config;
      elsif(enviar_jogada_in = '1') then
        dados_tx <= nota;
      end if;
    end if;
  end process;

  ---- Gera sinais de estimulo para a simulacao
  stimulus: process is
  begin

    -- inicio da simulacao
    assert false report "inicio da simulacao" severity note;
    keep_simulating <= '1';  -- inicia geracao do sinal de clock

    -- gera pulso de reset (1 periodo de clock)
    rst_in <= '0';
    wait for clockPeriod;
    rst_in <= '1';

    -- espera para inicio dos testes
    wait for 10*clockPeriod;
    wait until falling_edge(clk_in);

    -- pulso do sinal de Iniciar (muda na borda de descida do clock)
    wait until falling_edge(clk_in);
    iniciar_in <= '0';
    wait until falling_edge(clk_in);
    iniciar_in <= '1';
    wait for 10*clockPeriod;
    -- Escolher Modo e Dificuldade
    --enviar_config_in <= '1';
    --wait for clockPeriod;
    --enviar_config_in <= '0';
    --wait until pronto_tx = '1';
    chaves_in  <= std_logic_vector(to_unsigned(16*modo + rodada-1, 6));
    ativar_in  <= '0';
    wait for 10*clockPeriod;
    ativar_in  <= '1';
    wait for 505*clockPeriod;
    chaves_in  <= "000000";
    tests(0)   <= notas_out;
    assert ganhou_out   = '0'    report "bad initial ganhou"                      severity error;
    assert perdeu_out   = '0'    report "bad initial perdeu"                      severity error;
    assert perdeuT_out  = '0'    report "bad initial perdeuT"                     severity error;
    wait for 500*clockPeriod;
    -- Cada iteração corresponde a uma rodada
    for i in 0 to rodada - 1 loop
      assert false report "Rodada " & integer'image(i) severity note;
      -- Cada iteração corresponde a uma jogada
      -- Última rodada -> sem escrita
      if(i = rodada - 1) then
        for k in 0 to i loop
          assert false report "Jogada " & integer'image(k) severity note;
          wait until falling_edge(trigger_out);
          --notas_in <= tests(k);
          --enviar_jogada_in <= '1';
          --wait for clockPeriod;
          --enviar_jogada_in <= '0';
          wait for 20000*clockPeriod;
          echo_in <= '1';
          wait for EchoLen(tests(k));
          echo_in <= '0';
          wait for 10*clockPeriod;
          assert notas_out = tests(k) report "bad nota = " & integer'image(to_integer(unsigned(tests(k)))) severity error;
          -- última jogada da última rodada -> ganhou!
          wait for 15*clockPeriod;
          if(k = rodada - 1) then
            assert ganhou_out   = '1'  report "bad ganhou"  severity error;
            assert perdeu_out   = '0'  report "bad perdeu"  severity error;
            assert perdeuT_out  = '0'  report "bad perdeuT" severity error;
            wait for 5000*clockPeriod;
          else
            assert ganhou_out   = '0' report "bad ganhou"   severity error;
            assert perdeu_out   = '0' report "bad perdeu"   severity error;
            assert perdeuT_out  = '0' report "bad perdeuT"  severity error;
          end if;
          wait for 15*clockPeriod;
        end loop;
      -- Demais rodadas -> escrita pós-jogada
      else
        for k in 0 to i + 1 loop
          assert false report "Jogada " & integer'image(k) severity note;
          if(k = i + 1) then
            -- Modo multijogador -> jogador escreve a próxima jogada
            if(modo = 2) then
              wait until falling_edge(trigger_out);
              --notas_in <= tests(k);
              --enviar_jogada_in <= '1';
              --wait for clockPeriod;
              --enviar_jogada_in <= '0';
              wait for 20000*clockPeriod;
              echo_in <= '1';
              wait for EchoLen(tests(k));
              echo_in <= '0';
              wait for 10*clockPeriod;
              assert notas_out     = tests(k) report "bad nota = " & integer'image(to_integer(unsigned(tests(k)))) severity error;
            -- Demais modos -> jogador ve a jogada, determinada pela FPGA, e imita ela
            else
              wait for 25000*clockPeriod;
              tests(k) <= notas_out;
              wait for 750*clockPeriod;
              assert notas_out     = tests(k) report "bad nota = " & integer'image(to_integer(unsigned(tests(k)))) severity error;
              wait for 253*clockPeriod;
            end if;
          else
            wait until falling_edge(trigger_out);
            --notas_in <= tests(k);
            --enviar_jogada_in <= '1';
            --wait for clockPeriod;
            --enviar_jogada_in <= '0';
            wait for 20000*clockPeriod;
            echo_in <= '1';
            wait for EchoLen(tests(k));
            echo_in <= '0';
            wait for 10*clockPeriod;
            assert notas_out     = tests(k) report "bad nota = " & integer'image(to_integer(unsigned(tests(k)))) severity error;
          end if;
          assert ganhou_out   = '0'      report "bad  ganhou"                             severity error;
          assert perdeu_out   = '0'      report "bad  perdeu"                             severity error;
          assert perdeuT_out  = '0'      report "bad  perdeuT"                            severity error;
          wait for 15*clockPeriod;
        end loop;
      end if;
    end loop;

    ---- final do testbench
    assert false report "fim da simulacao" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: processo aguarda indefinidamente
  end process;

end architecture;