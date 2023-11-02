
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rx_serial_uc is
  port (
    clock       : in std_logic;
    reset       : in std_logic;
    dado        : in std_logic;
    tick        : in std_logic;
    fim         : in std_logic;
    carrega     : out std_logic;
    limpa       : out std_logic;
    zera        : out std_logic;
    desloca     : out std_logic;
    conta       : out std_logic;
    registra    : out std_logic;
    pronto      : out std_logic;
    db_estado   : out std_logic_vector(3 downto 0)
  );
end entity;

architecture rx_serial_uc_arch of rx_serial_uc is
  type estado is (inicial, preparacao, espera, recepcao, armazena, final);
  signal present_state, next_state: estado;
begin

  -- Registrador de estado
  process(reset, clock) begin
    if reset = '1' then
      present_state <= inicial;
    elsif rising_edge(clock) then
      present_state <= next_state;
    end if;
  end process;

  -- Lógica de Próximo Estado
  process(present_state, dado, tick, fim) begin
    next_state <= inicial;
    case(present_state) is
      when inicial =>
        if dado = '0' then next_state <= preparacao;
        else next_state <= inicial;
        end if;
      when preparacao =>
        next_state <= espera;
      when espera =>
        if tick = '1' then next_state <= recepcao;
        elsif fim = '1' then next_state <= armazena;
        else next_state <= espera;
        end if;
      when recepcao =>
        next_state <= espera;
      when armazena =>
          next_state <= final;
      when final =>
          next_state <= inicial;
      when others =>
          next_state <= inicial;
    end case;
  end process;

  -- Lógica de Saída (Moore)
  carrega  <= '1' when present_state = preparacao else '0';
  limpa    <= '1' when present_state = preparacao else '0';
  zera     <= '1' when present_state = preparacao else '0';
  desloca  <= '1' when present_state = recepcao   else '0';
  conta    <= '1' when present_state = recepcao   else '0';
  registra <= '1' when present_state = armazena   else '0';
  pronto   <= '1' when present_state = final      else '0';

  -- Depuração
  with present_state select
      db_estado <= "0000" when inicial,
                   "0001" when preparacao,
                   "0010" when espera,
                   "0100" when recepcao,
                   "0101" when armazena,
                   "1111" when final,
                   "1110" when others;

end architecture;