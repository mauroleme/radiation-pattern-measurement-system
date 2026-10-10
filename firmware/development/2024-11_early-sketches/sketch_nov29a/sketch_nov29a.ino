#define M1dirpin 7     // Pino de direção do motor 1 (X - Azimute)
#define M1steppin 6    // Pino de passo do motor 1 (X - Azimute)
#define M1en 8         // Pino de habilitação do motor 1 (X - Azimute)
#define HallPin A13    // Pino de leitura analógica do sensor de efeito Hall

const unsigned long stepInterval = 1000; // Intervalo entre micropassos em microssegundos
unsigned long lastStepTime = 0;

// Variáveis de controle
int stepsCompleted = 0;        // Contador de passos
int detectionStartStep = -1;   // Passo onde começa o intervalo de detecção
int detectionEndStep = -1;     // Passo onde termina o intervalo de detecção
bool detecting = false;        // Indica se o sensor está no intervalo de detecção
bool searchingOrigin = true;

void setup() {
  pinMode(M1dirpin, OUTPUT);
  pinMode(M1steppin, OUTPUT);
  pinMode(M1en, OUTPUT);
  pinMode(HallPin, INPUT); // Configura o pino analógico como entrada para o sensor de efeito Hall

  digitalWrite(M1en, LOW); // Habilita o motor
  digitalWrite(M1dirpin, LOW); // Define a direção inicial (sentido horário)

  Serial.begin(115200);    // Inicializa a comunicação serial
  Serial.println("Iniciando busca precisa do ponto de origem...");
}

void loop() {
  if (searchingOrigin) {
    findPreciseOrigin(); // Executa a lógica para encontrar o ponto de origem
  }
}

void findPreciseOrigin() {
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
      // Início do intervalo de detecção
      detecting = true;
      detectionStartStep = stepsCompleted;
      Serial.print("Início da detecção no passo: ");
      Serial.println(detectionStartStep);
    } else if (sensorValue > 50 && detecting) {
      // Fim do intervalo de detecção
      detecting = false;
      detectionEndStep = stepsCompleted;
      Serial.print("Fim da detecção no passo: ");
      Serial.println(detectionEndStep);
    }

    // Limite para o movimento: 360° (3200 micropassos no total para 1 revolução com 1/16 microstepping)
    if (stepsCompleted >= 3200) {
      Serial.println("Busca concluída. Calculando ponto central...");

      // Calcula o ponto central do intervalo de valores mínimos
      if (detectionStartStep != -1 && detectionEndStep != -1) {
        int centralStep = (detectionStartStep + detectionEndStep) / 2;
        Serial.print("Ponto central calculado no passo: ");
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

        Serial.println("Ponto de origem preciso alcançado!");
      } else {
        Serial.println("Falha ao detectar um intervalo válido.");
      }

      searchingOrigin = false; // Finaliza a busca
    }
  }
}

