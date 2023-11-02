library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity controle_servo is
  port (
    clock      : in  std_logic;
    reset      : in  std_logic;
    posicao    : in  std_logic_vector(2 downto 0);
    pwm        : out std_logic;
    db_reset   : out std_logic;
    db_pwm     : out std_logic;
    db_posicao : out std_logic_vector(2 downto 0)
  );
end entity controle_servo;

architecture structural of controle_servo is
  component circuito_pwm is
    generic (
      conf_periodo : integer := 1250;
      largura_000   : integer :=    0;
      largura_001   : integer :=   50;
      largura_010   : integer :=  500;
      largura_011   : integer := 1000;
      largura_100   : integer :=    0;
      largura_101   : integer :=   50;
      largura_110   : integer :=  500;
      largura_111   : integer := 1000
  );
  port (
      clock   : in  std_logic;
      reset   : in  std_logic;
      largura : in  std_logic_vector(2 downto 0);
      pwm     : out std_logic
    );
  end component circuito_pwm;

  signal s_pwm : std_logic;

begin

  controlador_servo_motor: circuito_pwm
    generic map (
      conf_periodo  => 1000000,
      largura_000   => 35000, -- 0.7 ms
      largura_001   => 45700, -- 0.914 ms
      largura_010   => 56450, -- 1.129 ms
      largura_011   => 67150, -- 1.343 ms
      largura_100   => 77850, -- 1.557 ms
      largura_101   => 88550, -- 1.771 ms
      largura_110   => 99300, -- 1.986 ms
      largura_111   => 110000 -- 2.2 ms
    )
    port map (
      clock => clock,
      reset => reset,
      largura => posicao,
      pwm => s_pwm
    );

  -- saidas
  pwm <= s_pwm;

  -- depuracao
  db_reset <= reset;
  db_pwm <= s_pwm;
  db_posicao <= posicao;
end architecture structural;