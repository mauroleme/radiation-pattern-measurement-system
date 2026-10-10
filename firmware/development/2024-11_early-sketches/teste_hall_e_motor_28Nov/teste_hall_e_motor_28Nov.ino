#include "A4988.h"

#define MOTOR_STEPS 200  // Passos por revolução do motor NEMA 17
#define DIR  8           // Pino de direção
#define STEP 9           // Pino de passo
#define MS1  10          // Pino de microstepping
#define MS2  11          // Pino de microstepping
#define MS3  12          // Pino de microstepping

A4988 stepper(MOTOR_STEPS, DIR, STEP, MS1, MS2, MS3);

// Sensor de efeito Hall
#define HallPin A13
int currentPosition = 0;         // Posição absoluta em graus
const int detectionThreshold = 100; // Limiar para detectar o ímã

void setup() {
  stepper.begin(16, 120); // Configura microstepping para 1/16 e 120 RPM
  Serial.begin(115200);   // Comunicação serial com MATLAB
  Serial.setTimeout(1000); // Timeout de 1 segundo
  pinMode(HallPin, INPUT); // Configura o sensor de efeito Hall

  Serial.println("Sistema inicializado e aguardando comandos.");
}

void loop() {
  // Verifica se há dados recebidos do MATLAB
  if (Serial.available() > 0) {
    char command = Serial.read(); // Lê um caractere
    Serial.print("Comando recebido: ");
    Serial.println(command);

    switch (command) {
      case '1': // Encontrar origem
        findOrigin();
        break;
      case '2': // Rotacionar 180° no sentido horário
        rotateToAngle(180);
        break;
      case '3': // Rotacionar 180° no sentido anti-horário
        rotateToAngle(-180);
        break;
      default:
        Serial.println("Comando inválido.");
        break;
    }
  }
}

void findOrigin() {
  Serial.println("Procurando origem...");
  while (true) {
    stepper.move(1); // Move 1 micropasso no sentido horário
    int sensorValue = analogRead(HallPin);

    if (sensorValue < detectionThreshold) { // Detecta o ímã
      Serial.println("Origem encontrada!");
      currentPosition = 0; // Define a posição atual como origem
      break;
    }
  }
}

void rotateToAngle(int angle) {
  int stepsToMove = angle * 16; // Cada grau corresponde a 16 micropassos
  Serial.print("Movendo ");
  Serial.print(stepsToMove);
  Serial.println(" passos.");

  stepper.move(stepsToMove); // Executa o movimento
  currentPosition += angle; // Atualiza a posição atual
  Serial.print("Nova posição: ");
  Serial.println(currentPosition);
}
