#define HallPin A13    // Pino analógico do sensor de efeito Hall
#define M1dirpin 7     // Pino de direção do motor
#define M1steppin 6    // Pino de passo do motor
#define M1en 8         // Pino de habilitação do motor
#define rfPin A15      // Pino analógico conectado ao módulo RF

const int passosPorGrau = 9; // Número de micro-passos por grau
const int numAmostras = 10;  // 10 amostras por grau

void setup() {
  pinMode(M1dirpin, OUTPUT);
  pinMode(M1steppin, OUTPUT);
  pinMode(M1en, OUTPUT);
  pinMode(HallPin, INPUT);
  pinMode(rfPin, INPUT);

  digitalWrite(M1en, LOW);     // Habilita o motor
  digitalWrite(M1dirpin, LOW); // Direção inicial

  Serial.begin(115200);        // Comunicação serial
  Serial.println("Arduino pronto para receber comandos...");
}

void loop() {
  if (Serial.available() > 0) {
    char comando = Serial.read();
    if (comando == '0') { // Comando para iniciar a medição
      buscarOrigem();            // Localiza o ponto de origem
      realizar_medicoes_360();   // Realiza medições para os 360°
    }
  }
}

void buscarOrigem() {
  Serial.println("Iniciando busca do ponto de origem...");
  int stepsCompleted = 0;
  int detectionStartStep = -1;
  int detectionEndStep = -1;
  bool detecting = false;
  const int limiar = 50;       // Limiar de detecção do sensor
  const int maxSteps = 3200;   // Máximo de passos para uma rotação completa (360°)

  while (stepsCompleted < maxSteps) {
    int sensorValue = analogRead(HallPin);

    if (sensorValue < limiar && !detecting) {
      detecting = true;
      detectionStartStep = stepsCompleted;
    } else if (sensorValue >= limiar && detecting) {
      detecting = false;
      detectionEndStep = stepsCompleted;
      break;
    }

    // Passo do motor
    digitalWrite(M1steppin, HIGH);
    delayMicroseconds(10);
    digitalWrite(M1steppin, LOW);
    delayMicroseconds(1000);
    stepsCompleted++;
  }

  if (detectionStartStep != -1 && detectionEndStep != -1) {
    int centralStep = (detectionStartStep + detectionEndStep) / 2;

    // Retorna ao ponto central
    int stepsToReturn = stepsCompleted - centralStep;
    digitalWrite(M1dirpin, HIGH);
    for (int i = 0; i < stepsToReturn; i++) {
      digitalWrite(M1steppin, HIGH);
      delayMicroseconds(10);
      digitalWrite(M1steppin, LOW);
      delayMicroseconds(1000);
    }

    Serial.println("Ponto de origem encontrado!");
  } else {
    Serial.println("Falha ao encontrar o ponto de origem.");
  }
}

void realizar_medicoes_360() {
  const int numGraus = 180; // 180 graus por lado
  int matriz[360][10];      // Matriz para armazenar os resultados

  Serial.println("Iniciando medições de 0° a 180°...");
  realizar_medicoes(0, numGraus, matriz, LOW);

  Serial.println("Retornando ao ponto de origem...");
  digitalWrite(M1dirpin, HIGH); // Retorna ao ponto de origem
  for (int passo = 0; passo < numGraus * passosPorGrau; passo++) {
    digitalWrite(M1steppin, HIGH);
    delayMicroseconds(10);
    digitalWrite(M1steppin, LOW);
    delayMicroseconds(1000);
  }

  Serial.println("Iniciando medições de 0° a -180°...");
  realizar_medicoes(numGraus, 2 * numGraus, matriz, HIGH);

  Serial.println("Medições concluídas. Enviando matriz...");
  for (int angulo = 0; angulo < 360; angulo++) {
    for (int amostra = 0; amostra < 10; amostra++) {
      Serial.print(matriz[angulo][amostra]);
      if (amostra < 9) Serial.print(", ");
    }
    Serial.println();
    delay(10); // Atraso para evitar sobrecarga do buffer
  }
  Serial.println("Envio completo.");
}

void realizar_medicoes(int inicio, int fim, int matriz[][10], bool sentidoHorario) {
  digitalWrite(M1dirpin, sentidoHorario ? LOW : HIGH);
  for (int angulo = inicio; angulo < fim; angulo++) {
    for (int passo = 0; passo < passosPorGrau; passo++) {
      digitalWrite(M1steppin, HIGH);
      delayMicroseconds(10);
      digitalWrite(M1steppin, LOW);
      delayMicroseconds(1000);
    }

    // Coleta 10 amostras para o ângulo atual
    for (int amostra = 0; amostra < numAmostras; amostra++) {
      matriz[angulo][amostra] = analogRead(rfPin);
      delay(10); // Pequeno atraso para estabilizar a leitura
    }
  }
}



