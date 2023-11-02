
library ieee;
use ieee.std_logic_1164.all;

entity interface_hcsr04_df is
  port (
    clock     : in  std_logic;
    pulso     : in  std_logic;
    zera      : in  std_logic;
    registra  : in  std_logic;
    gera      : in  std_logic;
    trigger   : out std_logic;
    fim_medida: out std_logic;
    distancia : out std_logic_vector(11 downto 0)
  );
end entity interface_hcsr04_df;

architecture structural of interface_hcsr04_df is

  component contador_cm
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
  end component;

  component gerador_pulso
    generic (
      largura: integer:= 25
    );
    port(
        clock  : in  std_logic;
        reset  : in  std_logic;
        gera   : in  std_logic;
        para   : in  std_logic;
        pulso  : out std_logic;
        pronto : out std_logic
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

  signal digito0, digito1, digito2 : std_logic_vector(3 downto 0);
  signal digitos: std_logic_vector(11 downto 0);

begin

  contador: contador_cm
    generic map (
      R => 2941
    )
    port map (
      clock   => clock,
      reset   => zera,
      pulso   => pulso,
      digito0 => digito0,
      digito1 => digito1,
      digito2 => digito2,
      pronto  => fim_medida,
      fim     => open
    );

  gen_pulso: gerador_pulso
    generic map (
      largura => 500
    )
    port map (
      clock   => clock,
      reset   => zera,
      gera    => gera,
      para    => '0',
      pulso   => trigger,
      pronto  => open
    );

  reg: registrador_n
    generic map (
      N => 12
    )
    port map (
      clock   => clock,
      clear   => zera,
      enable  => registra,
      D       => digitos,
      Q       => distancia
    );

  digitos <= digito2 & digito1 & digito0;

end architecture;