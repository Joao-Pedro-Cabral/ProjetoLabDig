
#include <PubSubClient.h>
#include <WiFi.h>

#define RXp2 16
#define TXp2 17
#define TXp0 1
#define RXp0 3
#define pinBuzzer 23
int tempoNota = 800;  // 800ms por nota

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

int tempoMQTT = 100;

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

  if (strcmp(topic, (user + "/ConfiguracaoTwin").c_str()) == 0) {
    byte modo, dificuldade, config;
    modo = (payload[1] - 48) + 2 * (payload[0] - 48);
    Serial.println(modo);
    dificuldade = (payload[5] - 48) + 2 * (payload[4] - 48) +
                  4 * (payload[3] - 48) + 8 * (payload[2] - 48);
    Serial.println(dificuldade);
    config = 0xC0 + modo * 16 + dificuldade;
    Serial.println(config);
    Serial2.write(config);
    Serial2.read();
  } else if (strcmp(topic, (user + "/NotaTwin").c_str()) == 0) {
    byte nota, nota_tx;
    nota = (payload[3] - 48) + 2 * (payload[2] - 48) + 4 * (payload[1] - 48) +
           8 * (payload[0] - 48);
    Serial.println(nota);
    nota_tx = nota;
    Serial.println(nota_tx);
    Serial2.write(nota_tx);
    Serial2.read();
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
  // Publicações
  client.publish((user + "/NotaESP").c_str(), "0");
  client.publish((user + "/RodadaESP").c_str(), "0");
  client.publish((user + "/JogadaESP").c_str(), "0");
  client.publish((user + "/ConfiguracaoESP").c_str(), "0");
  // Inscrições
  client.subscribe((user + "/ConfiguracaoTwin").c_str());
  client.subscribe((user + "/NotaTwin").c_str());
}

void play_buzzer(int nota) {
  // Escolher a nota musical (Escala Diatônica C-Major) -> Uma oitava acima(*2)
  Serial.print("Nota: ");
  Serial.println(nota);
  switch (nota) {
    case 1:
      tone(pinBuzzer, 784 * 2, tempoNota);  // G5
      delay(tempoNota);
      break;
    case 2:
      tone(pinBuzzer, 699 * 2, tempoNota);  // F5
      delay(tempoNota);
      break;
    case 3:
      tone(pinBuzzer, 659 * 2, tempoNota);  // E5
      delay(tempoNota);
      break;
    case 4:
      tone(pinBuzzer, 587 * 2, tempoNota);  // D5
      delay(tempoNota);
      break;
    case 5:
      tone(pinBuzzer, 523 * 2, tempoNota);  // C5
      delay(tempoNota);
      break;
    case 6:
      tone(pinBuzzer, 494 * 2, tempoNota);  // B4
      delay(tempoNota);
      break;
    case 7:
      tone(pinBuzzer, 440 * 2, tempoNota);  // A4
      delay(tempoNota);
      break;
    case 8:
      tone(pinBuzzer, 392 * 2, tempoNota);  // G4
      delay(tempoNota);
      break;
    case 9:
      tone(pinBuzzer, 349 * 2, tempoNota);  // F4
      delay(tempoNota);
      break;
    case 10:
      tone(pinBuzzer, 330 * 2, tempoNota);  // E4
      delay(tempoNota);
      break;
    case 11:
      tone(pinBuzzer, 293 * 2, tempoNota);  // D4
      delay(tempoNota);
      break;
    case 12:
      tone(pinBuzzer, 262 * 2, tempoNota);  // C4
      delay(tempoNota);
      break;
      // Entrada inválida ou 0 -> Não há nota
  }
}

void send_mqtt_data() {
  int byteRead = Serial2.read();  // Lê um byte da porta Serial2
  int index = byteRead >> 6;
  int dado = byteRead - (index << 6);
  char msgm[3];
  Serial.print("Byte lido: ");
  Serial.println(byteRead);
  Serial.print("Index: ");
  Serial.println(index);
  Serial.print("Dado: ");
  Serial.println(dado);
  sprintf(msgm, "%d", dado);
  Serial.print("Texto convertido: ");
  Serial.println(msgm);
  if (index == 0) {
    client.publish((user + "/NotaESP").c_str(), msgm);
    play_buzzer(dado);
  } else if (index == 1)
    client.publish((user + "/JogadaESP").c_str(), msgm);
  else if (index == 2)
    client.publish((user + "/RodadaESP").c_str(), msgm);
  else if (index == 3)
    client.publish((user + "/ConfiguracaoESP").c_str(), msgm);
}

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  // Serial1.begin(115200, SERIAL_8O1, RXp0, TXp0);
  Serial2.begin(115200, SERIAL_8O1, RXp2, TXp2);
  // Wi-fi
  setup_wifi();
  connect_mqtt();
  // Entrada do Buzzer Passivo -> Regular a frequência
  pinMode(pinBuzzer, OUTPUT);
}

void loop() {
  client.loop();
  // Serial.println("Estou vivo!");
  client.publish((user + "/homehello").c_str(), "hello");
  if (Serial2.available()) send_mqtt_data();

  delay(tempoMQTT);
}
