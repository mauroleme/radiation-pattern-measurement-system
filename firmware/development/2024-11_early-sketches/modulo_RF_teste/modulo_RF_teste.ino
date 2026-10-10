#define RF_OUT_PIN A2  // Pino analógico conectado ao OUT do módulo
#define VCC 5.0        // Tensão de referência do Arduino (5V para Uno)

const float SLOPE = 18.0;      // Inclinação: 18 mV/dBm
const float V_MIN = 0.5;       // Tensão mínima de saída (-72 dBm)
const float POWER_MIN = -72.0; // Potência mínima detectável
const float THRESHOLD = -35.0; // Limiar para detectar picos (ajustado para -26.74 dBm)
const float BASELINE = -50.0;  // Fundo observado nas amostras anteriores

void setup() {
  Serial.begin(9600);
  delay(2000);
  Serial.println("Testando com RF Explorer...");
}

void loop() {
  // Lê o valor analógico
  int sensorValue = analogRead(RF_OUT_PIN);
  
  // Converte para tensão
  float voltage = sensorValue * (VCC / 1023.0);
  
  // Calcula a potência em dBm
  float power_dBm = POWER_MIN + (voltage - V_MIN) / (SLOPE / 1000.0);
  
  // Limita a faixa de potência
  if (power_dBm < -72.0) power_dBm = -72.0;
  if (power_dBm > -2.0) power_dBm = -2.0;

  // Aplica a lógica do limiar
  float output_power;
  if (power_dBm >= THRESHOLD) {
    output_power = power_dBm; // Mostra o pico real
  } else {
    output_power = BASELINE;  // Força linha constante no fundo
  }

  // Plota potência bruta e filtrada
  Serial.print(power_dBm);       // Potência real
  Serial.print(" ");
  Serial.println(output_power);  // Potência com limiar

  delay(100); // 10 amostras por segundo
}