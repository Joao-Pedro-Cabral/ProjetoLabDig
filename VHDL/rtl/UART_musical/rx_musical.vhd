
library ieee;
use ieee.std_logic_1164.all;

entity rx_musical is
  port (
    clock         : in  std_logic;
    reset         : in  std_logic;
    rx            : in  std_logic;
    iniciar       : out std_logic;
    configurado   : out std_logic;
    configuracao  : out std_logic_vector(5 downto 0);
    jogada        : out std_logic;
    notas         : out std_logic_vector(3 downto 0);
    db_dado_rx    : out std_logic;
    db_estado     : out std_logic_vector(3 downto 0);
  );
end entity rx_musical;

architecture structural of rx_musical is

  component rx_musical_df is
    port (
      clock         : in  std_logic;
      zera          : in  std_logic;
      rx            : in  std_logic;
      fim_rx        : out std_logic;
      index         : out std_logic_vector(1 downto 0);
      configuracao  : out std_logic_vector(5 downto 0);
      notas         : out std_logic_vector(3 downto 0);
      db_dado_rx    : out std_logic
    );
  end component rx_musical_df;

  component rx_musical_uc is
    port (
      clock         : in  std_logic;
      reset         : in  std_logic;
      fim_rx        : in  std_logic;
      index         : in  std_logic_vector(1 downto 0);
      zera          : out std_logic;
      iniciar       : out std_logic;
      configurado   : out std_logic;
      jogada        : out std_logic;
      db_estado     : out std_logic_vector(3 downto 0)
    );
  end component rx_musical_uc;

  signal iniciar, zera, fim_rx: std_logic;
  signal index: std_logic_vector(1 downto 0);

begin

  df: rx_musical_df
    port map (
      clock        => clock,
      zera         => zera,
      rx           => rx,
      fim_rx       => fim_rx,
      index        => index,
      configuracao => configuracao,
      notas        => notas,
      db_dado_rx   => db_dado_rx
    );

  uc: rx_musical_uc
    port map (
      clock        => clock,
      reset        => reset,
      fim_rx       => fim_rx,
      index        => index,
      zera         => zera,
      iniciar      => iniciar,
      configurado  => configurado,
      jogada       => jogada,
      db_estado    => db_estado
    );
end architecture;