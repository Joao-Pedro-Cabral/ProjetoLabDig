
library ieee;
use ieee.std_logic_1164.all;

entity contador_cm_uc is
  port (
    clock      : in  std_logic;
    reset      : in  std_logic;
    pulso      : in  std_logic;
    tick       : in  std_logic;
    conta_bcd  : out std_logic;
    zera_bcd   : out std_logic;
    conta_tick : out std_logic;
    zera_tick  : out std_logic;
    pronto     : out std_logic
  );
end entity;

architecture behavioral of contador_cm_uc is
  type tipo_estado is (inicial, espera, conta, final);
  signal present_state, next_state : tipo_estado;
begin

  -- mudança de estado
  process (reset, clock) begin
    if reset = '1' then
      present_state <= inicial;
    elsif clock'event and clock = '1' then
      present_state <= next_state;
    end if;
  end process;

  -- logica de proximo estado
  process(present_state, pulso, tick) begin
    next_state <= inicial;
    case present_state is
      when inicial => 
        if pulso = '1' then next_state <= espera;
        else next_state <= inicial;
        end if;
      when espera =>
        if pulso = '0' then next_state <= final;
        elsif tick = '1' then next_state <= conta;
        else next_state <= espera;
        end if;
      when conta =>
        next_state <= espera;
      when final =>
        next_state <= inicial;
      when others =>
        next_state <= inicial;
    end case;
  end process;

  -- logica de saída
  conta_bcd  <= '1' when present_state = conta   else '0';
  zera_bcd   <= '1' when present_state = inicial else '0';
  conta_tick <= '1' when present_state = espera or present_state = conta else '0';
  zera_tick  <= '1' when present_state = inicial else '0';
  pronto     <= '1' when present_state = final   else '0';

end architecture;
