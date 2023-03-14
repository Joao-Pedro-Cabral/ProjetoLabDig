
library ieee;
use ieee.std_logic_1164.all;

entity conversor12to4 is
    port(
        botoes_12 : in  std_logic_vector(11 downto 0);
        botoes_4  : out std_logic_vector(3 downto 0)
    );
end entity;

architecture structural of conversor12to4 is
begin
    -- Encoder 
    with botoes_12 select
    botoes_4 <=
                "1100" when "100000000000",
                "1011" when "010000000000",
                "1010" when "001000000000",
                "1001" when "000100000000",
                "1000" when "000010000000",
                "0111" when "000001000000",
                "0110" when "000000100000",
                "0101" when "000000010000",
                "0100" when "000000001000",
                "0011" when "000000000100",
                "0010" when "000000000010",
                "0001" when "000000000001",
                "0000" when others; -- Entradas inválidas -> 0 (Buzzer não toca)
end architecture;