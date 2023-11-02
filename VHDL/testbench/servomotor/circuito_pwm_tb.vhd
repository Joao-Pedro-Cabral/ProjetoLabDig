-- circuito_pwm_tb
--------------------------------------------------------------------------
-- Descricao : 
--             testbench do componentge circuito_pwm
--
--------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     26/09/2021  1.0     Edson Midorikawa  criacao
--     24/08/2022  1.1     Edson Midorikawa  revisao
--     08/05/2023  1.2     Edson Midorikawa  revisao do componente
--     17/08/2023  1.3     Edson Midorikawa  revisao do componente
-------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;

entity circuito_pwm_tb is
end entity;

architecture tb of circuito_pwm_tb is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component circuito_pwm is
  generic (
      conf_periodo : integer;
      largura_000  : integer;
      largura_001  : integer;
      largura_010  : integer;
      largura_011  : integer;
      largura_100  : integer;
      largura_101  : integer;
      largura_110  : integer;
      largura_111  : integer
  );
    port (
      clock   : in  std_logic;
      reset   : in  std_logic;
      largura : in  std_logic_vector(2 downto 0);
      pwm     : out std_logic
    );
  end component;
  
  -- Declaração de sinais para conectar o componente a ser testado (DUT)
  --   valores iniciais para fins de simulacao (GHDL ou ModelSim)
  signal clock_in   : std_logic := '0';
  signal reset_in   : std_logic := '0';
  signal largura_in : std_logic_vector (2 downto 0) := "000";
  signal pwm_out    : std_logic := '0';


  -- Configurações do clock
  signal keep_simulating : std_logic := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod   : time := 20 ns;    -- f=50MHz
  
begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
  -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
  -- simulação de eventos
  clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;

 
  -- Conecta DUT (Device Under Test)
  DUT: circuito_pwm 
       generic map (
           conf_periodo => 1250, -- valores default
           largura_000  => 0,
           largura_001  => 50,
           largura_010  => 100,
           largura_011  => 200,
           largura_100  => 300,
           largura_101  => 400,
           largura_110  => 500,
           largura_111  => 600
       )
       port map( 
           clock   => clock_in,
           reset   => reset_in,
           largura => largura_in,
           pwm     => pwm_out
       );

  -- geracao dos sinais de entrada (estimulos)
  stimulus: process is
  begin
  
    assert false report "Inicio da simulacao" & LF & "... Simulacao ate 800 us. Aguarde o final da simulacao..." severity note;
    keep_simulating <= '1';
    
    ---- inicio: reset ----------------
    reset_in <= '1'; 
    wait for 2*clockPeriod;
    reset_in <= '0';
    wait for 2*clockPeriod;

    ---- casos de teste
    -- posicao=000
    largura_in <= "000";
    wait for 200 us;

    -- posicao=001
    largura_in <= "001";
    wait for 200 us;

    -- posicao=010
    largura_in <= "010";
    wait for 200 us;

    -- posicao=011
    largura_in <= "011";
    wait for 200 us;

    -- posicao=100
    largura_in <= "100";
    wait for 200 us;

    -- posicao=101
    largura_in <= "101";
    wait for 200 us;

    -- posicao=110
    largura_in <= "110";
    wait for 200 us;

    -- posicao=111
    largura_in <= "111";
    wait for 200 us;

    ---- final dos casos de teste  da simulacao
    assert false report "Fim da simulacao" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente
  end process;

end architecture;
