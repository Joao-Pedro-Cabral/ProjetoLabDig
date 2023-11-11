library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rx_musical_tb is
end entity;

architecture tb of rx_musical_tb is

  -- Declaração de sinais para conectar o componente a ser testado (DUT)
  signal clock_in              : std_logic  := '0';
  signal reset_in              : std_logic  := '0';
  -- saidas
  signal iniciar_out           : std_logic  := '0';
  signal configurado_out       : std_logic  := '0';
  signal jogada_out            : std_logic  := '0';
  signal notas_out             : std_logic_vector(3 downto 0)  := "0000";
  signal configuracao_out      : std_logic_vector(5 downto 0)  := "000000";
  signal paridade_ok_out       : std_logic  := '0';

  -- para procedimento UART_WRITE_BYTE
  signal entrada_serial_in : std_logic := '1';
  signal serialData        : std_logic_vector(8 downto 0) := "000000000";

  -- Configurações do clock
  constant clockPeriod : time := 20 ns;            -- 50MHz
  -- constant bitPeriod   : time := 5208*clockPeriod; -- 5208 clocks por bit (9.600 bauds)
  constant bitPeriod   : time := 434*clockPeriod;  -- 434 clocks por bit (115.200 bauds)
  
  ---- UART_WRITE_BYTE()
  -- Procedimento para geracao da sequencia de comunicacao serial 8N2
  -- adaptacao de codigo acessado de:
  -- https://www.nandland.com/goboard/uart-go-board-project-part1.html
  procedure UART_WRITE_BYTE (
      Data_In : in  std_logic_vector(8 downto 0);
      signal Serial_Out : out std_logic ) is
    begin

      -- envia Start Bit
      Serial_Out <= '0';
      wait for bitPeriod;

      -- envia 8 bits seriais
      for ii in 0 to 8 loop
          Serial_Out <= Data_In(ii);
          wait for bitPeriod;
      end loop;  -- loop ii

      -- envia 2 Stop Bits
      Serial_Out <= '1';

  end UART_WRITE_BYTE;
  ---- fim procedure UART_WRITE_BYTE

  ---- Array de casos de teste
  type caso_teste_type is record
      id   : natural;
      data : std_logic_vector(8 downto 0);
  end record;

  type casos_teste_array is array (natural range <>) of caso_teste_type;
  constant casos_teste : casos_teste_array :=
      (
        (1, "011001101"), -- config
        (2, "100110101"), -- nota
        (3, "011010110"), -- config
        (4, "100010100")  -- nota
        -- inserir aqui outros casos de teste (inserir "," na linha anterior)
      );
  signal caso : natural;

  ---- controle do clock e simulacao
  signal keep_simulating: std_logic := '0'; -- delimita o tempo de gera��o do clock

begin

  ---- Gerador de Clock
  clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;

  -- Instanciação direta DUT (Device Under Test)
  DUT: entity work.rx_musical (structural)
       port map (  
           clock             => clock_in,
           reset             => reset_in,
           rx                => entrada_serial_in,
           iniciar           => iniciar_out,
           configurado       => configurado_out,
           configuracao      => configuracao_out,
           jogada            => jogada_out,
           notas             => notas_out,
           db_dado_rx        => open,
           db_estado         => open
       );

  ---- Geracao dos sinais de entrada (estimulo)
  stimulus: process is
  begin
  
    ---- inicio da simulacao
    assert false report "inicio da simulacao" severity note;
    keep_simulating <= '1';
    -- reset com 5 periodos de clock
    reset_in <= '0';
    -- wait for bitPeriod;
    reset_in <= '1', '0' after 5*clockPeriod; 
    wait for bitPeriod;

    ---- loop pelos casos de teste
    for i in casos_teste'range loop
        caso <= casos_teste(i).id;
        assert false report "Caso de teste " & integer'image(casos_teste(i).id) severity note;
        serialData <= casos_teste(i).data; -- caso de teste "i"
        -- aguarda 2 periodos de bit antes de enviar bits
        wait for 2*bitPeriod;

        -- 1) envia bits seriais para circuito de recepcao
        UART_WRITE_BYTE ( Data_In=>serialData, Serial_Out=>entrada_serial_in );

        -- Sincronizando
        wait for bitPeriod/2;
        wait for 6*clockPeriod;
        wait until clock_in = '0';
        if casos_teste(i).data(7 downto 6) = "11" then -- config
          assert iniciar_out = '1' report "Erro iniciar" severity error;
          wait until clock_in = '0';
          assert configurado_out = '1' report "Erro configurado" severity error;
          assert configuracao_out = serialData(5 downto 0) report "Erro configuracao" severity error;
        else -- nota
          assert jogada_out = '1' report "Erro jogada" severity error;
          assert notas_out = serialData(3 downto 0) report "Erro notas" severity error;
        end if;

        -- 2) intervalo entre casos de teste
        wait for 2*bitPeriod;
    end loop;


    ---- final dos casos de teste da simulacao
    -- reset
    reset_in <= '0';
    wait for bitPeriod;
    reset_in <= '1', '0' after 5*clockPeriod; 
    wait for bitPeriod;

    ---- final da simulacao
    assert false report "fim da simulacao" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente

  end process stimulus;
end architecture tb;