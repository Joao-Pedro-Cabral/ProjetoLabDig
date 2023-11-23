import random

from paho.mqtt import client as mqtt_client


class MQTT:

    def __init__(self):
        self.notas = -1
        self.estado = -1
        self.jogada = -1
        self.jogador = -1
        self.rodada = -1
        self.modo = -1
        self.dificuldade = -1
        self.configurado = 0

        # Conectando com o Broker
    def connect_mqtt(self, on_message, on_connect):
        broker = 'broker.emqx.io'
        port = 1883
        client_id = f'python-mqtt-{random.randint(0, 1000)}'
        username = 'emqx2'
        password = 'public'
        client = mqtt_client.Client(client_id)  # Cria objeto cliente
        client.username_pw_set(username, password)
        # Define função de call back do connect Broker
        client.on_connect = on_connect
        client.connect(broker, port)
        client.subscribe([("emqx2/NotaESP", 0), ("emqx2/JogadaESP", 0),
                         ("emqx2/RodadaESP", 0), ("emqx2/ConfiguracaoESP", 0)])  # Inscrição no MQTT
        # Definindo função de call back das mensagens subscritas
        client.on_message = on_message
        return client

    def publicar(client, topic, msg):
        result = client.publish(topic, msg)
        if result[0] == 0:
            print("Send " + msg + " to " + topic)
        else:
            print("Failed to send message to " + topic)

        # Call back das mensagens
    def analisar_msgm(self, msg):
        print("%s %s" % (msg.topic, msg.payload))
        if (msg.topic == "emqx2/NotaESP"):
            self.notas = int(str(msg.payload, "utf-8"))
            print(f"Nota recebida: {self.notas}")
        elif (msg.topic == "emqx2/JogadaESP"):
            dado = int(str(msg.payload, "utf-8"))
            print(f"Dado Jogada recebido: {dado}")
            self.estado = dado >> 4
            print(f"Estado recebido: {self.estado}")
            self.jogada = dado % 16
            print(f"Jogada recebida: {self.jogada}")
        elif (msg.topic == "emqx2/RodadaESP"):
            dado = int(str(msg.payload, "utf-8"))
            print(f"Dado Rodada recebido: {dado}")
            self.jogador = dado >> 4
            print(f"Jogador recebido: {self.jogador}")
            self.rodada = dado % 16
            print(f"Rodada recebida: {self.rodada}")
        elif (msg.topic == "emqx2/ConfiguracaoESP"):
            dado = int(str(msg.payload, "utf-8"))
            self.modo = dado >> 4
            print(f"Estado recebido: {self.modo}")
            self.dificuldade = dado % 16
            print(f"Dificuldade recebida: {self.dificuldade}")
            self.configurado = 1
        else:
            print("Tópico não existe!")

    def get_nota(self):
        notas2 = self.notas
        self.notas = -1
        return notas2

    def get_estado(self):
        estado2 = self.estado
        self.estado = -1
        return estado2

    def get_jogada(self):
        jogada2 = self.jogada
        self.jogada = -1
        return jogada2

    def get_jogador(self):
        jogador2 = self.jogador
        self.jogador = -1
        return jogador2

    def get_rodada(self):
        rodada2 = self.rodada
        self.rodada = -1
        return rodada2

    def get_modo(self):
        modo2 = self.modo
        self.modo = -1
        return modo2

    def get_dificuldade(self):
        dificuldade2 = self.dificuldade
        self.dificuldade = -1
        return dificuldade2

    def get_configurado(self):
        return self.configurado

    def clear_configurado(self):
        self.configurado = 0
