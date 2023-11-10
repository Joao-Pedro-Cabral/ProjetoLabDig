
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity rx_serial is
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
end entity;

architecture estrutural of rx_serial is

  component rx_serial_fd
    port (
        clock             : in  std_logic;
        reset             : in  std_logic;
        carrega           : in  std_logic;
        limpa             : in  std_logic;
        zera              : in  std_logic;
        desloca           : in  std_logic;
        conta             : in  std_logic;
        registra          : in  std_logic;
        dado_serial       : in  std_logic;
        dado_recebido     : out std_logic_vector(7 downto 0);
        paridade_recebida : out std_logic;
        fim               : out std_logic
    );
  end component;

  component rx_serial_uc
    port (
      clock       : in std_logic;
      reset       : in std_logic;
      dado        : in std_logic;
      tick        : in std_logic;
      fim         : in std_logic;
      carrega     : out std_logic;
      limpa       : out std_logic;
      zera        : out std_logic;
      desloca     : out std_logic;
      conta       : out std_logic;
      registra    : out std_logic;
      pronto      : out std_logic;
      db_estado   : out std_logic_vector(3 downto 0)
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

  signal carrega, limpa, zera, desloca, conta, registra, fim, tick : std_logic;
begin

  df: rx_serial_fd
    port map(
      clock => clock,
      reset => reset,
      carrega => carrega,
      limpa => limpa,
      zera => zera,
      desloca => desloca,
      conta => conta,
      registra => registra,
      dado_serial => dado_serial,
      dado_recebido => dado_recebido,
      paridade_recebida => paridade_recebida,
      fim => fim
    );

  uc: rx_serial_uc
    port map(
      clock => clock,
      reset => reset,
      dado => dado_serial,
      tick => tick,
      fim => fim,
      carrega => carrega,
      limpa => limpa,
      zera => zera,
      desloca => desloca,
      conta => conta,
      registra => registra,
      pronto => pronto,
      db_estado => db_estado
    );

  -- gerador de tick
  -- fator de divisao para 115.200 bauds (434=50M/115200)
  gen_tick: contador_m
    generic map (
      M => 434 -- 115200 bauds
    ) 
    port map (
      clock   => clock,
      zera_as => '0',
      zera_s  => zera,
      conta   => '1',
      Q       => open,
      fim     => open,
      meio    => tick,
      quarto  => open
    );

  -- debug
  db_dado_serial <= dado_serial;
end architecture;