
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity tx_musical_df is
  port (
    clock         : in  std_logic;
    zera          : in  std_logic;
    configurar    : in  std_logic;
    enviar        : in  std_logic;
    contaJ        : in  std_logic;
    modo          : in  std_logic_vector(1 downto 0);
    dificuldade   : in  std_logic_vector(3 downto 0);
    perdeu        : in  std_logic;
    ganhou        : in  std_logic;
    notas         : in  std_logic_vector(3 downto 0);
    jogador       : in  std_logic;
    jogada        : in  std_logic_vector(3 downto 0);
    rodada        : in  std_logic_vector(3 downto 0);
    fim_tx        : out std_logic;
    fimJ          : out std_logic;
    tx            : out std_logic;
    db_dado_tx    : out std_logic
  );
end entity tx_musical_df;

architecture structural of tx_musical_df is

  component tx_serial is
    port (
        clock           : in  std_logic;
        reset           : in  std_logic;
        partida         : in  std_logic;
        dados_ascii     : in  std_logic_vector(7 downto 0);
        saida_serial    : out std_logic;
        pronto          : out std_logic;
        db_partida      : out std_logic;
        db_saida_serial : out std_logic;
        db_estado       : out std_logic_vector(3 downto 0)
    );
  end component;

  component contador_m is
    generic (
        constant M: integer := 100 -- modulo do contador
    );
    port (
        clock   : in  std_logic;
        zera_as : in  std_logic;
        zera_s  : in  std_logic;
        conta   : in  std_logic;
        Q       : out std_logic_vector(natural(ceil(log2(real(M))))-1 downto 0);
        fim     : out std_logic;
        meio    : out std_logic;
        quarto  : out std_logic
    );
  end component;

  component mux4x1 is
    port(
        A: in  std_logic;
        B: in  std_logic;
        C: in  std_logic;
        D: in  std_logic;
        S: in  std_logic_vector(1 downto 0);
        Y: out std_logic
    );
  end component mux4x1;

  signal dado_tx, dado_00, dado_01, dado_10, dado_11: std_logic_vector(7 downto 0);
  signal seletor, contagem: std_logic_vector(1 downto 0);

begin

  transmissor: tx_serial
    port map (
      clock           => clock,
      reset           => limpa,
      partida         => enviar,
      dados_ascii     => dado_tx,
      saida_serial    => tx,
      pronto          => fim_tx,
      db_partida      => open,
      db_saida_serial => db_dado_tx,
      db_estado       => open
    );

  contador: contador_m
    generic map (
      M => 3
    )
    port map (
      clock     => clock,
      zera_as   => '0',
      zera_s    => limpa,
      conta     => contaJ,
      Q         => open,
      fim       => fimJ,
      meio      => open,
      quarto    => open
    );

  mux: mux4x1
    port map (
      A => dado_00,
      B => dado_01,
      C => dado_10,
      D => dado_11,
      S => seletor,
      Y => dado_tx
    );

  -- Seletor
  seletor(0) <= contagem(0) or configurar;
  seletor(1) <= contagem(1) or configurar;

  -- Dados
  dado_00 <= "00" & modo & dificuldade;
  dado_01 <= "01" & perdeu & ganhou & notas;
  dado_10 <= "10" & '0' & jogador & jogada;
  dado_11 <= "11" & "00" & rodada;

end architecture structural;