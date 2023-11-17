
from MQTT import *
from Botao import *

class BotaoMQTT(Botao):

    def __init__(self, texto, x_pos, y_pos, topico, msgm, client):
        super.__init__(self, texto, x_pos, y_pos)
        self.msgm     = msgm
        self.topico   = topico
        self.client   = client

    def publicar_msgm(self):
        publicar(self.client, self.topico, self.msgm)
