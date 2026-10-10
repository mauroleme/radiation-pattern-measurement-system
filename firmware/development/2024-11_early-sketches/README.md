# Early sketches (November-December 2024)

The first experiments, before the `Joint` class and the MATLAB protocol existed. They are kept to show how the firmware evolved.

| Sketch | What it tested |
|---|---|
| `teste-motor-de-passo` | First stepper motor test (DRV8825) |
| `hall_sensor_test` | KY-035 Hall sensor output (mV and mT) |
| `teste_hall_e_motor`, `teste_hall_e_motor_28Nov` | Homing on the magnet, then the 0 → +180 → 0 → −180 → 0 cycle that was kept in the final design |
| `sketch_nov29a`, `sketch_nov29b-funciona`, `29_11_2024b`, `02_12_2024_funcionando` | Motor + Hall iterations (`funciona` = the one that worked) |
| `sketch_dec3_funciona_moduloRF_sensorHall_ControloMotor` | First sketch combining the RF module, the Hall sensor and motor control |
| `Dec9_new_test` | Last test before the `Joint` refactor |
| `modulo_RF_teste`, `teste_modulo_RF` | AD8313 module readings |

The `Stepper` and `StepperDriver` Arduino libraries that sat next to these sketches are third-party and are not included.
