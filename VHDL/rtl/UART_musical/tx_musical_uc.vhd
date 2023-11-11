
library ieee;
use ieee.std_logic_1164.all;

entity tx_musical_uc is
  port (
    clock         : in  std_logic;
    reset         : in  std_logic;
    enviar_config : in  std_logic;
    enviar_jogada : in  std_logic;
    fim_tx        : in  std_logic;
    fimJ          : in  std_logic;
    zera          : out std_logic;
    configurar    : out std_logic;
    enviar        : out std_logic;
    contaJ        : out std_logic;
    pronto        : out std_logic;
    db_estado     : out std_logic_vector(3 downto 0)
  );
end entity tx_musical_uc;

architecture fsm of tx_musical_uc is

  type tipo_estado is (inicial, envia_config, espera_config, envia_jogada, espera_jogada, checa_jogada, final);
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
  process (Eatual, enviar_config, enviar_jogada, fim_tx, fimJ)
    begin
      case Eatual is
        when inicial =>         if enviar_config = '1' then Eprox <= envia_config;
                                elsif enviar_jogada = '1' then Eprox <= envia_jogada;
                                else Eprox <= inicial;
                                end if;
        when envia_config =>    Eprox <= espera_config;
        when espera_config =>   if fim_tx = '1' then Eprox <= final;
                                else Eprox <= espera_config;
                                end if;
        when envia_jogada =>    Eprox <= espera_jogada;
        when espera_jogada =>   if fim_tx = '1' then Eprox <= checa_jogada;
                                else Eprox <= espera_jogada;
                                end if;
        when checa_jogada =>    if fimJ = '1' then Eprox <= final;
                                else Eprox <= envia_jogada;
                                end if;
        when final =>           Eprox <= inicial;
        when others =>          Eprox <= inicial;
      end case;
    end process;

  -- saidas de controle
  with Eatual select
      zera        <= '1' when inicial, '0' when others;
  with Eatual select
      configurar  <= '1' when envia_config | espera_config, '0' when others;
  with Eatual select
      enviar      <= '1' when envia_config | envia_jogada, '0' when others;
  with Eatual select
      contaJ      <= '1' when checa_jogada, '0' when others;
  with Eatual select
      pronto      <= '1' when final, '0' when others;

  -- depuração
  with Eatual select
    db_estado <= "0000" when inicial,
                 "0001" when envia_config,
                 "0010" when espera_config,
                 "0011" when envia_jogada,
                 "0100" when espera_jogada,
                 "0101" when checa_jogada,
                 "1111" when final,
                 "1110" when others;

end architecture fsm;