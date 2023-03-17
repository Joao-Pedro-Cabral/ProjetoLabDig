
library ieee;
use ieee.std_logic_1164.all;

entity LSFR_viciado is
    port(
        clock           : in  std_logic;
        reset           : in  std_logic;
        pseudo_random   : out std_logic_vector(3 downto 0) -- Número pseudo-aleatório
    );
end entity;

architecture rtl of LSFR_viciado is

    component register_d_bit is
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
    end component register_d_bit;

    signal pse_rand : std_logic_vector(4 downto 0);

begin

    -- LSFR
        -- Multiplicação polinomial
    register_generate: for i in 0 to 3 generate
        generate_0: if i = 0 generate
            register0: component register_d_bit generic map('1') port map(pse_rand(i), clock, '1', reset, pse_rand(i + 1));
        end generate generate_0;
        generate_i: if i > 0 generate
            registeri: component register_d_bit generic map('0') port map(pse_rand(i), clock, '1', reset, pse_rand(i + 1));
        end generate generate_i;
    end generate register_generate;

        -- Resto da divisão polinomial
    pse_rand(0) <= pse_rand(4) xor pse_rand(3);

    -- Viciando a saída(C5(2x), G4,(2x), C4(2x))
    with pse_rand(4 downto 1) select
    pseudo_random <= 
                    "0000" when "0000", -- Valor impossível
                                        -- Valores não viciados
                    "0001" when "0001",
                    "0010" when "0010",
                    "0011" when "0011",
                    "0100" when "0100",
                    "0101" when "0101",
                    "0110" when "0110",
                    "0111" when "0111",
                    "1000" when "1000",
                    "1001" when "1001",
                    "1010" when "1010",
                    "1011" when "1011",
                    "1100" when "1100",
                                        -- Valores viciados
                    "0101" when "1101", -- C5
                    "1000" when "1110", -- G4
                    "1100" when "1111", -- C4
                    "0000" when others;
end architecture;