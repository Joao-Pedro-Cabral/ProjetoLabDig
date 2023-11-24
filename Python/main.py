
from MQTT import *
import pygame
from Botao import Botao
from BotaoMQTT import BotaoMQTT

text_background = (250, 250, 250)


def main():
    client = MyMQTT.connect_mqtt(on_message, on_connect)
    client.loop_start()
    pygame.init()
    WIDTH = 600
    HEIGHT = 600
    font_padrao = pygame.font.Font("freesansbold.ttf", 18)
    font_titulo = pygame.font.Font("freesansbold.ttf", 35)
    fps = 60
    configurado = False
    timer = pygame.time.Clock()
    pygame.display.set_caption("Magic Piano")
    while True:
        if not configurado:
            configurado, terminar = tela_inicio(
                font_padrao, font_titulo, fps, timer, 600, 600)
        if terminar:
            break
        if not configurado:
            modo, configurado, terminar = tela_modo(
                font_padrao, font_titulo, fps, timer, WIDTH, HEIGHT)
        if terminar:
            break
        if not configurado:
            dificuldade, configurado, terminar = tela_dificuldade(
                font_padrao, font_titulo, fps, timer, WIDTH, HEIGHT)
        if terminar:
            break
        if not configurado:
            MQTT.publicar(
                client, "emqx2/ConfiguracaoTwin", modo + dificuldade)
        MyMQTT.clear_configurado()
        configurado, terminar = tela_jogo(
            font_padrao, font_titulo, fps, timer, client, WIDTH, HEIGHT)
        if terminar:
            break
        if configurado:
            MyMQTT.clear_except_config()
        else:
            MyMQTT.clear_all()

    pygame.quit()


def on_message(client, userdata, msg):
    MyMQTT.analisar_msgm(msg)


def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("Connected to MQTT Broker!")
    else:
        print("Failed to connect, return code %d\n", rc)


def tela_inicio(font_padrao, font_titulo, fps, timer, WIDTH, HEIGHT):
    screen = pygame.display.set_mode([WIDTH, HEIGHT])
    screen.fill("white")
    titulo = font_titulo.render(
        "Magic Piano", True, "black", text_background)
    run = True
    terminar = False
    new_press = True
    apertado = False
    configurado = False
    botao = Botao("Iniciar", 225, 285, 150, 25)
    screen.fill("white")
    botao.desenhar(font_padrao, screen)

    while run and (not configurado):
        screen.blit(titulo, (210, 100))
        timer.tick(fps)

        if pygame.mouse.get_pressed()[0] and new_press:
            new_press = False
            if botao.check_click():
                apertado = True
        elif not pygame.mouse.get_pressed()[0] and not new_press:
            if apertado:
                run = False
            new_press = True
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                run = False
                terminar = True
        configurado = MyMQTT.get_configurado()
        pygame.display.flip()

    return configurado, terminar


def tela_modo(font_padrao, font_titulo, fps, timer, WIDTH, HEIGHT):
    screen = pygame.display.set_mode([WIDTH, HEIGHT])
    screen.fill("white")
    run = True
    new_press = True
    apertado = False
    terminar = False
    configurado = False
    modo = "00"
    botao_Treino1 = Botao("Treino 1", 100, 235, 150, 25)
    botao_Treino2 = Botao("Treino 2", 350, 235, 150, 25)
    botao_Multi = Botao("PvP", 100, 275, 150, 25)
    botao_Aleatorio = Botao("Aleatório", 350, 275, 150, 25)
    screen.fill("white")
    titulo = font_titulo.render(
        "Escolha o Modo de Jogo", True, "black", text_background)
    botao_Treino1.desenhar(font_padrao, screen)
    botao_Treino2.desenhar(font_padrao, screen)
    botao_Multi.desenhar(font_padrao, screen)
    botao_Aleatorio.desenhar(font_padrao, screen)

    while run and (not configurado):
        screen.blit(titulo, (100, 100))
        timer.tick(fps)

        if pygame.mouse.get_pressed()[0] and new_press:
            new_press = False
            apertado = True
            if botao_Treino1.check_click():
                modo = "00"
            elif botao_Treino2.check_click():
                modo = "01"
            elif botao_Multi.check_click():
                modo = "10"
            elif botao_Aleatorio.check_click():
                modo = "11"
            else:
                apertado = False
        elif not pygame.mouse.get_pressed()[0] and not new_press:
            if apertado:
                run = False
            new_press = True
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                run = False
                terminar = True

        configurado = MyMQTT.get_configurado()
        pygame.display.flip()

    return modo, configurado, terminar


def tela_dificuldade(font_padrao, font_titulo, fps, timer, WIDTH, HEIGHT):
    screen = pygame.display.set_mode([WIDTH, HEIGHT])
    screen.fill("white")
    titulo = font_titulo.render(
        "Escolha o número de rodadas", True, "black", text_background)
    run = True
    new_press = True
    terminar = False
    configurado = False
    dificuldade = "0000"
    botao2 = Botao("2",  25,  200, 150, 25)
    botao3 = Botao("3",  225, 200, 150, 25)
    botao4 = Botao("4",  425, 200, 150, 25)
    botao5 = Botao("5",  25,  250, 150, 25)
    botao6 = Botao("6",  225, 250, 150, 25)
    botao7 = Botao("7",  425, 250, 150, 25)
    botao8 = Botao("8",  25,  300, 150, 25)
    botao9 = Botao("9",  225, 300, 150, 25)
    botao10 = Botao("10", 425, 300, 150, 25)
    botao11 = Botao("11", 25,  350, 150, 25)
    botao12 = Botao("12", 225, 350, 150, 25)
    botao13 = Botao("13", 425, 350, 150, 25)
    botao14 = Botao("14", 25,  400, 150, 25)
    botao15 = Botao("15", 225, 400, 150, 25)
    botao16 = Botao("16", 425, 400, 150, 25)
    screen.fill("white")
    botao2.desenhar(font_padrao, screen)
    botao3.desenhar(font_padrao, screen)
    botao4.desenhar(font_padrao, screen)
    botao5.desenhar(font_padrao, screen)
    botao6.desenhar(font_padrao, screen)
    botao7.desenhar(font_padrao, screen)
    botao8.desenhar(font_padrao, screen)
    botao9.desenhar(font_padrao, screen)
    botao10.desenhar(font_padrao, screen)
    botao11.desenhar(font_padrao, screen)
    botao12.desenhar(font_padrao, screen)
    botao13.desenhar(font_padrao, screen)
    botao14.desenhar(font_padrao, screen)
    botao15.desenhar(font_padrao, screen)
    botao16.desenhar(font_padrao, screen)

    while run and (not configurado):
        screen.blit(titulo, (50, 100))
        timer.tick(fps)

        if pygame.mouse.get_pressed()[0] and new_press:
            new_press = False
            apertado = True
            if botao2.check_click():
                dificuldade = "0001"
            elif botao3.check_click():
                dificuldade = "0010"
            elif botao4.check_click():
                dificuldade = "0011"
            elif botao5.check_click():
                dificuldade = "0100"
            elif botao6.check_click():
                dificuldade = "0101"
            elif botao7.check_click():
                dificuldade = "0110"
            elif botao8.check_click():
                dificuldade = "0111"
            elif botao9.check_click():
                dificuldade = "1000"
            elif botao10.check_click():
                dificuldade = "1001"
            elif botao11.check_click():
                dificuldade = "1010"
            elif botao12.check_click():
                dificuldade = "1011"
            elif botao13.check_click():
                dificuldade = "1100"
            elif botao14.check_click():
                dificuldade = "1101"
            elif botao15.check_click():
                dificuldade = "1110"
            elif botao16.check_click():
                dificuldade = "1111"
            else:
                apertado = False
        elif not pygame.mouse.get_pressed()[0] and not new_press:
            # Esse botao limpa o envio de todos
            if apertado:
                run = False
            new_press = True
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                run = False
                terminar = True

        configurado = MyMQTT.get_configurado()
        pygame.display.flip()

    return dificuldade, configurado, terminar


def tela_jogo(font_padrao, font_titulo, fps, timer, client, WIDTH, HEIGHT):
    screen = pygame.display.set_mode([WIDTH, HEIGHT])
    screen.fill("white")
    titulo = font_titulo.render(
        "Toque a música", True, "black", text_background)
    run = True
    new_press = True
    terminar = False
    reiniciar = False
    fim = False
    configurado = False
    botao2 = BotaoMQTT("C5",  60,  300, 40, 150,
                       "emqx2/NotaTwin", "1100", client)
    botao3 = BotaoMQTT("D5",  100, 300, 40, 150,
                       "emqx2/NotaTwin", "1011", client)
    botao4 = BotaoMQTT("E5",  140, 300, 40, 150,
                       "emqx2/NotaTwin", "1010", client)
    botao5 = BotaoMQTT("F5",  180,  300, 40, 150,
                       "emqx2/NotaTwin", "1001", client)
    botao6 = BotaoMQTT("G5",  220, 300, 40, 150,
                       "emqx2/NotaTwin", "1000", client)
    botao7 = BotaoMQTT("A5",  260, 300, 40, 150,
                       "emqx2/NotaTwin", "0111", client)
    botao8 = BotaoMQTT("B5",  300,  300, 40, 150,
                       "emqx2/NotaTwin", "0110", client)
    botao9 = BotaoMQTT("C6",  340, 300, 40, 150,
                       "emqx2/NotaTwin", "0101", client)
    botao10 = BotaoMQTT("D6", 380, 300, 40, 150,
                        "emqx2/NotaTwin", "0100", client)
    botao11 = BotaoMQTT("E6", 420,  300, 40, 150,
                        "emqx2/NotaTwin", "0011", client)
    botao12 = BotaoMQTT("F6", 460, 300, 40, 150,
                        "emqx2/NotaTwin", "0010", client)
    botao13 = BotaoMQTT("G6", 500, 300, 40, 150,
                        "emqx2/NotaTwin", "0001", client)
    botaoReiniciar = Botao("Reiniciar", 400, 570, 150, 25)
    screen.fill("white")
    botao2.desenhar(font_padrao, screen)
    botao3.desenhar(font_padrao, screen)
    botao4.desenhar(font_padrao, screen)
    botao5.desenhar(font_padrao, screen)
    botao6.desenhar(font_padrao, screen)
    botao7.desenhar(font_padrao, screen)
    botao8.desenhar(font_padrao, screen)
    botao9.desenhar(font_padrao, screen)
    botao10.desenhar(font_padrao, screen)
    botao11.desenhar(font_padrao, screen)
    botao12.desenhar(font_padrao, screen)
    botao13.desenhar(font_padrao, screen)
    botoes = {}
    botoes[12] = botao2
    botoes[11] = botao3
    botoes[10] = botao4
    botoes[9] = botao5
    botoes[8] = botao6
    botoes[7] = botao7
    botoes[6] = botao8
    botoes[5] = botao9
    botoes[4] = botao10
    botoes[3] = botao11
    botoes[2] = botao12
    botoes[1] = botao13
    contador = -1
    notaAnterior = -1
    # Use asyncio.run para executar o loop de eventos assíncronos
    while run and (not configurado):
        screen.blit(titulo, (180, 30))
        timer.tick(fps)

        if pygame.mouse.get_pressed()[0] and new_press:
            new_press = False
            if botao2.check_click():
                botao2.publicar_msgm()
            elif botao3.check_click():
                botao3.publicar_msgm()
            elif botao4.check_click():
                botao4.publicar_msgm()
            elif botao5.check_click():
                botao5.publicar_msgm()
            elif botao6.check_click():
                botao6.publicar_msgm()
            elif botao7.check_click():
                botao7.publicar_msgm()
            elif botao8.check_click():
                botao8.publicar_msgm()
            elif botao9.check_click():
                botao9.publicar_msgm()
            elif botao10.check_click():
                botao10.publicar_msgm()
            elif botao11.check_click():
                botao11.publicar_msgm()
            elif botao12.check_click():
                botao12.publicar_msgm()
            elif botao13.check_click():
                botao13.publicar_msgm()
            elif botaoReiniciar.check_click() and reiniciar:
                fim = True
        elif not pygame.mouse.get_pressed()[0] and not new_press:
            if (fim and reiniciar):
                run = False
            new_press = True
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                run = False
                terminar = True

        jogada = MyMQTT.get_jogada()
        rodada = MyMQTT.get_rodada()
        jogadores = (MyMQTT.get_modo() == 2)
        jogador = MyMQTT.get_jogador()

        screen.blit(font_titulo.render("Jogada " + str(jogada),
                    True, "black", text_background), (50, 100))
        screen.blit(font_titulo.render("Rodada " + str(rodada),
                    True, "black", text_background), (380, 100))

        end_label_height = 170
        if jogadores:
            end_label_height = 220
            screen.blit(font_titulo.render("Jogador " + str(jogador),
                        True, "black", text_background), (230, 150))

        if (MyMQTT.ganhou() or MyMQTT.perdeu()):
            if (MyMQTT.ganhou()):
                screen.blit(font_titulo.render("Ganhou!", True,
                            "black", text_background), (240, end_label_height))
            elif (MyMQTT.perdeu_timeout()):
                screen.blit(font_titulo.render("Timeout!", True,
                            "black", text_background), (235, end_label_height))
            else:
                screen.blit(font_titulo.render("Perdeu!", True,
                            "black", text_background), (240, end_label_height))
            reiniciar = True
            botaoReiniciar.desenhar(font_padrao, screen)

        nota = MyMQTT.get_nota()
        if nota != -1:
            contador = 0
            notaAnterior = nota
            botoes[nota].desenhar_apertado(font_padrao, screen)

        if contador >= 0:
            contador = contador + 1

        if contador > 45:
            botoes[notaAnterior].desenhar(font_padrao, screen)
            notaAnterior = -1
            contador = -1

        pygame.display.update()
        configurado = MyMQTT.get_configurado()

    return configurado, terminar


MyMQTT = MQTT()
main()
