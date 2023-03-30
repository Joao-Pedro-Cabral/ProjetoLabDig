
from MQTT import *
import pygame
from Botao import Botao
import time

def main():
    client = connect_mqtt()
    client.loop_start()
    inicializar(client)
    pygame.init()
    WIDTH = 600
    HEIGHT = 600
    font_padrao = pygame.font.Font("freesansbold.ttf", 18)
    font_titulo = pygame.font.Font("freesansbold.ttf", 35)
    fps = 60
    timer = pygame.time.Clock()
    pygame.display.set_caption("Genius Musical")
    while True:
        if(tela_inicio(font_padrao, font_titulo, fps, timer, client, 600, 600)):
            break
        if(tela_modo(font_padrao, font_titulo, fps, timer, client, WIDTH, HEIGHT)):
            break
        if(tela_dificuldade(font_padrao, font_titulo, fps, timer, client, WIDTH, HEIGHT)):
            break
        jogadores, terminar = tela_jogador(font_padrao, font_titulo, fps, timer, client, WIDTH, HEIGHT)
        if terminar:
            break
        if(tela_jogo(font_padrao, font_titulo, fps, timer, client, WIDTH, HEIGHT, jogadores)):
            break

    pygame.quit()

def inicializar(client):
    publicar(client, "emqx2/Iniciar", "0")
    publicar(client, "emqx2/Botoes", "0000")
    publicar(client, "emqx2/Reset", "1")
    time.sleep(1)
    publicar(client, "emqx2/Reset", "0")

def tela_inicio(font_padrao, font_titulo, fps, timer, client, WIDTH, HEIGHT):
    screen = pygame.display.set_mode([WIDTH, HEIGHT])
    screen.fill("white")
    titulo = font_titulo.render("Genius Musical", True, "black", (250, 250, 250))
    run = True
    terminar = False
    new_press = True
    apertado = False
    botao = Botao("Iniciar", 225, 285, "emqx2/Iniciar", "1", "0", client)
    screen.fill("white")
    botao.desenhar(font_padrao, screen)

    while run:
        screen.blit(titulo, (170, 100))
        timer.tick(fps)

        if pygame.mouse.get_pressed()[0] and new_press:
            new_press = False
            if botao.check_click():
                botao.publicar_apertado()
                apertado = True
        elif not pygame.mouse.get_pressed()[0] and not new_press:
            if apertado:
                botao.publicar_solto()
                run = False
            new_press = True
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                run = False
                terminar = True
        
        pygame.display.flip()
    return terminar

def tela_modo(font_padrao, font_titulo, fps, timer, client, WIDTH, HEIGHT):
    screen = pygame.display.set_mode([WIDTH, HEIGHT])
    screen.fill("white")
    run = True
    new_press = True
    apertado = False
    terminar = False
    botao_Treino1   = Botao("Treino 1", 100, 225, "emqx2/Ativar", "1", "0", client)
    botao_Treino2   = Botao("Treino 2", 350, 225, "emqx2/Botoes", "0001", "0000", client)
    botao_Multi     = Botao("Multijogador", 100, 275, "emqx2/Botoes", "0010", "0000", client)
    botao_Aleatorio = Botao("Aleatório", 350, 275, "emqx2/Botoes", "0011", "0000", client)
    screen.fill("white")
    titulo = font_titulo.render("Escolha o Modo de Jogo", True, "black", (250, 250, 250))
    botao_Treino1.desenhar(font_padrao, screen)
    botao_Treino2.desenhar(font_padrao, screen)
    botao_Multi.desenhar(font_padrao, screen)
    botao_Aleatorio.desenhar(font_padrao, screen)

    while run:
        screen.blit(titulo, (100, 100))
        timer.tick(fps)

        if pygame.mouse.get_pressed()[0] and new_press:
            new_press = False
            apertado  = True
            if botao_Treino1.check_click():
                botao_Treino1.publicar_apertado()
            elif botao_Treino2.check_click():
                botao_Treino2.publicar_apertado()
            elif botao_Multi.check_click():
                botao_Multi.publicar_apertado()
            elif botao_Aleatorio.check_click():
                botao_Aleatorio.publicar_apertado()
            else:
                apertado = False
        elif not pygame.mouse.get_pressed()[0] and not new_press:
            # Esse botao limpa o envio de todos
            if apertado:
                botao_Treino2.publicar_solto()
                run = False
            new_press = True
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                run = False
                terminar = True
        
        pygame.display.flip()

    return terminar

def tela_dificuldade(font_padrao, font_titulo, fps, timer, client, WIDTH, HEIGHT):
    screen = pygame.display.set_mode([WIDTH, HEIGHT])
    screen.fill("white")
    titulo = font_titulo.render("Escolha o número de rodadas", True, "black", (250, 250, 250))
    run = True
    new_press = True
    terminar  = False
    botao2    = Botao("2",  25,  200, "emqx2/Botoes", "0001", "0000", client)
    botao3    = Botao("3",  225, 200, "emqx2/Botoes", "0010", "0000", client)
    botao4    = Botao("4",  425, 200, "emqx2/Botoes", "0011", "0000", client)
    botao5    = Botao("5",  25,  250, "emqx2/Botoes", "0100", "0000", client)
    botao6    = Botao("6",  225, 250, "emqx2/Botoes", "0101", "0000", client)
    botao7    = Botao("7",  425, 250, "emqx2/Botoes", "0110", "0000", client)
    botao8    = Botao("8",  25,  300, "emqx2/Botoes", "0111", "0000", client)
    botao9    = Botao("9",  225, 300, "emqx2/Botoes", "1000", "0000", client)
    botao10   = Botao("10", 425, 300, "emqx2/Botoes", "1001", "0000", client)
    botao11   = Botao("11", 25,  350, "emqx2/Botoes", "1010", "0000", client)
    botao12   = Botao("12", 225, 350, "emqx2/Botoes", "1011", "0000", client)
    botao13   = Botao("13", 425, 350, "emqx2/Botoes", "1100", "0000", client)
    botao14   = Botao("14", 25,  400, "emqx2/Botoes", "1101", "0000", client)
    botao15   = Botao("15", 225, 400, "emqx2/Botoes", "1110", "0000", client)
    botao16   = Botao("16", 425, 400, "emqx2/Botoes", "1111", "0000", client)
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

    while run:
        screen.blit(titulo, (50, 100))
        timer.tick(fps)

        if pygame.mouse.get_pressed()[0] and new_press:
            new_press = False
            apertado = True
            if botao2.check_click():
                botao2.publicar_apertado()
            elif botao3.check_click():
                botao3.publicar_apertado()
            elif botao4.check_click():
                botao4.publicar_apertado()
            elif botao5.check_click():
                botao5.publicar_apertado()
            elif botao6.check_click():
                botao6.publicar_apertado()
            elif botao7.check_click():
                botao7.publicar_apertado()
            elif botao8.check_click():
                botao8.publicar_apertado()
            elif botao9.check_click():
                botao9.publicar_apertado()
            elif botao10.check_click():
                botao10.publicar_apertado()
            elif botao11.check_click():
                botao11.publicar_apertado()
            elif botao12.check_click():
                botao12.publicar_apertado()
            elif botao13.check_click():
                botao13.publicar_apertado()
            elif botao14.check_click():
                botao14.publicar_apertado()
            elif botao15.check_click():
                botao15.publicar_apertado()
            elif botao16.check_click():
                botao16.publicar_apertado()
            else:
                apertado = False
        elif not pygame.mouse.get_pressed()[0] and not new_press:
            # Esse botao limpa o envio de todos
            if apertado:
                botao2.publicar_solto()
                run = False
            new_press = True
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                run = False
                terminar = True
        
        pygame.display.flip()

    return terminar

def tela_jogador(font_padrao, font_titulo, fps, timer, client, WIDTH, HEIGHT):
    screen = pygame.display.set_mode([WIDTH, HEIGHT])
    screen.fill("white")
    run = True
    new_press = True
    apertado  = False
    terminar  = False
    jogadores = False
    botao1   = Botao("1 Jogador", 125, 225, "emqx2/Ativar", "0", "0", client)
    botao2   = Botao("2 Jogadores", 325, 225, "emqx2/Ativar", "0", "0", client)
    screen.fill("white")
    titulo = font_titulo.render("Escolha o número de jogadores", True, "black", (250, 250, 250))
    botao1.desenhar(font_padrao, screen)
    botao2.desenhar(font_padrao, screen)

    while run:
        screen.blit(titulo, (35, 100))
        timer.tick(fps)

        if pygame.mouse.get_pressed()[0] and new_press:
            new_press = False
            apertado  = True
            if botao1.check_click():
                jogadores = False
            elif botao2.check_click():
                jogadores = True
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
        
        pygame.display.flip()

    return jogadores, terminar

def tela_jogo(font_padrao, font_titulo, fps, timer, client, WIDTH, HEIGHT, jogadores):
    screen = pygame.display.set_mode([WIDTH, HEIGHT])
    screen.fill("white")
    titulo = font_titulo.render("Toque a música", True, "black", (250, 250, 250))
    run = True
    new_press = True
    terminar  = False
    reiniciar = False
    fim       = False
    botao2    = Botao("C5",  25,  200, "emqx2/Botoes", "0001", "0000", client)
    botao3    = Botao("D5",  225, 200, "emqx2/Botoes", "0010", "0000", client)
    botao4    = Botao("E5",  425, 200, "emqx2/Botoes", "0011", "0000", client)
    botao5    = Botao("F5",  25,  250, "emqx2/Botoes", "0100", "0000", client)
    botao6    = Botao("G5",  225, 250, "emqx2/Botoes", "0101", "0000", client)
    botao7    = Botao("A5",  425, 250, "emqx2/Botoes", "0110", "0000", client)
    botao8    = Botao("B5",  25,  300, "emqx2/Botoes", "0111", "0000", client)
    botao9    = Botao("C6",  225, 300, "emqx2/Botoes", "1000", "0000", client)
    botao10   = Botao("D6",  425, 300, "emqx2/Botoes", "1001", "0000", client)
    botao11   = Botao("E6",  25,  350, "emqx2/Botoes", "1010", "0000", client)
    botao12   = Botao("F6",  225, 350, "emqx2/Botoes", "1011", "0000", client)
    botao13   = Botao("G6",  425, 350, "emqx2/Botoes", "1100", "0000", client)
    botaoReiniciar  = Botao("Reiniciar", 400, 570, "emqx2/Iniciar", "1", "0", client)
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

    while run:
        screen.blit(titulo, (200, 50))
        timer.tick(fps)

        if pygame.mouse.get_pressed()[0] and new_press:
            new_press = False
            apertado = True
            if botao2.check_click():
                botao2.publicar_apertado()
            elif botao3.check_click():
                botao3.publicar_apertado()
            elif botao4.check_click():
                botao4.publicar_apertado()
            elif botao5.check_click():
                botao5.publicar_apertado()
            elif botao6.check_click():
                botao6.publicar_apertado()
            elif botao7.check_click():
                botao7.publicar_apertado()
            elif botao8.check_click():
                botao8.publicar_apertado()
            elif botao9.check_click():
                botao9.publicar_apertado()
            elif botao10.check_click():
                botao10.publicar_apertado()
            elif botao11.check_click():
                botao11.publicar_apertado()
            elif botao12.check_click():
                botao12.publicar_apertado()
            elif botao13.check_click():
                botao13.publicar_apertado()
            elif botaoReiniciar.check_click() and reiniciar:
                botaoReiniciar.publicar_apertado()
                fim = True
            else:
                apertado = False
        elif not pygame.mouse.get_pressed()[0] and not new_press:
            # Esse botao limpa o envio de todos
            if apertado:
                botao2.publicar_solto()
            if(fim and reiniciar):
                botaoReiniciar.publicar_solto()
                run = False
            new_press = True
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                run = False
                terminar = True

        if(ler_jogador() == "1"):
            jogador = "2"
        else:
            jogador = "1"

        if jogadores:
            screen.blit(font_titulo.render("Jogador " + jogador, True, "black", (250, 250, 250)), (230, 100))

        if(ler_ganhou() == "1" or ler_perdeu() == "1"):
            if(ler_ganhou() == "1"):
                screen.blit(font_titulo.render("Ganhou!", True, "black", (250, 250, 250)), (250, 150))
            if(ler_perdeu() == "1"):
                screen.blit(font_titulo.render("Perdeu!", True, "black", (250, 250, 250)), (250, 150))
            reiniciar = True
            botaoReiniciar.desenhar(font_padrao, screen)
        
        pygame.display.update()

    return terminar

main()