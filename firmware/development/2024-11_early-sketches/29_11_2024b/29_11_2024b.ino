#define M1dirpin 7     // Pino de direção do motor 1
#define M1steppin 6    // Pino de passo do motor 1
#define M1en 8         // Pino de habilitação do motor 1
#define HallPin A13    // Pino de leitura analógica do sensor de efeito Hall

const unsigned long stepInterval = 1000; // Intervalo entre micropassos em microssegundos
unsigned long lastStepTime = 0;
int stepsCompleted = 0; // Contador de passos
int detectionStartStep = -1; // Passo onde começa o intervalo de detecção
int detectionEndStep = -1; // Passo onde termina o intervalo de detecção
bool detecting = false; // Indica se está no intervalo de detecção

void setup() {
  pinMode(M1dirpin, OUTPUT);
  pinMode(M1steppin, OUTPUT);
  pinMode(M1en, OUTPUT);
  pinMode(HallPin, INPUT); // Configura o pino analógico como entrada

  digitalWrite(M1en, LOW); // Habilita o motor
  digitalWrite(M1dirpin, LOW); // Define a direção inicial (sentido horário)

  Serial.begin(115200); // Inicializa a comunicação serial
  Serial.println(F("Arduino pronto para receber comandos..."));
}

void loop() {
  if (Serial.available() > 0) {
    String command = Serial.readStringUntil('\n');
    Serial.print(F("Comando recebido: "));
    Serial.println(command);

    if (command.equalsIgnoreCase(F("BUSCAR_ORIGEM"))) { // Uso de equalsIgnoreCase()
      Serial.println(F("Iniciando busca do ponto de origem..."));
      findPreciseOrigin();
      Serial.println(F("Busca do ponto de origem concluída."));
    } else {
      Serial.println(F("Comando inválido."));
    }
  }
}


void findPreciseOrigin() {
  stepsCompleted = 0;
  detectionStartStep = -1;
  detectionEndStep = -1;
  detecting = false;

  while (stepsCompleted < 3200) { // Limite para 360° de rotação
    unsigned long currentTime = micros();
    if (currentTime - lastStepTime >= stepInterval) {
      lastStepTime = currentTime;

      // Gera pulso para o motor
      digitalWrite(M1steppin, HIGH);
      delayMicroseconds(10); // Pulso curto
      digitalWrite(M1steppin, LOW);

      stepsCompleted++;

      // Lê o valor analógico do sensor
      int sensorValue = analogRead(HallPin);

      // Verifica se o valor está dentro do limiar de detecção
      if (sensorValue < 50 && !detecting) {
        detecting = true;
        detectionStartStep = stepsCompleted;
        Serial.print(F("Início da detecção no passo: "));
        Serial.println(detectionStartStep);
      } else if (sensorValue > 50 && detecting) {
        detecting = false;
        detectionEndStep = stepsCompleted;
        Serial.print(F("Fim da detecção no passo: "));
        Serial.println(detectionEndStep);
      }
    }
  }

  if (detectionStartStep != -1 && detectionEndStep != -1) {
    // Calcula o ponto central
    int centralStep = (detectionStartStep + detectionEndStep) / 2;
    Serial.print(F("Ponto central calculado no passo: "));
    Serial.println(centralStep);

    // Retorna ao ponto central
    int stepsToReturn = stepsCompleted - centralStep;
    digitalWrite(M1dirpin, HIGH); // Define a direção para retornar

    for (int i = 0; i < stepsToReturn; i++) {
      digitalWrite(M1steppin, HIGH);
      delayMicroseconds(10);
      digitalWrite(M1steppin, LOW);
      delayMicroseconds(stepInterval);
    }

    Serial.println(F("Ponto de origem preciso alcançado!"));
  } else {
    Serial.println(F("Falha ao detectar um intervalo válido."));
  }
}


