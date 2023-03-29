
from MQTT import *
import pygame

class Botoes:

    def __init__(self, texto, x_pos, y_pos, topico, apertado, solto, client):
        self.texto    = texto
        self.x_pos    = x_pos
        self.y_pos    = y_pos
        self.apertado = apertado
        self.solto    = solto
        self.topico   = topico
        self.client   = client
        self.desenhar()

    def desenhar(self, font, screen):
        botao_texto = font
        botao_retan = pygame.rect.Rect((self.x_pos, self.y_pos), (150, 25))
        pygame.draw.rect(screen, "gray", botao_retan, 0, 5)
        pygame.draw.rect(screen, "black", botao_retan, 2, 5)
        screen.blit(botao_texto, (self.x_pos + 3, self.y_pos + 3))

    def check_click(self):
        mouse_pos   = pygame.mouse.get_pos()
        left_click  = pygame.mouse.get_pressed()[0]
        botao_retan = pygame.rect.Rect((self.x_pos, self.y_pos), (150, 25))
        if left_click and botao_retan.collidepoint(mouse_pos):
            return True
        else:
            return False
    