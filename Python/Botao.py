
import pygame


class Botao:

    def __init__(self, texto, x_pos, y_pos, width, height):
        self.texto = texto
        self.x_pos = x_pos
        self.y_pos = y_pos
        self.width = width
        self.height = height

    def desenhar(self, font, screen):
        botao_texto = font.render(self.texto, True, "black")
        botao_retan = pygame.rect.Rect(
            (self.x_pos, self.y_pos), (self.width, self.height))
        pygame.draw.rect(screen, "gray", botao_retan, 0, 5)
        pygame.draw.rect(screen, "black", botao_retan, 2, 5)
        screen.blit(botao_texto, (self.x_pos + 8, self.y_pos + 5))

    def desenhar_apertado(self, font, screen):
        botao_texto = font.render(self.texto, True, "black")
        botao_retan = pygame.rect.Rect(
            (self.x_pos, self.y_pos), (self.width, self.height))
        pygame.draw.rect(screen, "blue", botao_retan, 0, 5)
        pygame.draw.rect(screen, "black", botao_retan, 2, 5)
        screen.blit(botao_texto, (self.x_pos + 8, self.y_pos + 5))

    def check_click(self):
        mouse_pos = pygame.mouse.get_pos()
        left_click = pygame.mouse.get_pressed()[0]
        botao_retan = pygame.rect.Rect(
            (self.x_pos, self.y_pos), (self.width, self.height))
        if left_click and botao_retan.collidepoint(mouse_pos):
            return True
        else:
            return False
