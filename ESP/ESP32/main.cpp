
#include <WiFi.h>
#include <PubSubClient.h>

// Update these with values suitable for your network.

const char* ssid = "Turini's s10e";
const char* password = "morbius123";
const char* mqtt_broker = "broker.emqx.io";
const int mqtt_port = 1883;

String user = "emqx2";
String passwd = "public";

WiFiClient espClient;
PubSubClient client(espClient);
unsigned long lastMsg = 0;
#define MSG_BUFFER_SIZE	(50)
char msg[MSG_BUFFER_SIZE];
int value = 0;
 
// Sinais indo para a FPGA
#define reset 0
#define iniciar 2
#define ativar 1
#define botoes0 4
#define botoes1 5
#define botoes2 6
#define botoes3 7
// Sinais vindo do FPGA
#define perdeu 3
#define ganhou 18
#define jogador 19

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

void gera_botoes(char le_botoes0, char le_botoes1, char le_botoes2, char le_botoes3){
  if(le_botoes0 == '0') {
    digitalWrite(botoes0, LOW);
    Serial.println("Botoes0: 0");
  }
  else{
    digitalWrite(botoes0, HIGH);
    Serial.println("Botoes0: 1");
  }
  if(le_botoes1 == '0') {
    digitalWrite(botoes1, LOW);
    Serial.println("Botoes1: 0");
  }
  else{
    digitalWrite(botoes1, HIGH);
    Serial.println("Botoes1: 1");
  }
  if(le_botoes2 == '0') {
    digitalWrite(botoes2, LOW);
    Serial.println("Botoes2: 0");
  }
  else{
    digitalWrite(botoes2, HIGH);
    Serial.println("Botoes2: 1");
  }  
  if(le_botoes3 == '0') {
    digitalWrite(botoes3, LOW);
    Serial.println("Botoes3: 0");
  }
  else{
    digitalWrite(botoes3, HIGH);
    Serial.println("Botoes3: 1");
  }
}

void gera_reset(char le_reset){
  if(le_reset=='0'){
    digitalWrite(reset, LOW);
    Serial.println("Reset: 0");
  }
   else{
    digitalWrite(reset, HIGH);
    Serial.println("Reset: 1");
  }
}

void gera_iniciar(char le_iniciar){
  if(le_iniciar=='0'){
    digitalWrite(iniciar, LOW);
    Serial.println("Iniciar: 0");
  }
   else{
    digitalWrite(iniciar, HIGH);
    Serial.println("Iniciar: 1");
  }
}

void gera_ativar(char le_ativar){
  if(le_ativar=='0'){
    digitalWrite(ativar, LOW);
    Serial.println("Ativar: 0");
  }
   else{
    digitalWrite(ativar, HIGH);
    Serial.println("Ativar: 1");
  }
}
 
String gera_ganhou(int le_ganhou){
  if(le_ganhou == HIGH)
    return "1";
  else
    return "0";
}

String gera_jogador(int le_jogador){
  if(le_jogador == HIGH)
    return "1";
  else
    return "0";
}

String gera_perdeu(int le_perdeu){
  if(le_perdeu == HIGH)
    return "1";
  else
    return "0";
}


void callback(char* topic, byte* payload, unsigned int length) {
  // Serial.print("Message arrived [");
  // Serial.print(topic);
  // Serial.print("] ");
  // String payloadTemp;
  // for (int i = 0; i < length; i++){
  //   Serial.print((char) payload[i]);
  //   payloadTemp += (char)payload[i];
  // }
  // Serial.println();

  if(strcmp(topic, (user + "/Botoes").c_str()) == 0){
    gera_botoes((char) payload[3], (char) payload[2], (char) payload[1], (char) payload[0]); // MQTT é invertido
  }
  else if(strcmp(topic, (user + "/Iniciar").c_str()) == 0){
    gera_iniciar( (char) payload[0]);
  }
  else if(strcmp(topic, (user + "/Reset").c_str()) == 0){
    gera_reset( (char) payload[0]);
  }
  else if(strcmp(topic, (user + "/Ativar").c_str()) == 0){
    gera_ativar( (char) payload[0]);
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
        else{
          Serial.print("failed with state ");
          Serial.print(client.state());
          delay(tempoMQTT);
        }
    }
    // Publicações
    client.publish((user + "/Perdeu").c_str(), "0"); //Perdeu 
    client.publish((user + "/Ganhou").c_str(), "0"); //Ganhou
    client.publish((user + "/Jogador").c_str(), "0"); //Jogador
    // Inscrições
    client.subscribe((user + "/Botoes").c_str());
    client.subscribe((user + "/Ativar").c_str());
    client.subscribe((user + "/Iniciar").c_str());
    client.subscribe((user + "/Reset").c_str());
}

void setup() {
  // Entradas vindas da FPGA
  pinMode(perdeu,  INPUT);
  pinMode(ganhou,  INPUT);
  pinMode(jogador, INPUT);
  // Saídas indo para a FPGA
  pinMode(reset,   OUTPUT);
  pinMode(iniciar, OUTPUT);
  pinMode(ativar,  OUTPUT);
  pinMode(botoes0, OUTPUT);
  pinMode(botoes1, OUTPUT);
  pinMode(botoes2, OUTPUT);
  pinMode(botoes3, OUTPUT);
  // Serial
  Serial.begin(115200);
  // Wi-fi
  setup_wifi();
  connect_mqtt();
}

void loop() { //Loop de execucao

  client.loop();

  unsigned long now = millis();
  if (now - lastMsg > tempoMQTT) {
   lastMsg = now;
   //++value;
   //snprintf (msg, MSG_BUFFER_SIZE, "hello world #%ld", value);
   //Serial.println("Publicações executadas");
   //Serial.println(msg);
   client.publish((user + "/homehello").c_str(), "hello");
   //Serial.println(gera_perdeu(digitalRead(perdeu)).c_str());
   client.publish((user + "/Perdeu").c_str(), gera_perdeu(digitalRead(perdeu)).c_str()); //Perdeu 
   //Serial.println(gera_perdeu(digitalRead(ganhou)).c_str());
   client.publish((user + "/Ganhou").c_str(), gera_ganhou(digitalRead(ganhou)).c_str()); //Ganhou
  // Serial.println(gera_perdeu(digitalRead(jogador)).c_str());
   client.publish((user + "/Jogador").c_str(), gera_jogador(digitalRead(jogador)).c_str()); //Jogador
  }
}