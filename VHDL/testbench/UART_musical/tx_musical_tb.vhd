
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx_musical_tb is
end entity;

architecture tb of tx_musical_tb is

    -- Componente a ser testado (Device Under Test -- DUT)
    component tx_musical
      port (
        clock         : in  std_logic;
        reset         : in  std_logic;
        enviar_config : in  std_logic;
        enviar_jogada : in  std_logic;
        modo          : in  std_logic_vector(1 downto 0);
        dificuldade   : in  std_logic_vector(3 downto 0);
        perdeu        : in  std_logic;
        ganhou        : in  std_logic;
        notas         : in  std_logic_vector(3 downto 0);
        jogador       : in  std_logic;
        jogada        : in  std_logic_vector(3 downto 0);
        rodada        : in  std_logic_vector(3 downto 0);
        tx            : out std_logic;
        pronto        : out std_logic;
        db_dado_tx    : out std_logic;
        db_estado     : out std_logic_vector(3 downto 0)
      );
    end component;

    component rx_serial is
      port (
        clock             : in std_logic;
        reset             : in std_logic;
        dado_serial       : in std_logic;
        dado_recebido     : out std_logic_vector(7 downto 0);
        paridade_recebida : out std_logic;
        pronto            : out std_logic;
        db_dado_serial    : out std_logic;
        db_estado         : out std_logic_vector(3 downto 0)
      );
    end component;
    
    -- Declaração de sinais para conectar o componente a ser testado (DUT)
    --   valores iniciais para fins de simulacao (ModelSim)
    signal clock_in         : std_logic := '0';
    signal reset_in         : std_logic := '0';
    signal enviar_config_in : std_logic := '0';
    signal enviar_jogada_in : std_logic := '0';
    signal modo_in          : std_logic_vector(1 downto 0) := "00";
    signal dificuldade_in   : std_logic_vector(3 downto 0) := "0000";
    signal perdeu_in        : std_logic;
    signal ganhou_in        : std_logic;
    signal notas_in         : std_logic_vector (3 downto 0) := "0000";
    signal jogador_in       : std_logic;
    signal jogada_in        : std_logic_vector(3 downto 0);
    signal rodada_in        : std_logic_vector(3 downto 0);
    signal tx               : std_logic := '1';
    signal pronto_out       : std_logic := '0';

    -- receptor
    signal dado_recebido    : std_logic_vector(7 downto 0);
    signal dado_esperado    : std_logic_vector(7 downto 0);
    signal pronto_rx        : std_logic;
  
    -- Configurações do clock
    signal keep_simulating : std_logic := '0'; -- delimita o tempo de geração do clock
    constant clockPeriod   : time := 20 ns;    -- clock de 50MHz
    
    signal caso,j : integer := 0;

    type caso_teste_type is record
      id            : natural;
      enviar_config : std_logic;
      enviar_jogada : std_logic;
      modo          : std_logic_vector(1 downto 0);
      dificuldade   : std_logic_vector(3 downto 0);
      perdeu        : std_logic;
      ganhou        : std_logic;
      notas         : std_logic_vector(3 downto 0);
      jogador       : std_logic;
      jogada        : std_logic_vector(3 downto 0);
      rodada        : std_logic_vector(3 downto 0);
    end record;
    type caso_teste_array is array (natural range <>) of caso_teste_type;
    constant vetor_teste: caso_teste_array :=
       ((1, '1', '0', "11", "0001", '0', '0', "0101", '1', "1101", "1000"),
        (2, '0', '1', "01", "0010", '0', '1', "0110", '0', "1110", "1001"),
        (3, '1', '0', "10", "0011", '1', '0', "0111", '1', "1111", "1010"),
        (4, '0', '1', "00", "0100", '1', '0', "1000", '0', "0000", "1011"));
  
  begin
    -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
    -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
    -- simulação de eventos
    clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;

    -- Conecta DUT (Device Under Test)
    dut: tx_musical
         port map (
             clock           => clock_in,
             reset           => reset_in,
             enviar_config   => enviar_config_in,
             enviar_jogada   => enviar_jogada_in,
             modo            => modo_in,
             dificuldade     => dificuldade_in,
             perdeu          => perdeu_in,
             ganhou          => ganhou_in,
             notas           => notas_in,
             jogador         => jogador_in,
             jogada          => jogada_in,
             rodada          => rodada_in,
             tx              => tx,
             pronto          => pronto_out,
             db_dado_tx      => open,
             db_estado       => open
        );

    receptor: rx_serial
      port map (
        clock             => clock_in,
        reset             => reset_in,
        dado_serial       => tx,
        paridade_recebida => open,
        pronto            => pronto_rx,
        dado_recebido     => dado_recebido,
        db_estado         => open,
        db_dado_serial    => open
      );

    -- geracao dos sinais de entrada (estimulos)
    stimulus: process is
    begin

      assert false report "Inicio da simulacao" severity note;
      keep_simulating <= '1';

      ---- inicio da simulacao: reset ----------------
      -- pulso largo de reset com 20 periodos de clock
      wait until falling_edge(clock_in);
      reset_in   <= '1';
      wait for 20*clockPeriod;
      reset_in   <= '0';
      wait until falling_edge(clock_in);
      wait for 50*clockPeriod;
  
      ---- Casos de teste
  
      -- Para cada padrao de teste no vetor
      for i in vetor_teste'range loop
  
          assert false report "caso: " & integer'image(i) severity note;
          caso <= i;
  
          ---- dado de entrada do vetor de teste
          ---- acionamento da partida (inicio da transmissao)
          wait until falling_edge(clock_in);
          modo_in          <= vetor_teste(i).modo;
          dificuldade_in   <= vetor_teste(i).dificuldade;
          perdeu_in        <= vetor_teste(i).perdeu;
          ganhou_in        <= vetor_teste(i).ganhou;
          notas_in         <= vetor_teste(i).notas;
          jogador_in       <= vetor_teste(i).jogador;
          jogada_in        <= vetor_teste(i).jogada;
          rodada_in        <= vetor_teste(i).rodada;
          enviar_config_in <= vetor_teste(i).enviar_config;
          enviar_jogada_in <= vetor_teste(i).enviar_jogada;
          wait for clockPeriod;
          modo_in          <= "00";
          dificuldade_in   <= "0000";
          perdeu_in        <= '0';
          ganhou_in        <= '0';
          notas_in         <= "0000";
          jogador_in       <= '0';
          jogada_in        <= "0000";
          rodada_in        <= "0000";
          enviar_config_in <= '0';
          enviar_jogada_in <= '0';
      
          ---- espera final da transmissao (pulso pronto em 1)
          if vetor_teste(i).enviar_config = '1' then
            assert false report "config" severity note;
            wait until pronto_rx = '1';
            dado_esperado <= "11" & vetor_teste(i).modo & vetor_teste(i).dificuldade;
            wait for 5*clockPeriod;
            assert dado_recebido = dado_esperado report "dado incorreto" severity error;
          end if;
          assert false report "jogada" severity note;
          j <= 0;
          while j < 3 loop
            assert false report "j: " & integer'image(j) severity note;
            wait until pronto_rx = '1';
            -- assert false report "pronto rx!" severity note;
            if j = 0 then
              dado_esperado <= "00" & vetor_teste(i).perdeu & vetor_teste(i).ganhou & vetor_teste(i).notas;
            elsif j = 1 then
              dado_esperado <= "01" & '0' & vetor_teste(i).jogador & vetor_teste(i).jogada;
            else
              dado_esperado <= "10" & "00" & vetor_teste(i).rodada;
            end if;
            wait for 5*clockPeriod;
            assert dado_recebido = dado_esperado report "dado incorreto" severity error;
            j <= j + 1;
            wait for 5*clockPeriod;
          end loop;
          
          --assert false report "esperando" severity note;
          -- intervalo entre casos de teste
          wait until pronto_out = '1'; -- transmissor mais lento do que o receptor
          wait for 10*clockPeriod;
          --assert false report "esperei" severity note;
      
  
      end loop;
  
      ---- final dos casos de teste da simulacao
      assert false report "Fim da simulacao" severity note;
      keep_simulating <= '0';
      
      wait; -- fim da simulação: aguarda indefinidamente
    end process;
  
end architecture;