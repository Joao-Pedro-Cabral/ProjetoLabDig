--------------------------------------------------------------------
-- Arquivo   : interface_hcsr04_tb.vhd
-- Projeto   : Experiencia 3 - Interface com sensor de distancia
--------------------------------------------------------------------
-- Descricao : testbench para circuito de interface com HC-SR04 
--
--             1) array de casos de teste contém valores de  
--                largura de pulso de echo do sensor
-- 
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     19/09/2021  1.0     Edson Midorikawa  versao inicial
--     12/09/2022  1.1     Edson Midorikawa  revisao
--------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity interface_hcsr04_tb is
end entity;

architecture tb of interface_hcsr04_tb is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component interface_hcsr04
    port (
        clock     : in  std_logic;
        reset     : in  std_logic;
        medir     : in  std_logic;
        echo      : in  std_logic;
        trigger   : out std_logic;
        notas     : out std_logic_vector(3 downto 0);
        pronto    : out std_logic;
        db_medida : out std_logic_vector(11 downto 0);
        db_reset  : out std_logic;
        db_medir  : out std_logic;
        db_estado : out std_logic_vector(3 downto 0)
    );
  end component;
  
  -- Declaração de sinais para conectar o componente a ser testado (DUT)
  --   valores iniciais para fins de simulacao (GHDL ou ModelSim)
  signal clock_in      : std_logic := '0';
  signal reset_in      : std_logic := '0';
  signal medir_in      : std_logic := '0';
  signal echo_in       : std_logic := '0';
  signal trigger_out   : std_logic := '0';
  signal notas_out     : std_logic_vector(3 downto 0) := "0000";
  signal db_medida_out : std_logic_vector(11 downto 0) := x"000";
  signal pronto_out    : std_logic := '0';
  signal db_estado_out : std_logic_vector (3 downto 0)  := "0000";

  -- Configurações do clock
  constant clockPeriod   : time      := 20 ns; -- clock de 50MHz
  signal keep_simulating : std_logic := '0';   -- delimita o tempo de geração do clock

  function EchoLen(nota: std_logic_vector(3 downto 0) := "0000") return time is
  begin
    if nota = "0000" then
      return 0 us;
    else
      return (2*to_integer(unsigned(nota)) - 1)*(58.82 us);
    end if;
  end function;

  type casos_teste_array is array (natural range <>) of std_logic_vector(3 downto 0);
  constant casos_teste : casos_teste_array :=
      (
        "0001", -- (2.04cm, G5)
        "0010", -- (3,99cm, F5)
        "0000", -- Invalido
        "1111", -- Invalido
        "0011", -- (6,80cm, E5)
        "0100", -- (9,69cm, D5)
        "1110", -- Invalido
        "0101", -- (12,75cm, C5)
        "0110", -- (15,81cm, B5)
        "1111", -- Invalido
        "1110", -- Invalido
        "0111", -- (18,70cm, A5)
        "1000", -- (22,01cm, G4)
        "1111", -- Invalido
        "1001", -- (25,84cm, F4)
        "1010", -- (28,56cm, E4)
        "0000", -- Invalido
        "1011", -- (32,30cm, D4)
        "1100", -- (35,70cm, C4)
        "1111", -- Invalido
        "1111", -- Invalido
        "0000", -- Invalido
        "1110", -- Invalido
        "1011", -- (31,11cm, D4)
        "1010", -- (27,54cm, E4)
        "1001", -- (25,50cm, F4)
        "1000", -- (23,46cm, G4)
        "1101", -- Invalido
        "0000", -- Invalido
        "1111"  -- Invalido
        -- inserir aqui outros casos de teste (inserir "," na linha anterior)
      );

  signal larguraPulso: time := 1 ns;

begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
  -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
  -- simulação de eventos
  clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;
  
  -- Conecta DUT (Device Under Test)
  dut: interface_hcsr04
       port map( 
           clock     => clock_in,
           reset     => reset_in,
           medir     => medir_in,
           echo      => echo_in,
           trigger   => trigger_out,
           notas     => notas_out,
           pronto    => pronto_out,
           db_medida => db_medida_out,
           db_estado => db_estado_out,
           db_reset  => open,
           db_medir  => open
       );

  -- geracao dos sinais de entrada (estimulos)
  stimulus: process is
  begin
  
    assert false report "Inicio das simulacoes" severity note;
    keep_simulating <= '1';
    
    ---- valores iniciais ----------------
    medir_in <= '0';
    echo_in  <= '0';

    ---- inicio: reset ----------------
    wait for 2*clockPeriod;
    reset_in <= '1';
    wait for 2 us;
    reset_in <= '0';
    wait until falling_edge(clock_in);

    ---- loop pelos casos de teste
    for i in casos_teste'range loop
        -- 1) determina largura do pulso echo
        assert false report "Caso de teste " & integer'image(i) severity note;
        larguraPulso <= EchoLen(casos_teste(i)); -- caso de teste "i"

        -- 2) envia pulso medir
        wait until falling_edge(clock_in);
        medir_in <= '1';
        wait for 5*clockPeriod;
        medir_in <= '0';

        -- 3) espera por trigger
        wait until falling_edge(trigger_out);
     
        -- 4) gera pulso de echo (largura = larguraPulso)
        wait until falling_edge(clock_in);
        wait until falling_edge(clock_in);
        echo_in <= '1';
        wait for larguraPulso;
        echo_in <= '0';
     
        -- 5) espera final da medida
        if (casos_teste(i) <= "1100" and casos_teste(i) /= "0000") then
          wait until pronto_out = '1';
        else
          wait for 50 us;
        end if;
        assert false report "Fim do caso " & integer'image(i) severity note;

        -- 6) espera entre casos de tese
        wait for 10 us;

    end loop;

    ---- final dos casos de teste da simulacao
    assert false report "Fim das simulacoes" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente (não retirar esta linha)
  end process;

end architecture;
