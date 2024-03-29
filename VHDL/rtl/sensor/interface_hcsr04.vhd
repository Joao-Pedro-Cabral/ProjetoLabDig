
library ieee;
use ieee.std_logic_1164.all;

entity interface_hcsr04 is
  port (
      clock     : in std_logic;
      reset     : in std_logic;
      medir     : in std_logic;
      echo      : in std_logic;
      trigger   : out std_logic;
      notas     : out std_logic_vector(3 downto 0);
      pronto    : out std_logic;
      db_medida : out std_logic_vector(11 downto 0);
      db_reset  : out std_logic;
      db_medir  : out std_logic;
      db_estado : out std_logic_vector(3 downto 0)
  );
end entity interface_hcsr04;

architecture structural of interface_hcsr04 is

  component interface_hcsr04_uc
    port ( 
      clock        : in  std_logic;
      reset        : in  std_logic;
      medir        : in  std_logic;
      echo         : in  std_logic;
      fim_medida   : in  std_logic;
      nota_valida  : in  std_logic;
      fimT         : in  std_logic;
      zera         : out std_logic;
      zeraT        : out std_logic;
      contaT       : out std_logic;
      gera         : out std_logic;
      registra     : out std_logic;
      pronto       : out std_logic;
      db_estado    : out std_logic_vector(3 downto 0)
    );
  end component;

  component interface_hcsr04_df
    port (
      clock        : in  std_logic;
      pulso        : in  std_logic;
      zera         : in  std_logic;
      zeraT        : in  std_logic;
      contaT       : in  std_logic;
      registra     : in  std_logic;
      gera         : in  std_logic;
      fimT         : out std_logic;
      trigger      : out std_logic;
      fim_medida   : out std_logic;
      nota_valida  : out std_logic;
      notas        : out std_logic_vector(3 downto 0);
      db_distancia : out std_logic_vector(11 downto 0)
    );
  end component;

  signal zeraT, nota_valida, zera, registra, gera, fim_medida, contaT, fimT: std_logic;

  begin

    UC: interface_hcsr04_uc
      port map (
        clock => clock,
        reset => reset,
        medir => medir,
        echo => echo,
        fim_medida => fim_medida,
        nota_valida => nota_valida,
        zera => zera,
        zeraT => zeraT,
        gera => gera,
        contaT => contaT,
        fimT => fimT,
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
        contaT => contaT,
        nota_valida => nota_valida,
        zeraT => zeraT,
        fimT => fimT,
        gera => gera,
        trigger => trigger,
        fim_medida => fim_medida,
        notas => notas,
        db_distancia => db_medida
      );

  -- depuracao
  db_reset <= reset;
  db_medir <= medir;

end architecture structural;
