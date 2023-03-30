import random
import time

from paho.mqtt import client as mqtt_client

perdeu  = "0"
ganhou  = "0"
jogador = "0"

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
    client.subscribe([("emqx2/Perdeu", 0), ("emqx2/Ganhou", 0), ("emqx2/Jogador", 0)]) # Inscrição no MQTT
    client.on_message = on_message #Definindo função de call back das mensagens subscritas
    return client

def publicar(client, topic, msg):
    publicar_msg(client, topic, msg)
    if(topic == "emqx2/Botoes"):
        if(msg != "0000"):
            time.sleep(0.02)
            publicar_msg(client, "emqx2/Ativar", "1")
        else:
            print("Ativar 0")
            publicar_msg(client, "emqx2/Ativar", "0")

def publicar_msg(client, topic, msg):
    result = client.publish(topic, msg)
    if result[0] == 0:
        print("Send " + msg + " to " + topic)
    else:
        print("Failed to send message to " + topic) 

# Call back das mensagens
def on_message(client, userdata, msg):
    # print("%s %s" % (msg.topic, msg.payload))
    # 3 tipos de mensagens permitidas armazenadas em variáveis globais
    if(msg.topic == "emqx2/Perdeu"):
        global perdeu
        perdeu = str(msg.payload, "utf-8")
        # print("Perdeu recebido")
        # print(perdeu)
    elif(msg.topic == "emqx2/Ganhou"):
        global ganhou
        ganhou = str(msg.payload, "utf-8")
        # print("Ganhou recebido!")
        # print(ganhou)
    elif(msg.topic == "emqx2/Jogador"):
        global jogador
        jogador = str(msg.payload, "utf-8")
        # print("Jogador recebido!")
        # print(jogador)
    else:
        print("Topic não existe!")

def ler_perdeu():
    return perdeu

def ler_ganhou():
    return ganhou

def ler_jogador():
    return jogador