
library ieee;
use ieee.std_logic_1164.all;

entity interface_hcsr04 is
  port (
      clock     : in std_logic;
      reset     : in std_logic;
      medir     : in std_logic;
      echo      : in std_logic;
      trigger   : out std_logic;
      medida    : out std_logic_vector(11 downto 0); -- 3 digitos BCD
      pronto    : out std_logic;
      db_reset  : out std_logic;
      db_medir  : out std_logic;
      db_estado : out std_logic_vector(3 downto 0)
  );
end entity interface_hcsr04;

architecture structural of interface_hcsr04 is

  component interface_hcsr04_uc
    port ( 
        clock      : in  std_logic;
        reset      : in  std_logic;
        medir      : in  std_logic;
        echo       : in  std_logic;
        fim_medida : in  std_logic;
        zera       : out std_logic;
        gera       : out std_logic;
        registra   : out std_logic;
        pronto     : out std_logic;
        db_estado  : out std_logic_vector(3 downto 0)
    );
  end component;

  component interface_hcsr04_df
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
  end component;

  signal zera, registra, gera, fim_medida: std_logic;

  begin

    UC: interface_hcsr04_uc
      port map (
        clock => clock,
        reset => reset,
        medir => medir,
        echo => echo,
        fim_medida => fim_medida,
        zera => zera,
        gera => gera,
        registra => registra,
        pronto => pronto,
        db_estado => db_estado
      );

    DF: interface_hcsr04_df
      port map (
        clock => clock,
        pulso => echo,
        zera => zera,
        registra => registra,
        gera => gera,
        trigger => trigger,
        fim_medida => fim_medida,
        distancia => medida
      );

  -- depuracao
  db_reset <= reset;
  db_medir <= medir;

end architecture structural;
