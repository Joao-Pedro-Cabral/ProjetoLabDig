library ieee;
use ieee.std_logic_1164.all;

entity mux16x1 is
    port(
        w : in std_logic_vector(15 downto 0);
        s : in std_logic_vector(3 downto 0);
        f : out std_logic
    );
end mux16x1;

architecture structural of mux16to1 is
component mux4x1 is
    port(
        A: in std_logic;
        B: in std_logic;
        C: in std_logic;
        D: in std_logic;
        S: in std_logic_vector(1 downto 0);
        Y: out std_logic
    );
end component mux4x1;

signal m : std_logic_vector(3 downto 0);

begin
    
    Mux1: mux4x1 port map (w(0), w(1), w(2), w(3), s(1 downto 0), m(0));
    Mux2: mux4x1 port map (w(4), w(5), w(6), w(7), s(1 downto 0), m(1));
    Mux3: mux4x1 port map (w(8), w(9), w(10), w(11), s(1 downto 0), m(2));
    Mux4: mux4x1 port map (w(12), w(13), w(14), w(15), s(1 downto 0), m(3));
    Mux5: mux4x1 port map (m(0), m(1), m(2), m(3), s(3 downto 2), f);

end structural;