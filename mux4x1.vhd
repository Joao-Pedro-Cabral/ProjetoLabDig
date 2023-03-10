-------------------------------------------------------
--! @file instruction_memory.vhdl
--! @brief mux 4 para 1 
--! @author Joao Pedro Cabral Miranda (miranda.jp@usp.br)
--! @date 2022-05-26
-------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux4x1 is
    generic(
        size: natural := 12
    );
    port(
        A: in std_logic;
        B: in std_logic;
        C: in std_logic;
        D: in std_logic;
        S: in std_logic_vector(1 downto 0);
        Y: out std_logic
    );
end entity mux4x1;

architecture structural of mux4x1 is
begin
    Y <= A when S = "00" else
         B when S = "01" else
         C when S = "10" else
         D;
end architecture structural;