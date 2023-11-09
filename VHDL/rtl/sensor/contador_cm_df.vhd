
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity contador_cm_df is
  generic (
    constant R : integer := 100
  );
  port (
    clock      : in  std_logic;
    conta_bcd  : in  std_logic;
    zera_bcd   : in  std_logic;
    conta_tick : in  std_logic;
    zera_tick  : in  std_logic;
    digito0    : out std_logic_vector(3 downto 0);
    digito1    : out std_logic_vector(3 downto 0);
    digito2    : out std_logic_vector(3 downto 0);
    fim        : out std_logic;
    tick       : out std_logic
  );
end entity;

architecture structural of contador_cm_df is

  component contador_bcd_3digitos is
    port ( 
        clock   : in  std_logic;
        zera    : in  std_logic;
        conta   : in  std_logic;
        digito0 : out std_logic_vector(3 downto 0);
        digito1 : out std_logic_vector(3 downto 0);
        digito2 : out std_logic_vector(3 downto 0);
        fim     : out std_logic
    );
  end component;

  component contador_m
    generic (
        constant M : integer
    );
    port (
        clock   : in  std_logic;
        zera_as : in  std_logic;
        zera_s  : in  std_logic;
        conta   : in  std_logic;
        Q       : out std_logic_vector(natural(ceil(log2(real(M))))-1 downto 0);
        fim     : out std_logic;
        meio    : out std_logic;
        quarto  : out std_logic
    );
  end component;

begin

  -- Componentes
  gen_bcd: contador_bcd_3digitos
    port map (
      clock   => clock,
      zera    => zera_bcd,
      conta   => conta_bcd,
      digito0 => digito0,
      digito1 => digito1,
      digito2 => digito2,
      fim     => fim
    );

  gen_tick: contador_m
    generic map (
      M => R
    )
    port map(
      clock   => clock,
      zera_as => '0',
      zera_s  => zera_tick,
      conta   => conta_tick,
      Q       => open,
      fim     => open,
      meio    => open,
      quarto  => tick
    );
end architecture;