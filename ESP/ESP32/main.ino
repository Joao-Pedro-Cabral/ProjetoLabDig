
#include <PubSubClient.h>
#include <WiFi.h>

#define RXp2 16
#define TXp2 17

const char* ssid = "Delta 1 152";
const char* password = "pipoca55";
const char* mqtt_broker = "broker.emqx.io";
const int mqtt_port = 1883;

String user = "emqx2";
String passwd = "public";

WiFiClient espClient;
PubSubClient client(espClient);
unsigned long lastMsg = 0;
#define MSG_BUFFER_SIZE (50)
char msg[MSG_BUFFER_SIZE];
int value = 0;

int tempoMQTT = 1000;

void setup_wifi() {
  delay(10);
  // We start by connecting to a WiFi network
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}

void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");
  for (int i = 0; i < length; i++) {
    Serial.print((char)payload[i]);
  }
  Serial.println();

  if (strcmp(topic, (user + "/Configuracao").c_str()) == 0) {
    byte modo, dificuldade, config;
    modo = (payload[1] - 48) + 2 * (payload[0] - 48);
    Serial.println(modo);
    dificuldade = (payload[5] - 48) + 2 * (payload[4] - 48) +
                  4 * (payload[3] - 48) + 8 * (payload[2] - 48);
    Serial.println(dificuldade);
    config = 0xC0 + modo * 16 + dificuldade;
    Serial.println(config);
    Serial2.write(config);
  } else if (strcmp(topic, (user + "/Nota").c_str()) == 0) {
    byte nota, nota_tx;
    nota = (payload[3] - 48) + 2 * (payload[2] - 48) + 4 * (payload[1] - 48) +
           8 * (payload[0] - 48);
    Serial.println(nota);
    nota_tx = 0x40 + nota;
    Serial.println(nota_tx);
    Serial2.write(nota_tx);
  }
}

void connect_mqtt() {
  // MQTT
  client.setServer(mqtt_broker, mqtt_port);
  client.setCallback(callback);
  while (!client.connected()) {
    // Client Connection
    String client_id = "esp32-client-";
    client_id += String(WiFi.macAddress());
    Serial.printf("Client ID: %s\n", client_id.c_str());
    if (client.connect(client_id.c_str(), user.c_str(), passwd.c_str())) {
      Serial.println("Public emqx mqtt broker connected");
    }
    // Failed
    else {
      Serial.print("failed with state ");
      Serial.print(client.state());
      delay(tempoMQTT);
    }
  }
  // Inscrições
  client.subscribe((user + "/Configuracao").c_str());
  client.subscribe((user + "/Botoes").c_str());
  client.subscribe((user + "/Nota").c_str());
}

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  Serial2.begin(115200, SERIAL_8O1, RXp2, TXp2);
  // Wi-fi
  setup_wifi();
  connect_mqtt();
}

void loop() {
  client.loop();
  // Serial.println("Estou vivo!");
  client.publish((user + "/homehello").c_str(), "hello");
  if (Serial2.available()) {
    int byteRead = Serial2.read();  // Lê um byte da porta Serial2
    Serial.print("Byte lido: ");
    Serial.println(byteRead);
  }

  delay(tempoMQTT);
}
