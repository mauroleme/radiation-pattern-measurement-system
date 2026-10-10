# Commissioning tests

Hardware checks of the positioner: motion, calibration and RF chain. They run on a **separate test firmware** ([`firmware/commissioning`](../../firmware/commissioning)), so the measurement firmware is only changed once the tests have shown what to change.

➡️ **Step-by-step instructions: [PROCEDURE.md](PROCEDURE.md)**

| File | Role |
|---|---|
| `RunCommissioning.m` | Runs T01-T09 group by group and writes a dated report to `reports/` |
| `T01_…` to `T09_…` | One test each, returning PASS/FAIL, the numbers and a plot |
| `Bench.m` | Talks to the test firmware (or to the simulator) |
| `SimulatedRig.m` | Software model of the platform with faults injected on purpose, for dry runs |
| `example-report_SIMULATED/` | What a report looks like (**simulated, not hardware**) |
