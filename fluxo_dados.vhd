--------------------------------------------------------------------
-- Arquivo   : fluxo_dados.vhd
-- Projeto   : Experiencia 6 - Projeto do Jogo do Desafio da Memória
--------------------------------------------------------------------
-- Descricao : fluxo de dados para Exp. 6
--
--             
--
-- 
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor              Descricao
--     11/01/2022  1.0     Edson Midorikawa   versao inicial
--     07/01/2023  1.1     Edson Midorikawa   revisao
--     10/01/2023  1.1.1   Edson Midorikawa   arquivo parcial
--     14/01/2023  1.2     Pedro Hrosz Turini arquivo final
--     25/01/2023	 1.3 	   Pedro H. Turini		alteração de nome e adaptação para UC
--     01/02/2023  1.4     Pedro H. Turini		adição do Edge Detector
--     06/02/2023  1.5     João Pedro C.M.    versão desafio exp4
--     08/02/2023  1.6     João Pedro C.M.    exp5
--     08/02/2023  1.7     João Pedro C.M.    exp6
--     10/03/2023  1.8     Pedro H. Turini    implementação projeto (12 botões)
--------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity fluxo_dados is
    port (
          clock                    : in  std_logic;
          contaCR                  : in  std_logic;
          zeraCR                   : in  std_logic;
          contaE                   : in  std_logic;
          zeraE                    : in  std_logic;
          escreve                  : in  std_logic;
          ativar                   : in  std_logic;
          chaves                   : in  std_logic_vector(3 downto 0);
          registraRC               : in  std_logic;
          limpaRC                  : in  std_logic;
          registraModo             : in  std_logic;
          registraSel              : in  std_logic;
          ledSel                   : in  std_logic;
          escreve_aleatorio        : in  std_logic;
          zeraT                    : in  std_logic;
          contaT                   : in  std_logic;
          zeraI                    : in  std_logic;
          contaI                   : in  std_logic;
--Saidas
          db_rodada                : out std_logic_vector(3 downto 0);
          db_jogada                : out std_logic_vector(3 downto 0);
          enderecoIgualRodada      : out std_logic;
          leds                     : out std_logic_vector(3 downto 0);
          db_contagem              : out std_logic_vector(3 downto 0);
          db_memoria               : out std_logic_vector(3 downto 0);
          modo                     : out std_logic_vector(1 downto 0);
          jogada_correta           : out std_logic;
          jogada                   : out std_logic;
          fimL                     : out std_logic;
          fimE                     : out std_logic;
          fimT                     : out std_logic;
          fimI                     : out std_logic
    );
end entity;

architecture estrutural of fluxo_dados is

  signal s_rodada        : std_logic_vector(3 downto 0);
  signal seletor_rodada  : std_logic_vector(3 downto 0);
  signal seletor_modo    : std_logic_vector(1 downto 0);
  signal s_endereco      : std_logic_vector(3 downto 0);
  signal s_jogada        : std_logic_vector(3 downto 0);
  signal s_escrita       : std_logic_vector(3 downto 0);
  signal s_aleatorio     : std_logic_vector(3 downto 0);
  signal s_fimL          : std_logic_vector(15 downto 0);
  signal s_dado          : std_logic_vector(3 downto 0);
  signal s_dado_multi    : std_logic_vector(3 downto 0);
  signal s_dado_treino_2 : std_logic_vector(3 downto 0);
  signal s_dado_treino_1 : std_logic_vector(3 downto 0);
  signal s_dado_treino   : std_logic_vector(3 downto 0);
  signal s_not_zeraCR    : std_logic;
  signal s_not_zeraE     : std_logic;
  signal s_not_escreve   : std_logic;
  signal pulso_out       : std_logic;
  signal reset_ed        : std_logic;
  
  component contador_163
    port (
        clock : in  std_logic;
        clr   : in  std_logic;
        ld    : in  std_logic;
        ent   : in  std_logic;
        enp   : in  std_logic;
        D     : in  std_logic_vector (3 downto 0);
        Q     : out std_logic_vector (3 downto 0);
        rco   : out std_logic 
    );
  end component;

  component comparador
    generic(
      constant N : integer := 8
    );
    port (
      A       : in  std_logic_vector(N-1 downto 0);
      B       : in  std_logic_vector(N-1 downto 0);
      igual   : out std_logic
    );
  end component;

  component ram_16x4 is
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
  end component;
  
  component registrador_n is
    generic (
        constant N: integer := 12 
    );
    port (
        clock  : in  std_logic;
        clear  : in  std_logic;
        enable : in  std_logic;
        D      : in  std_logic_vector (N-1 downto 0);
        Q      : out std_logic_vector (N-1 downto 0) 
    );
end component registrador_n;

component edge_detector is
    port (
        clock  : in  std_logic;
        reset  : in  std_logic;
        sinal  : in  std_logic;
        pulso  : out std_logic
    );
end component edge_detector;

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
      meio    : out std_logic
  );
end component contador_m;

component mux16x1 is
    port(
        w : in std_logic_vector(15 downto 0);
        s : in std_logic_vector(3 downto 0);
        f : out std_logic
    );
end component mux16x1;

component LSFR_viciado is
  port(
      clock           : in  std_logic;
      reset           : in  std_logic;
      pseudo_random   : out std_logic_vector(3 downto 0) -- Número pseudo-aleatório
  );
end component;

begin

  -- sinais de controle ativos em alto
  -- sinais dos componentes ativos em baixo
  s_not_zeraCR   <= not zeraCR;
  s_not_zeraE    <= not zeraE;
  s_not_escreve  <= not escreve;
  
  contador_rodada: contador_163
    port map (
      clock => clock,
      clr   => s_not_zeraCR,  -- clr ativo em baixo
      ld    => '1',
      ent   => '1',
      enp   => contaCR,
      D     => "0000",
      Q     => s_rodada,
      rco   => open
    );

  contador_endereco: contador_163
    port map (
      clock => clock,
      clr   => s_not_zeraE,  -- clr ativo em baixo
      ld    => '1',
      ent   => '1',
      enp   => contaE,
      D     => "0000",
      Q     => s_endereco,
      rco   => fimE
    );

  comparador_jogada: comparador
    generic map(
      N => 4
    )
    port map (
      A     => s_dado,
      B     => s_jogada,
      igual => jogada_correta
    );

  comparador_endereco: comparador
    generic map(
      N => 4
    )
    port map (
      A     => s_rodada,
      B     => s_endereco,
      igual => enderecoIgualRodada
    );

  gerador_pseudo_aleatorio: LSFR_viciado
      port map(
          clock           => clock,
          reset           => limpaRC,
          pseudo_random   => s_aleatorio
      );
  
  --memoria: entity work.ram (ram_mif)  -- usar esta linha para Intel Quartus
  memoria_multijogador: entity work.ram (ram_multijogador) -- usar arquitetura para ModelSim
    -- generic map(
      -- init_file => "ram_treino_1.mif" -- Quartus -> Será totalmente sobrescrita durante a partida
    -- )
    port map (
       clk          => clock,
       endereco     => s_endereco,
       dado_entrada => s_escrita,
       we           => s_not_escreve, -- we ativo em baixo
       ce           => '0',
       dado_saida   => s_dado_multi
    );

  s_escrita <= s_aleatorio when (seletor_modo(0) or escreve_aleatorio) = '1' else s_jogada;

  --memoria_treino_1: entity work.ram (ram_mif)  -- usar esta linha para Intel Quartus
  memoria_treino_1: entity work.ram (ram_treino_1) -- usar arquitetura para ModelSim
    -- generic map(
      -- init_file => "ram_treino_1.mif" -- Quartus
    -- )
    port map (
       clk          => clock,
       endereco     => s_endereco,
       dado_entrada => "0000", -- ROM
       we           => '1',    -- ROM
       ce           => '0',
       dado_saida   => s_dado_treino_1
    );
  
  --memoria_treino_2: entity work.ram (ram_mif)  -- usar esta linha para Intel Quartus
  memoria_treino_2: entity work.ram (ram_treino_2) -- usar arquitetura para ModelSim
    -- generic map(
      -- init_file => "ram_treino_2.mif" -- Quartus
    -- )
    port map (
       clk          => clock,
       endereco     => s_endereco,
       dado_entrada => "0000", -- ROM
       we           => '1',    -- ROM
       ce           => '0',
       dado_saida   => s_dado_treino_2
    );

  -- Seleção da memória de treino
  s_dado_treino <= s_dado_treino_2 when seletor_modo(0) = '1' else s_dado_treino_1; 

  -- Seleção do s_dado
  s_dado <= s_dado_multi when seletor_modo(1) = '1' else s_dado_treino;
  
	registrador_jogada: registrador_n 
    generic map(
      N => 4
    )
    port map (
        clock => clock,
        clear => limpaRC,
        enable => registraRC,
        D =>  chaves,   
        Q => s_jogada    
    );
	 
	ed_detector : edge_detector 
    port map(
      clock => clock,
      reset => reset_ed,
      sinal => ativar,
      pulso => pulso_out
    );

  temporizador: contador_m
    generic map (
        M => 5000
    )
    port map (
      clock   => clock,
      zera_as => '0',
      zera_s  => zeraT,
      conta   => contaT,
      Q       => open,
      fim     => fimT,
      meio    => open
    );

  temporizador_inicial: contador_m
      generic map(
        M => 2000
      )
      port map(
        clock   => clock,
        zera_as => '0',
        zera_s  => zeraI,
        conta   => contaI,
        Q       => open,
        fim     => fimI,
        meio    => open
      );

  registrador_rodada: registrador_n
    generic map(
      N => 4
    )
    port map(
      clock  => clock,
      clear  => limpaRC,
      enable => registraSel,
      D      => chaves,
      Q      => seletor_rodada
    );

  registrador_modo: registrador_n
    generic map(
      N => 2
    )
    port map(
      clock  => clock,
      clear  => limpaRC,
      enable => registraModo,
      D      => chaves(1 downto 0),
      Q      => seletor_modo
    );
   
  multiplexador_rodada: mux16x1
    port map(
      w => s_fimL,
      s => seletor_rodada,
      f => fimL
    );

  -- Determinação dos possíveis fimL
  s_fimL(0)  <= s_rodada(0); -- Inatingível 
  s_fimL(1)  <= s_rodada(0);
  s_fimL(2)  <= s_rodada(1);
  s_fimL(3)  <= s_rodada(1) and s_rodada(0);
  s_fimL(4)  <= s_rodada(2);
  s_fimL(5)  <= s_rodada(2) and s_rodada(0);
  s_fimL(6)  <= s_rodada(2) and s_rodada(1);
  s_fimL(7)  <= s_rodada(2) and s_rodada(1) and s_rodada(0);
  s_fimL(8)  <= s_rodada(3);
  s_fimL(9)  <= s_rodada(3) and s_rodada(0);
  s_fimL(10) <= s_rodada(3) and s_rodada(1);
  s_fimL(11) <= s_rodada(3) and s_rodada(1) and s_rodada(0);
  s_fimL(12) <= s_rodada(3) and s_rodada(2);
  s_fimL(13) <= s_rodada(3) and s_rodada(2) and s_rodada(0);
  s_fimL(14) <= s_rodada(3) and s_rodada(2) and s_rodada(1);
  s_fimL(15) <= s_rodada(3) and s_rodada(2) and s_rodada(1) and s_rodada(0);
  
  reset_ed        <= limpaRC;
  db_rodada       <= s_rodada;
  db_jogada       <= s_jogada;
  db_contagem     <= s_endereco;
  db_memoria      <= s_dado;
  jogada          <= pulso_out;
  modo            <= seletor_modo;
  leds            <= s_dado when ledSel='1' else chaves;
  
end architecture estrutural;