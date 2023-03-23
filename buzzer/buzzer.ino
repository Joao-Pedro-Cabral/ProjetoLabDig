
// Pinos de Entrada
#define nota0 D0
#define nota1 D5
#define nota2 D6
#define nota3 D7
// Pino do Buzzer
# define pinBuzzer D1   
int nota  = 0; // Entrada Computada
int notaAnterior = 0; // Entrada Anterior
int tempoNota = 1000; // 2s por nota 

void setup()
{
  // Saídas LEDs da FPGA
  pinMode(nota0, INPUT);
  pinMode(nota1, INPUT);
  pinMode(nota2, INPUT);
  pinMode(nota3, INPUT);
  // Entrada do Buzzer Passivo -> Regular a frequência
  pinMode(pinBuzzer, OUTPUT);
}

void loop() {
  
  // Computa a nota a partir dos 4 bits de entrada
  nota = digitalRead(nota0) + 2*digitalRead(nota1) + 4*digitalRead(nota2) + 8*digitalRead(nota3);
  
  // se for uma nota nova devemos tocá-la
  if(nota != notaAnterior){
    // Escolher a nota musical (Escala Diatônica C-Major) -> Uma oitava acima(*2)
    switch(nota){
    	case 1:  tone(pinBuzzer, 784*2, tempoNota); //G5
      			 delay(tempoNota);
      			 break;
        case 2:  tone(pinBuzzer, 699*2, tempoNota); //F5
      			 delay(tempoNota);
      			 break;
        case 3:  tone(pinBuzzer, 659*2, tempoNota); //E5
      			 delay(tempoNota);
      		     break;
        case 4:  tone(pinBuzzer, 587*2, tempoNota); //D5
      			 delay(tempoNota);
      			 break;
      	case 5:  tone(pinBuzzer, 523*2, tempoNota); //C5
      		     delay(tempoNota);
      			 break;
       	case 6:  tone(pinBuzzer,494*2 , tempoNota); //B4
      		     delay(tempoNota);
      		     break;
       	case 7:  tone(pinBuzzer, 440*2, tempoNota); //A4
      			 delay(tempoNota);
      			 break;
        case 8:  tone(pinBuzzer, 392*2, tempoNota); //G4
       			 delay(tempoNota);
      			 break;
       	case 9:  tone(pinBuzzer, 349*2, tempoNota); //F4
      			 delay(tempoNota);
      		     break;
       	case 10: tone(pinBuzzer, 330*2, tempoNota); //E4
      			 delay(tempoNota);
      			 break;
        case 11: tone(pinBuzzer, 293*2, tempoNota); //D4
      			 delay(tempoNota);
      			 break;
       	case 12: tone(pinBuzzer, 262*2, tempoNota); //C4
      			 delay(tempoNota);
      			 break;
        // Entrada inválida ou 0 -> Não há nota
    }
  }
  notaAnterior = nota;
}
