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


          chaves                   : in  std_logic_vector(11 downto 0);
          registraRC               : in  std_logic;
          limpaRC                  : in  std_logic;
          registraSel              : in  std_logic;

          zeraT                    : in  std_logic;
          contaT                   : in  std_logic;
          contaI                   : in  std_logic;
          
--Saidas
          db_rodada                : out std_logic_vector(3 downto 0);
          enderecoIgualRodada      : out std_logic;
          db_contagem              : out std_logic_vector(3 downto 0);
          db_memoria               : out std_logic_vector(11 downto 0);
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
  signal s_endereco      : std_logic_vector(3 downto 0);
  signal s_jogada        : std_logic_vector(11 downto 0);
  signal s_fimL          : std_logic_vector(15 downto 0);
  signal s_rodada        : std_logic_vector(3 downto 0);
  signal s_dado          : std_logic_vector(11 downto 0);
  signal s_not_zeraCR    : std_logic;
  signal s_not_zeraE     : std_logic;
  signal s_not_escreve   : std_logic;
  signal pulso_out       : std_logic;
  signal s_chaveacionada : std_logic;
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
      size: natural := 12
    );
     port (       
         clk          : in  std_logic;
         endereco     : in  std_logic_vector(3 downto 0);
         dado_entrada : in  std_logic_vector(size-1 downto 0);
         we           : in  std_logic;
         ce           : in  std_logic;
         dado_saida   : out std_logic_vector(size-1 downto 0)
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
end mux16x1;

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
    generic(
      N => 12
    )
    port map (
      A     => s_dado,
      B     => s_jogada,
      igual => jogada_correta
    );

  comparador_endereco: comparador
    generic(
      N => 4
    )
    port map (
      A     => s_rodada,
      B     => s_endereco,
      igual => enderecoIgualRodada
    );

  --memoria: entity work.ram (ram_mif)  -- usar esta linha para Intel Quartus
  memoria: entity work.ram (ram_modelsim) -- usar arquitetura para ModelSim
    generic(
      size => 12
    )
    port map (
       clk          => clock,
       endereco     => s_endereco,
       dado_entrada => s_jogada,
       we           => s_not_escreve, -- we ativo em baixo
       ce           => '0',
       dado_saida   => s_dado
    );
	
	registrador: registrador_n 
    generic map(
      N => 12
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
      sinal => s_chaveacionada,
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
        zera_s  => limpaRC,
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
      D      => chaves(3 downto 0),
      Q      => seletor_rodada,
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
  s_chaveacionada <= chaves(0) or chaves(1) or chaves(2) or chaves(3) or chaves(4) or chaves(5) or chaves (6) or chaves(7) or chaves(8) or chaves(9) or chaves(10) or chaves(11);
  db_rodada       <= s_rodada;
  db_contagem     <= s_endereco;
  db_memoria      <= s_dado;
  jogada          <= pulso_out;
  
end architecture estrutural;