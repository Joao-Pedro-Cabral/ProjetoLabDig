
library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity rx_musical_df is
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
end entity rx_musical_df;

architecture structural of rx_musical_df is

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

  signal dado_recebido: std_logic_vector(7 downto 0);

begin

  receptor: rx_serial
    port map (
      clock             => clock,
      reset             => zera,
      dado_serial       => rx,
      dado_recebido     => dado_recebido,
      paridade_recebida => open,
      pronto            => fim_rx,
      db_dado_serial    => db_dado_rx,
      db_estado         => open
    );

  index        <= dado_recebido(1 downto 0);
  configuracao <= dado_recebido(5 downto 0);
  notas        <= dado_recebido(3 downto 0);

end architecture;