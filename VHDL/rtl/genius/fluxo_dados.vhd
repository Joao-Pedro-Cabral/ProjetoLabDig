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
          ativar                   : in  std_logic;
          chaves                   : in  std_logic_vector(5 downto 0);
          echo                     : in  std_logic;
          rx                       : in  std_logic;
          zeraCR                   : in  std_logic;
          zeraI                    : in  std_logic;
          zeraE                    : in  std_logic;
          zeraT                    : in  std_logic;
          limpa                    : in  std_logic;
          contaCR                  : in  std_logic;
          contaI                   : in  std_logic;
          contaE                   : in  std_logic;
          contaT                   : in  std_logic;
          medir_nota               : in  std_logic;
          enviar_config            : in  std_logic;
          enviar_jogada            : in  std_logic;
          escreve                  : in  std_logic;
          escreve_aleatorio        : in  std_logic;
          registraRC               : in  std_logic;
          registraConfig           : in  std_logic;
          notaSel                  : in  std_logic;
          ganhou                   : in  std_logic;
          perdeu                   : in  std_logic;
          perdeuT                  : in  std_logic;
--Saidas
          iniciar                  : out std_logic;
          trigger                  : out std_logic;
          pwm                      : out std_logic;
          pwm2                     : out std_logic;
          tx                       : out std_logic;
          notas                    : out std_logic_vector(3 downto 0);
          modo                     : out std_logic_vector(1 downto 0);
          enderecoIgualRodada      : out std_logic;
          jogada_correta           : out std_logic;
          jogada                   : out std_logic;
          configurado              : out std_logic;
          jogador                  : out std_logic;
          fimL                     : out std_logic;
          fimE                     : out std_logic;
          fimT                     : out std_logic;
          fimI                     : out std_logic;
          db_rodada                : out std_logic_vector(3 downto 0);
          db_jogada                : out std_logic_vector(3 downto 0);
          db_contagem              : out std_logic_vector(3 downto 0);
          db_memoria               : out std_logic_vector(3 downto 0);
          db_sensor                : out std_logic_vector(3 downto 0);
          db_medida                : out std_logic_vector(11 downto 0);
          db_dado_tx               : out std_logic;
          db_dado_rx               : out std_logic
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
  signal s_not_ativar    : std_logic;
  signal s_medida_nota, medida_nota : std_logic_vector(3 downto 0);
  signal pronto_sensor   : std_logic;
  signal posicao_servo, posicao_servo2, estado: std_logic_vector(1 downto 0);
  signal venceu1, venceu2 : std_logic;
  signal s_perdeu, configurado_ed, configurado_rx, jogada_rx, configurado_rx2, jogada_rx2: std_logic;
  signal s_config, configuracao_rx  : std_logic_vector(5 downto 0);
  signal s_notas,notas_rx : std_logic_vector(3 downto 0);

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
      meio    : out std_logic;
      quarto  : out std_logic
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

  component interface_hcsr04 is
    port (
      clock     : in std_logic;
      reset     : in std_logic;
      medir     : in std_logic;
      echo      : in std_logic;
      trigger   : out std_logic;
      notas     : out std_logic_vector(3 downto 0);
      pronto    : out std_logic;
      db_medida : out std_logic_vector(11 downto 0);
      db_reset  : out std_logic;
      db_medir  : out std_logic;
      db_estado : out std_logic_vector(3 downto 0)
    );
  end component interface_hcsr04;

  component controle_servo is
    port (
      clock : in std_logic;
      reset : in std_logic;
      posicao : in std_logic_vector(1 downto 0);
      controle : out std_logic
    );
  end component controle_servo;

  component rx_musical is
    port (
      clock         : in  std_logic;
      reset         : in  std_logic;
      rx            : in  std_logic;
      iniciar       : out std_logic;
      configurado   : out std_logic;
      configuracao  : out std_logic_vector(5 downto 0);
      jogada        : out std_logic;
      notas         : out std_logic_vector(3 downto 0);
      db_dado_rx    : out std_logic;
      db_estado     : out std_logic_vector(3 downto 0)
    );
  end component rx_musical;

  component tx_musical is
    port (
      clock         : in  std_logic;
      reset         : in  std_logic;
      enviar_config : in  std_logic;
      enviar_jogada : in  std_logic;
      modo          : in  std_logic_vector(1 downto 0);
      dificuldade   : in  std_logic_vector(3 downto 0);
      estado        : in  std_logic_vector(1 downto 0);
      notas         : in  std_logic_vector(3 downto 0);
      jogador       : in  std_logic;
      jogada        : in  std_logic_vector(3 downto 0);
      rodada        : in  std_logic_vector(3 downto 0);
      tx            : out std_logic;
      pronto        : out std_logic;
      db_dado_tx    : out std_logic;
      db_estado     : out std_logic_vector(3 downto 0)
    );
  end component tx_musical;

begin

  -- sinais de controle ativos em alto
  -- sinais dos componentes ativos em baixo
  s_not_zeraCR   <= not zeraCR;
  s_not_zeraE    <= not zeraE;
  s_not_escreve  <= not escreve;
  s_not_ativar   <= not ativar;

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
          reset           => limpa,
          pseudo_random   => s_aleatorio
      );
  
  -- memoria: entity work.ram (ram_mif)  -- usar esta linha para Intel Quartus
  memoria_multijogador: entity work.ram (ram_multijogador) -- usar arquitetura para ModelSim
    -- generic map(
    --   init_file => "ram_treino_1.mif" -- Quartus -> Sobrescrito durante o jogo
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

  -- memoria_treino_1: entity work.ram (ram_mif)  -- usar esta linha para Intel Quartus
  memoria_treino_1: entity work.ram (ram_treino_1) -- usar arquitetura para ModelSim
    -- generic map(
    --   init_file => "ram_treino_1.mif" -- Quartus
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
    --   init_file => "ram_treino_2.mif" -- Quartus
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
        clock  => clock,
        clear  => limpa,
        enable => registraRC,
        D      => s_medida_nota,
        Q      => s_jogada
    );

  interface_sensor: interface_hcsr04
    port map (
      clock      => clock,
      reset      => limpa,
      medir      => medir_nota,
      echo       => echo,
      trigger    => trigger,
      notas      => medida_nota,
      pronto     => pronto_sensor,
      db_medida  => db_medida,
      db_reset   => open,
      db_medir   => open,
      db_estado  => db_sensor
    );

  ed_detector : edge_detector
    port map(
      clock => clock,
      reset => limpa,
      sinal => ativar,
      pulso => configurado_ed
    );

  temporizador: contador_m
    generic map (
      M => 750000 -- simulacao
      --M => 500000000 -- quartus
    )
    port map (
      clock   => clock,
      zera_as => '0',
      zera_s  => zeraT,
      conta   => contaT,
      Q       => open,
      fim     => fimT,
      meio    => open,
      quarto  => open
    );

  temporizador_inicial: contador_m
      generic map(
        M => 25000 -- simulacao
        -- M => 50000000 --quartus
      )
      port map(
        clock   => clock,
        zera_as => '0',
        zera_s  => zeraI,
        conta   => contaI,
        Q       => open,
        fim     => fimI,
        meio    => open,
        quarto  => open
      );

  registrador_rodada: registrador_n
    generic map(
      N => 4
    )
    port map(
      clock  => clock,
      clear  => limpa,
      enable => registraConfig,
      D      => s_config(3 downto 0),
      Q      => seletor_rodada
    );

  registrador_modo: registrador_n
    generic map(
      N => 2
    )
    port map(
      clock  => clock,
      clear  => limpa,
      enable => registraConfig,
      D      => s_config(5 downto 4),
      Q      => seletor_modo
    );
   
  multiplexador_rodada: mux16x1
    port map(
      w => s_fimL,
      s => seletor_rodada,
      f => fimL
    );

  pwm_servo: controle_servo
    port map (
      clock    => clock,
      reset    => limpa,
      posicao  => posicao_servo,
      controle => pwm
    );

  pwm_servo2: controle_servo
    port map (
      clock    => clock,
      reset    => limpa,
      posicao  => posicao_servo2,
      controle => pwm2
    );

  receptor: rx_musical
    port map (
      clock         => clock,
      reset         => limpa,
      rx            => rx,
      iniciar       => iniciar,
      configurado   => configurado_rx,
      configuracao  => configuracao_rx,
      jogada        => jogada_rx,
      notas         => notas_rx,
      db_dado_rx    => db_dado_rx,
      db_estado     => open
    );

  transmissor: tx_musical
    port map (
      clock         => clock,
      reset         => limpa,
      enviar_config => enviar_config,
      enviar_jogada => enviar_jogada,
      modo          => seletor_modo,
      dificuldade   => seletor_rodada,
      estado        => estado,
      notas         => s_notas,
      jogador       => s_rodada(0),
      jogada        => s_endereco,
      rodada        => s_rodada,
      tx            => tx,
      pronto        => open,
      db_dado_tx    => db_dado_tx,
      db_estado     => open
    );

  -- Determinação da posição do servo
  s_perdeu <= perdeu or perdeuT;
  venceu1 <= (((not seletor_modo(1)) or seletor_modo(0)) and ganhou) or
             ((seletor_modo(1) and (not seletor_modo(0))) and ((ganhou and (not s_rodada(0))) or (s_perdeu and s_rodada(0))));
  posicao_servo <= "10" when venceu1 = '1' else
                   "01";

  venceu2 <= (((not seletor_modo(1)) or seletor_modo(0)) and s_perdeu) or
             ((seletor_modo(1) and (not seletor_modo(0))) and ((ganhou and s_rodada(0)) or (s_perdeu and (not s_rodada(0)))));
  posicao_servo2 <= "10" when venceu2 = '1' else
                    "01";


  -- Bufferizo os sinais do receptor para usar no ciclo seguinte
  process(clock, limpa) begin
    if (clock'event and clock='1') then
      if (limpa = '1') then
        configurado_rx2 <= '0';
        jogada_rx2      <= '0';
      else
        configurado_rx2 <= configurado_rx;
        jogada_rx2      <= jogada_rx;
      end if;
    end if;
  end process;

  -- Muxes para escolha entre físico/Digital Twin
  s_config      <= configuracao_rx when configurado_rx2 = '1' else chaves;
  s_medida_nota <= notas_rx when jogada_rx2 = '1' else medida_nota;

  -- Decisão do estado atual
  estado <= "11" when perdeuT = '1' else
            "10" when perdeu  = '1' else
            "01" when ganhou  = '1' else
            "00";

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

  -- saidas
  -- ESP
  s_notas         <= s_dado when notaSel='1' else s_jogada;
  notas           <= s_notas;
  -- UC
  configurado     <= configurado_ed or configurado_rx;
  jogador         <= s_rodada(0);
  jogada          <= pronto_sensor or jogada_rx;
  modo            <= seletor_modo;
  -- debug
  db_rodada       <= s_rodada;
  db_jogada       <= s_jogada;
  db_contagem     <= s_endereco;
  db_memoria      <= s_dado;

end architecture estrutural;