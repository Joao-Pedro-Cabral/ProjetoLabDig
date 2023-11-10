library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity rx_serial_fd is
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
end entity;

architecture rx_serial_fd_arch of rx_serial_fd is

  component deslocador_n
    generic (
        constant N : integer
    );
    port (
        clock          : in  std_logic;
        reset          : in  std_logic;
        carrega        : in  std_logic; 
        desloca        : in  std_logic; 
        entrada_serial : in  std_logic; 
        dados          : in  std_logic_vector(N-1 downto 0);
        saida          : out std_logic_vector(N-1 downto 0)
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

  component registrador_n
    generic (
        constant N: integer := 8
    );
    port (
        clock  : in  std_logic;
        clear  : in  std_logic;
        enable : in  std_logic;
        D      : in  std_logic_vector (N-1 downto 0);
        Q      : out std_logic_vector (N-1 downto 0) 
    );
  end component;

  signal dado_deslocado: std_logic_vector(10 downto 0);
  signal dado_armazenado: std_logic_vector(8 downto 0);
  signal limpa_reg: std_logic;

begin

  shift_register: deslocador_n
    generic map (
      N => 11
    )
    port map (
      clock          => clock,
      reset          => reset,
      carrega        => carrega,
      desloca        => desloca,
      entrada_serial => dado_serial,
      dados          => "11111111111",
      saida          => dado_deslocado
    );

  conta_dado: contador_m
    generic map (
      M => 12
    ) 
    port map (
      clock   => clock,
      zera_as => '0',
      zera_s  => zera,
      conta   => conta,
      Q       => open,
      fim     => fim,
      meio    => open,
      quarto  => open
    );

  registrador_jogada: registrador_n
    generic map(
      N => 9
    )
    port map (
        clock => clock,
        clear => limpa_reg,
        enable => registra,
        D => dado_deslocado(9 downto 1),
        Q => dado_armazenado
    );

  limpa_reg <= limpa or reset;

  dado_recebido     <= dado_armazenado(7 downto 0);
  paridade_recebida <= dado_armazenado(8);
end architecture;