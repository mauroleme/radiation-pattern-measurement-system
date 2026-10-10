# MATLAB Antenna Toolbox studies (March 2025)

Before the CST model, the Yagi-Uda was explored with MATLAB's Antenna Toolbox (`yagiUda`, `dipole`, `pattern`).

- `Antenna.m`: first 3-director brass Yagi at 868 MHz
- `yagi-optimization/antenna_test_12_03_25*.m`, `test*.m`, `teste*antena.m`: 4-director Yagi (dipole exciter, 1.5 mm wire, 50 Ω) and its **pattern-search optimisation** for S11 < −10 dB, gain > 10.5 dBi and F/B > 15 dB
- `polarEplane.png`, `polarHplane.png`, `first_attempt.mat`: results

The optimisation calls `optimizeAntennaDirect` and `yagi_objective_function_direct`. These are MathWorks example files (© The MathWorks), so they are not redistributed here. They come with the Antenna Toolbox example *"Direct Search Based Optimization of Six-Element Yagi-Uda Antenna"*.
