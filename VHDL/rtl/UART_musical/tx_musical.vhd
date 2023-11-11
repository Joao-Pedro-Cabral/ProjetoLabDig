
library ieee;
use ieee.std_logic_1164.all;

entity tx_musical is
  port (
    clock         : in  std_logic;
    reset         : in  std_logic;
    enviar_config : in  std_logic;
    enviar_jogada : in  std_logic;
    modo          : in  std_logic_vector(1 downto 0);
    dificuldade   : in  std_logic_vector(3 downto 0);
    perdeu        : in  std_logic;
    ganhou        : in  std_logic;
    notas         : in  std_logic_vector(3 downto 0);
    jogador       : in  std_logic;
    jogada        : in  std_logic_vector(3 downto 0);
    rodada        : in  std_logic_vector(3 downto 0);
    tx            : out std_logic;
    pronto        : out std_logic;
    db_dado_tx    : out std_logic;
    db_estado     : out std_logic_vector(3 downto 0)
  );
end entity tx_musical;

architecture structural of tx_musical is

  component tx_musical_df is
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
  end component tx_musical_df;

  component tx_musical_uc is
    port (
      clock         : in  std_logic;
      reset         : in  std_logic;
      enviar_config : in  std_logic;
      enviar_jogada : in  std_logic;
      fim_tx        : in  std_logic;
      fimJ          : in  std_logic;
      zera          : out std_logic;
      amostrar      : out std_logic;
      configurar    : out std_logic;
      enviar        : out std_logic;
      contaJ        : out std_logic;
      pronto        : out std_logic;
      db_estado     : out std_logic_vector(3 downto 0)
    );
  end component tx_musical_uc;

  signal zera, amostrar, configurar, enviar, contaJ, fim_tx, fimJ: std_logic;

begin

  df: tx_musical_df
    port map (
      clock       => clock,
      zera        => zera,
      amostrar    => amostrar,
      configurar  => configurar,
      enviar      => enviar,
      contaJ      => contaJ,
      modo        => modo,
      dificuldade => dificuldade,
      perdeu      => perdeu,
      ganhou      => ganhou,
      notas       => notas,
      jogador     => jogador,
      jogada      => jogada,
      rodada      => rodada,
      fim_tx      => fim_tx,
      fimJ        => fimJ,
      tx          => tx,
      db_dado_tx  => db_dado_tx
    );

  uc: tx_musical_uc
    port map (
      clock         => clock,
      reset         => reset,
      enviar_config => enviar_config,
      enviar_jogada => enviar_jogada,
      fim_tx        => fim_tx,
      fimJ          => fimJ,
      zera          => zera,
      amostrar      => amostrar,
      configurar    => configurar,
      enviar        => enviar,
      contaJ        => contaJ,
      pronto        => pronto,
      db_estado     => db_estado
    );
end architecture structural;