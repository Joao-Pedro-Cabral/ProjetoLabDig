import random

from paho.mqtt import client as mqtt_client

notas = "0"
estado = "0"
jogada = "0"
jogador = "0"
rodada = "0"
modo = "0"
dificuldade = "0"
configurado = 0

# CallBack da conexão com o Broker
def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("Connected to MQTT Broker!")
    else:
        print("Failed to connect, return code %d\n", rc)
    
#Conectando com o Broker
def connect_mqtt():
    broker = 'broker.emqx.io'
    port = 1883
    client_id = f'python-mqtt-{random.randint(0, 1000)}'
    username = 'emqx2'
    password = 'public'
    client = mqtt_client.Client(client_id) # Cria objeto cliente
    client.username_pw_set(username, password)
    client.on_connect = on_connect #Define função de call back do connect Broker
    client.connect(broker, port)
    client.subscribe([("emqx2/NotaESP", 0), ("emqx2/JogadaESP", 0), ("emqx2/RodadaESP", 0), ("emqx2/ConfiguracaoESP", 0)]) # Inscrição no MQTT
    client.on_message = on_message #Definindo função de call back das mensagens subscritas
    return client

def publicar(client, topic, msg):
    result = client.publish(topic, msg)
    if result[0] == 0:
        print("Send " + msg + " to " + topic)
    else:
        print("Failed to send message to " + topic) 

# Call back das mensagens
def on_message(client, userdata, msg):
    print("%s %s" % (msg.topic, msg.payload))
    # 3 tipos de mensagens permitidas armazenadas em variáveis globais
    if(msg.topic == "emqx2/NotaESP"):
        global notas
        notas = str(msg.payload, "utf-8")
        print(f"Nota recebida: {notas}")
    elif(msg.topic == "emqx2/JogadaESP"):
        global estado
        global jogada
        dado = int(str(msg.payload, "utf-8"))
        print(f"Dado Jogada recebido: {dado}")
        estado = str(dado >> 4)
        print(f"Estado recebido: {estado}")
        jogada = str(dado % 16)
        print(f"Jogada recebida: {jogada}")
    elif(msg.topic == "emqx2/RodadaESP"):
        global jogador
        dado = int(str(msg.payload, "utf-8"))
        print(f"Dado Rodada recebido: {dado}")
        jogador = str(dado >> 4)
        print(f"Jogador recebido: {jogador}")
        global rodada
        rodada = str(dado % 16)
        print(f"Rodada recebida: {rodada}")
    elif(msg.topic == "emqx2/ConfiguracaoESP"):
        global modo
        global dificuldade
        dado = int(str(msg.payload, "utf-8"))
        modo = str(dado >> 4)
        print(f"Estado recebido: {modo}")
        dificuldade = str(dado % 16)
        print(f"Dificuldade recebida: {dificuldade}")
        global configurado
        configurado = 1
    else:
        print("Tópico não existe!")

def ler_notas():
    return notas

def ler_estado():
    return estado

def ler_jogada():
    return jogada

def ler_jogador():
    return jogador

def ler_rodada():
    return rodada

def ler_modo():
    return modo

def ler_dificuldade():
    return dificuldade
  
def ler_configurado():
    return configurado
  
def limpar_configurado():
    global configurado
    configurado = 0
