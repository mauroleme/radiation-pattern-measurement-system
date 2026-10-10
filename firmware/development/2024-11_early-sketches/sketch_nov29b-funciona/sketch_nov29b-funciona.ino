#define M1dirpin 7
#define M1steppin 6
#define M1en 8

const int stepsPerDegree = 16; // Micropassos por grau
unsigned long stepInterval = 800;

void setup() {
  pinMode(M1dirpin, OUTPUT);
  pinMode(M1steppin, OUTPUT);
  pinMode(M1en, OUTPUT);

  digitalWrite(M1en, LOW); // Habilita o motor
  Serial.begin(115200);
  delay(100); // Pequeno atraso para inicialização
  Serial.println("Arduino inicializado e aguardando comandos...");
}

void loop() {
  if (Serial.available() > 0) {
    String command = Serial.readStringUntil('\n');

    if (command.startsWith("GIRAR")) {
      int angle = command.substring(6).toInt();
      Serial.print("Recebido comando para girar ");
      Serial.print(angle);
      Serial.println(" graus.");

      moveMotor(angle);

      Serial.println("Movimento concluído.");
    } else {
      Serial.println("Comando inválido.");
    }
  }
}

void moveMotor(int angle) {
  int stepsToMove = abs(angle) * stepsPerDegree;
  digitalWrite(M1dirpin, angle > 0 ? HIGH : LOW);

  for (int i = 0; i < stepsToMove; i++) {
    digitalWrite(M1steppin, HIGH);
    delayMicroseconds(10);
    digitalWrite(M1steppin, LOW);
    delayMicroseconds(stepInterval);
  }
}


