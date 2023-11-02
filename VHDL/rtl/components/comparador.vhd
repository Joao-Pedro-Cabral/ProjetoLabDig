-------------------------------------------------------------------
-- Arquivo   : comparador.vhd
-- Projeto   : Genius Musical
-------------------------------------------------------------------
-- Descricao : comparador de magnitude de N bits 
-------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     02/01/2021  1.0     Edson Midorikawa  criacao
--     07/01/2023  1.1     Edson Midorikawa  revisao
--     10/03/2023  2.0     João Pedro C. M.  Genérico
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity comparador is
    generic(
        constant N : integer := 8
    );
    port (
        A       : in  std_logic_vector(N-1 downto 0);
        B       : in  std_logic_vector(N-1 downto 0);
        igual   : out std_logic
    );
end entity comparador;

architecture dataflow of comparador is
    signal xor_vector  : std_logic_vector(N-1 downto 0);
    signal or_vector   : std_logic_vector(N-1 downto 0);
begin

    -- bit 1 => diferença
    xor_vector <= A xor B;

    or_vector(0) <= xor_vector(0);
    
    -- Detectar se há algum bit distinto
    or_gen: for i in 1 to N - 1 generate
        or_vector(i) <= or_vector(i-1) or xor_vector(i); 
    end generate or_gen;

    igual <= not or_vector(N-1);
    
end architecture dataflow;