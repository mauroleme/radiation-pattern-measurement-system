#define RF_OUT_PIN A2
#define VCC 5.0

// Valores da calibração (dBm)
const float SLOPE = 0.0185; // V/dB (Este valor já está em V/dB)
const float INTERCEPT = 1.8621;

void setup() {
  Serial.begin(9600);
  delay(2000);
}

void loop() {
  int sensorValue = analogRead(RF_OUT_PIN);
  float voltage = sensorValue * (VCC / 1023.0);

  // Calcula a potência em dB usando a equação calibrada
  float power_dBm = (voltage - INTERCEPT) / SLOPE;

  // Limites de potência (ajuste conforme necessário)
  //  Remova se não forem necessários.  São apenas exemplos.
  if (power_dBm < -70.0) power_dBm = -70.0; 
  if (power_dBm > 0.0) power_dB = 0.0;     

  Serial.println(power_dBm);
  delay(100);
}