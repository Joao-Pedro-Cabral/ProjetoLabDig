
-------------------------------------------------------
--! @file register_d_bit.vhdl
--! @brief Flip-flop tipo D com enable e reset assíncrono para binários
--! @author Joao Pedro Cabral Miranda (miranda.jp@usp.br)
--! @date 2022-07-18
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity register_d_bit is
    generic (
        reset_value: std_logic := '0'
    );
    port (
        D: in std_logic;
        clock: in std_logic;
        enable: in std_logic;
        reset: in std_logic;
        Q: out std_logic
    );
end entity register_d_bit;

architecture ffd of register_d_bit is
begin

    flip_flop: process(clock, enable, reset) is
    begin
        if(reset = '1') then
            Q <= reset_value;
        elsif(enable = '1' and rising_edge(clock)) then
            Q <= D;
        end if;
    end process;

end architecture ffd;