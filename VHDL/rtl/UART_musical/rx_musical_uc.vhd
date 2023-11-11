
library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity rx_musical_uc is
  port (
    clock         : in  std_logic;
    reset         : in  std_logic;
    fim_rx        : in  std_logic;
    index         : in  std_logic_vector(1 downto 0);
    zera          : out std_logic;
    iniciar       : out std_logic;
    configurado   : out std_logic;
    jogada        : out std_logic;
    db_estado     : out std_logic_vector(3 downto 0)
  );
end entity rx_musical_uc;

architecture fsm of rx_musical_uc is

  type tipo_estado is (inicial, espera_dado, decodifica, envia_iniciar, envia_config, envia_nota);
  signal Eatual, Eprox: tipo_estado;

begin

  -- estado
  process (reset, clock)
    begin
      if reset = '1' then
        Eatual <= inicial;
      elsif clock'event and clock = '1' then
        Eatual <= Eprox;
      end if;
    end process;

  -- lógica de próximo estado
  process (Eatual, fim_rx, index)
    begin
      case Eatual is
        when inicial =>         Eprox <= espera_dado;
        when espera_dado =>     if fim_rx = '1' then Eprox <= decodifica;
                                else Eprox <= espera_dado;
                                end if;
        when decodifica =>      if index = "00" then Eprox <= envia_iniciar;
                                elsif index = "01" then Eprox <= envia_nota;
                                else Eprox <= espera_dado;
                                end if;
        when envia_iniciar =>   Eprox <= envia_config;
        when envia_config =>    Eprox <= espera_dado;
        when envia_nota =>      Eprox <= espera_dado;
        when others =>          Eprox <= inicial;
      end case;
    end process;

  -- saidas de controle
  with Eatual select
      zera        <= '1' when inicial, '0' when others;
  with Eatual select
      iniciar     <= '1' when envia_iniciar, '0' when others;
  with Eatual select
      configurado <= '1' when envia_config, '0' when others;
  with Eatual select
      jogada      <= '1' when envia_nota, '0' when others;

  -- depuração
  with present_state select
    db_estado <= "0000" when inicial,
                 "0001" when espera_dado,
                 "0010" when decodifica,
                 "0011" when envia_iniciar,
                 "0100" when envia_config,
                 "0101" when envia_nota,
                 "1110" when others;

end architecture;