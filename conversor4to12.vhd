
library ieee;
use ieee.std_logic_1164.all;

entity conversor4to12 is
    port(
        botoes_4  : in  std_logic_vector(3 downto 0);
        ativar    : in  std_logic;
        botoes_12 : out std_logic_vector(11 downto 0)
    );
end entity;

architecture structural of conversor4to12 is 
begin
    -- Decoder -> Entradas inválidas equivalem a 0, ou seja, não houve jogada
    botoes_12(0)  <= ativar and (botoes_4(0))     and (not botoes_4(1)) and (not botoes_4(2)) and (not botoes_4(3));
    botoes_12(1)  <= ativar and (not botoes_4(0)) and (botoes_4(1))     and (not botoes_4(2)) and (not botoes_4(3));
    botoes_12(2)  <= ativar and (botoes_4(0))     and (botoes_4(1))     and (not botoes_4(2)) and (not botoes_4(3));
    botoes_12(3)  <= ativar and (not botoes_4(0)) and (not botoes_4(1)) and (botoes_4(2))     and (not botoes_4(3));
    botoes_12(4)  <= ativar and (botoes_4(0))     and (not botoes_4(1)) and (botoes_4(2))     and (not botoes_4(3));
    botoes_12(5)  <= ativar and (not botoes_4(0)) and (botoes_4(1))     and (botoes_4(2))     and (not botoes_4(3));
    botoes_12(6)  <= ativar and (botoes_4(0))     and (botoes_4(1))     and (botoes_4(2))     and (not botoes_4(3));
    botoes_12(7)  <= ativar and (not botoes_4(0)) and (not botoes_4(1)) and (not botoes_4(2)) and (botoes_4(3));
    botoes_12(8)  <= ativar and (botoes_4(0))     and (not botoes_4(1)) and (not botoes_4(2)) and (botoes_4(3));
    botoes_12(9)  <= ativar and (not botoes_4(0)) and (botoes_4(1))     and (not botoes_4(2)) and (botoes_4(3));
    botoes_12(10) <= ativar and (botoes_4(0))     and (botoes_4(1))     and (not botoes_4(2)) and (botoes_4(3));
    botoes_12(11) <= ativar and (not botoes_4(0)) and (not botoes_4(1)) and (botoes_4(2))     and (botoes_4(3));
end architecture;