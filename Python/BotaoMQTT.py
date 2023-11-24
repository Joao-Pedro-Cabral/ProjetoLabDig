
from MQTT import *
from Botao import *


class BotaoMQTT(Botao):

    def __init__(self, texto, x_pos, y_pos, width, height, topico, msgm, client):
        super().__init__(texto, x_pos, y_pos, width, height)
        self.msgm = msgm
        self.topico = topico
        self.client = client

    def publicar_msgm(self):
        MQTT.publicar(self.client, self.topico, self.msgm)
