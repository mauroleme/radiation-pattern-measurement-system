#define M1dirpin 4     // Pino de direção do motor 1 (X - Azimute)
#define M1steppin 5    // Pino de passo do motor 1 (X - Azimute)
#define M1en 12         // Pino de habilitação do motor 1 (X - Azimute)
#define HallPin A2    // Pino de leitura analógica do sensor de efeito Hall

const int stepsPerDegree = 16;       // Micropassos por grau no eixo final (1° no eixo = 15 micropassos)
const unsigned long stepInterval = 1600; // Intervalo entre micropassos em microssegundos
unsigned long lastStepTime = 0;

// Variáveis de controle
int stepsToMove = 0; // Passos restantes no movimento atual
int direction = 0;   // Direção do movimento (1 = horário, -1 = anti-horário)
bool foundOrigin = false; // Indica se o ponto de origem foi encontrado
int movementStage = 0;    // Estágio atual do movimento

void setup() {
  pinMode(M1dirpin, OUTPUT);
  pinMode(M1steppin, OUTPUT);
  pinMode(M1en, OUTPUT);
  pinMode(HallPin, INPUT); // Configura o pino analógico como entrada

  digitalWrite(M1en, LOW); // Habilita o motor
  Serial.begin(115200);    // Comunicação serial para depuração
  Serial.println("Inicializando sistema...");
}

void loop() {
  if (!foundOrigin) {
    findOrigin(); // Procura o ponto de origem
  } else {
    executeCycle(); // Executa o ciclo de movimentos após encontrar a origem
  }

  // Continua executando os passos restantes
  executeMovement();
}

void findOrigin() {
  unsigned long currentTime = micros();

  if (currentTime - lastStepTime >= stepInterval) {
    lastStepTime = currentTime;

    // Gera pulso para o motor
    digitalWrite(M1steppin, HIGH);
    delayMicroseconds(10); // Pulso curto
    digitalWrite(M1steppin, LOW);

    // Lê o valor analógico do sensor
    int sensorValue = analogRead(HallPin);

    // Verifica se o valor está abaixo do limiar (ímã detectado)
    if (sensorValue < 100) { // Valor limiar para detectar o ímã
      foundOrigin = true;
      stepsToMove = 0; // Para o motor
      Serial.println("Origem encontrada!");
    }
  }
}

void executeCycle() {
  if (stepsToMove == 0) {
    switch (movementStage) {
      case 0:
        Serial.println("Movendo 180° no sentido horário.");
        moveMotor(180, 1); // 180° no sentido horário
        break;
      case 1:
        Serial.println("Retornando ao ponto de origem.");
        moveMotor(180, -1); // Retorna ao ponto de origem
        break;
      case 2:
        Serial.println("Movendo 180° no sentido anti-horário.");
        moveMotor(180, -1); // 180° no sentido anti-horário
        break;
      case 3:
        Serial.println("Retornando ao ponto de origem.");
        moveMotor(180, 1); // Retorna ao ponto de origem
        break;
    }

    // Avança para o próximo estágio
    movementStage = (movementStage + 1) % 4; // Retorna ao estágio 0 após o estágio 3
  }
}

void moveMotor(int angle, int dir) {
  stepsToMove = angle * stepsPerDegree; // Calcula os passos necessários
  direction = dir; // Define a direção
  digitalWrite(M1dirpin, direction == 1 ? HIGH : LOW); // Ajusta o pino de direção

  // Imprime no Serial Monitor
  Serial.print("Movendo ");
  Serial.print(angle);
  Serial.print("° no sentido ");
  Serial.println(direction == 1 ? "horário" : "anti-horário");
}

void executeMovement() {
  if (stepsToMove > 0) {
    unsigned long currentTime = micros();

    if (currentTime - lastStepTime >= stepInterval) {
      lastStepTime = currentTime;

      // Gera pulso
      digitalWrite(M1steppin, HIGH);
      delayMicroseconds(10); // Pulso curto
      digitalWrite(M1steppin, LOW);

      stepsToMove--; // Decrementa os passos restantes
    }
  }
}

