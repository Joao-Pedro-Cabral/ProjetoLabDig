
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity tx_musical_df is
  port (
    clock         : in  std_logic;
    zera          : in  std_logic;
    amostrar      : in  std_logic;
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

  signal dado_tx, dado_00, dado_01, dado_10, dado_11: std_logic_vector(7 downto 0);
  signal modo2 : std_logic_vector(1 downto 0);
  signal dificuldade2, notas2, jogada2, rodada2: std_logic_vector(3 downto 0);
  signal perdeu2, ganhou2, jogador2: std_logic;
  signal seletor, contagem: std_logic_vector(1 downto 0);

begin

  transmissor: tx_serial
    port map (
      clock           => clock,
      reset           => zera,
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
      zera_s    => zera,
      conta     => contaJ,
      Q         => contagem,
      fim       => fimJ,
      meio      => open,
      quarto    => open
    );

  -- Amostrar as entradas
  process(clock, amostrar)
    begin
      if (clock'event and clock='1') then
        if (amostrar='1') then
          modo2        <= modo;
          dificuldade2 <= dificuldade;
          notas2       <= notas;
          jogada2      <= jogada;
          rodada2      <= rodada;
          perdeu2      <= perdeu;
          ganhou2      <= ganhou;
          jogador2     <= jogador;
        end if;
      end if;
    end process;

  -- Seletor
  seletor(0) <= contagem(0) or configurar;
  seletor(1) <= contagem(1) or configurar;
  dado_tx    <= dado_01 when seletor = "00" else
                dado_10 when seletor = "01" else
                dado_11 when seletor = "10" else
                dado_00;

  -- Dados
  dado_01 <= "00" & perdeu2 & ganhou2 & notas2;
  dado_10 <= "01" & '0' & jogador2 & jogada2;
  dado_11 <= "10" & "00" & rodada2;
  dado_00 <= "11" & modo2 & dificuldade2;

end architecture structural;