import random

from paho.mqtt import client as mqtt_client


class MQTT:

    def __init__(self):
        self.notas = -1
        self.estado = 0
        self.jogada = 0
        self.jogador = 0
        self.rodada = 0
        self.modo = 0
        self.dificuldade = 0
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

    def perdeu(self):
        return (self.estado == 2 or self.estado == 3)

    def perdeu_timeout(self):
        return (self.estado == 3)

    def ganhou(self):
        return (self.estado == 1)

    def get_jogada(self):
        return self.jogada

    def get_jogador(self):
        return self.jogador

    def get_rodada(self):
        return self.rodada

    def get_modo(self):
        return self.modo

    def get_dificuldade(self):
        return self.dificuldade

    def get_configurado(self):
        return self.configurado

    def clear_configurado(self):
        self.configurado = 0

    def clear_all(self):
        self.notas = -1
        self.estado = 0
        self.jogada = 0
        self.jogador = 0
        self.rodada = 0
        self.modo = 0
        self.dificuldade = 0
        self.configurado = 0

    def clear_except_config(self):
        self.notas = -1
        self.estado = 0
        self.jogada = 0
        self.jogador = 0
        self.rodada = 0
        self.configurado = 0
