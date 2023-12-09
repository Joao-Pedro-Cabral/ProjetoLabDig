
library ieee;
use ieee.std_logic_1164.all;

entity conversor_bcd_nota is
  port(
    digitos_bcd : in  std_logic_vector(11 downto 0);
    nota        : out std_logic_vector(3 downto 0)
  );
end entity;

architecture behavioral of conversor_bcd_nota is

begin

  nota <= "0001" when digitos_bcd >= X"004" and digitos_bcd < X"006" else
          "0010" when digitos_bcd >= X"006" and digitos_bcd < X"008" else
          "0011" when digitos_bcd >= X"008" and digitos_bcd < X"010" else
          "0100" when digitos_bcd >= X"010" and digitos_bcd < X"012" else
          "0101" when digitos_bcd >= X"012" and digitos_bcd < X"014" else
          "0110" when digitos_bcd >= X"014" and digitos_bcd < X"016" else
          "0111" when digitos_bcd >= X"016" and digitos_bcd < X"018" else
          "1000" when digitos_bcd >= X"018" and digitos_bcd < X"020" else
          "1001" when digitos_bcd >= X"020" and digitos_bcd < X"022" else
          "1010" when digitos_bcd >= X"022" and digitos_bcd < X"024" else
          "1011" when digitos_bcd >= X"024" and digitos_bcd < X"026" else
          "1100" when digitos_bcd >= X"026" and digitos_bcd < X"028" else
          "0000";

end architecture behavioral;