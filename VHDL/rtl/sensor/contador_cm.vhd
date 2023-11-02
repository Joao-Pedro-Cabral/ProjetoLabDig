
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity contador_cm is
  generic (
    constant R : integer := 100
  );
  port (
    clock   : in  std_logic;
    reset   : in  std_logic;
    pulso   : in  std_logic;
    digito0 : out std_logic_vector(3 downto 0);
    digito1 : out std_logic_vector(3 downto 0);
    digito2 : out std_logic_vector(3 downto 0);
    pronto  : out std_logic;
    fim     : out std_logic
  );
end entity;

architecture behavioral of contador_cm is

  component contador_cm_df
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
  end component;

  component contador_cm_uc
    port (
      clock      : in  std_logic;
      reset      : in  std_logic;
      pulso      : in  std_logic;
      tick       : in  std_logic;
      conta_bcd  : out std_logic;
      zera_bcd   : out std_logic;
      conta_tick : out std_logic;
      zera_tick  : out std_logic;
      pronto     : out std_logic
    );
  end component;

  signal conta_bcd, zera_bcd, conta_tick, zera_tick, tick : std_logic;

begin

  -- Componentes
  DF: contador_cm_df
    generic map (
      R => R
    )
    port map (
      clock       => clock,
      conta_bcd   => conta_bcd,
      zera_bcd    => zera_bcd,
      conta_tick  => conta_tick,
      zera_tick   => zera_tick,
      digito0     => digito0,
      digito1     => digito1,
      digito2     => digito2,
      fim         => fim,
      tick        => tick
    );

  UC: contador_cm_uc
    port map (
      clock => clock,
      reset => reset,
      pulso => pulso,
      tick => tick,
      conta_bcd => conta_bcd,
      zera_bcd => zera_bcd,
      conta_tick => conta_tick,
      zera_tick => zera_tick,
      pronto => pronto
    );

end architecture behavioral;