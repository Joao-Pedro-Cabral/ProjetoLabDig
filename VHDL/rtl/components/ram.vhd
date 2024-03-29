-------------------------------------------------------------------
-- Arquivo   : ram.vhd
-- Projeto   : Genius Musical
-------------------------------------------------------------------
-- Descricao : módulo de memória RAM sincrona 16x4 
--             sinais we e ce ativos em baixo
--             codigo ADAPTADO do código encontrado no livro 
--             VHDL Descricao e Sintese de Circuitos Digitais
--             de Roberto D'Amore, LTC Editora.
-------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor                  Descricao
--     08/01/2020  1.0     Edson Midorikawa       criacao
--     01/02/2020  2.0     Antonio V.S.Neto       Atualizacao para 
--                                                RAM sincrona para
--                                                minimizar problemas
--                                                com Quartus.
--     02/02/2020  2.1     Edson Midorikawa       revisao de codigo e
--                                                arquitetura para 
--                                                simulacao com ModelSim 
--     07/01/2023  2.1.1   Edson Midorikawa       revisao
--     25/01/2023  2.1.2   João Pedro C. Miranda  novo nome de arquivo .mif
--     10/03/2023  2.2     Pedro H. Turini        modificações para size=12
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is
  generic(
    init_file     : string  := "rom.dat"
  );
   port (       
       clk          : in  std_logic;
       endereco     : in  std_logic_vector(3 downto 0);
       dado_entrada : in  std_logic_vector(3 downto 0);
       we           : in  std_logic;
       ce           : in  std_logic;
       dado_saida   : out std_logic_vector(3 downto 0)
    );
end entity ram;

-- Dados iniciais em arquivo MIF (para sintese com Intel Quartus Prime) 
architecture ram_mif of ram is
  type   arranjo_memoria is array(0 to 15) of std_logic_vector(3 downto 0);
  signal memoria : arranjo_memoria;
  
  -- Configuracao do Arquivo MIF
  attribute ram_init_file: string;
  attribute ram_init_file of memoria: signal is init_file;
  
begin

  process(clk)
  begin
    if (clk = '1' and clk'event) then
          if ce = '0' then -- dado armazenado na subida de "we" com "ce=0"
           
              -- Detecta ativacao de we (ativo baixo)
              if (we = '0') 
                  then memoria(to_integer(unsigned(endereco))) <= dado_entrada;
              end if;
            
          end if;
      end if;
  end process;

  -- saida da memoria
  dado_saida <= memoria(to_integer(unsigned(endereco)));
  
end architecture ram_mif;

-- Dados iniciais (para simulacao com Modelsim) 
architecture ram_multijogador of ram is
  type   arranjo_memoria is array(0 to 15) of std_logic_vector(3 downto 0);
  signal memoria : arranjo_memoria := ( --C_Major ? 
                                        "0001", --G5 (783.99 Hz)
                                        "0010", --F5
                                        "0011", --E5
                                        "0100", --D5
                                        "0101", --C5 (523.25 Hz)
                                        "0110", --B5
                                        "0111", --A5
                                        "1000", --G4
                                        "1001", --F4
                                        "1010", --E4
                                        "1011", --D4
                                        "1100", --C4 (261.63 Hz) 
                                        "1011", --D4
                                        "1010", --E4
                                        "1001", --F4
                                        "1000");--G4
  
begin

  process(clk)
  begin
    if (clk = '1' and clk'event) then
          if ce = '0' then -- dado armazenado na subida de "we" com "ce=0"
           
              -- Detecta ativacao de we (ativo baixo)
              if (we = '0') 
                  then memoria(to_integer(unsigned(endereco))) <= dado_entrada;
              end if;
            
          end if;
      end if;
  end process;

  -- saida da memoria
  dado_saida <= memoria(to_integer(unsigned(endereco)));

end architecture ram_multijogador;

architecture ram_treino_1 of ram is
  type   arranjo_memoria is array(0 to 15) of std_logic_vector(3 downto 0);
  signal memoria : arranjo_memoria := ( --Twinkle, Twinkle, Little Star
                                        "1100", --
                                        "1100", --
                                        "1000", --E5
                                        "1000",
                                        "0111", --D5
                                        "0111", --C5 (523.25 Hz)
                                        "1000", --B5
                                        "1000", --A5
                                        "1001", --G4
                                        "1001", --F4
                                        "1010", --E4
                                        "1010", --D4
                                        "1011", --C4 (261.63 Hz) 
                                        "1011", --D4
                                        "1100", --E4
                                        "1100");--G4
  
begin

  process(clk)
  begin
    if (clk = '1' and clk'event) then
          if ce = '0' then -- dado armazenado na subida de "we" com "ce=0"
           
              -- Detecta ativacao de we (ativo baixo)
              if (we = '0') 
                  then memoria(to_integer(unsigned(endereco))) <= dado_entrada;
              end if;
            
          end if;
      end if;
  end process;

  -- saida da memoria
  dado_saida <= memoria(to_integer(unsigned(endereco)));

end architecture ram_treino_1;

architecture ram_treino_2 of ram is
  type   arranjo_memoria is array(0 to 15) of std_logic_vector(3 downto 0);
  signal memoria : arranjo_memoria := ( --Hall of Fame (Pokemon)
                                        "0101", 
                                        "1000", 
                                        "0101", 
                                        "0100",
                                        "0101", 
                                        "1000", 
                                        "0101", 
                                        "0010", 
                                        "0011",
                                        "0100", 
                                        "0101", 
                                        "1000", 
                                        "0101", 
                                        "0100", 
                                        "0101", 
                                        "0101");
  
begin

  process(clk)
  begin
    if (clk = '1' and clk'event) then
          if ce = '0' then -- dado armazenado na subida de "we" com "ce=0"
           
              -- Detecta ativacao de we (ativo baixo)
              if (we = '0') 
                  then memoria(to_integer(unsigned(endereco))) <= dado_entrada;
              end if;
            
          end if;
      end if;
  end process;

  -- saida da memoria
  dado_saida <= memoria(to_integer(unsigned(endereco)));

end architecture ram_treino_2;