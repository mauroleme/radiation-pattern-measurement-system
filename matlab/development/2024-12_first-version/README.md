# First version of the project (December 2024)

The first attempt at the system, when the plan was still an **Arduino Mega**, a measurement over 360° with 10 samples per degree, and a 3D plot (see the two original `.md` notes).

- `StepperMotorHallSensorRFModule.m`: reads a 360 × 10 matrix sent by the Arduino after a `"0"` command
- `CommunicationTest.m`, `untitled*.m`: serial tests
- `RF-Pattern-Measurement.ino`, `Stepper-Motor-Control.ino`: the matching sketches
- `first_test_monopole.jpg`: the very first pattern, measured with a monopole
