function res = T08_ad8313_calibration(b, opt)
%T08_AD8313_CALIBRATION Fits ADC counts vs RF input power.
%   Connect the signal generator (868 MHz CW) to the AD8313 input through
%   the same cable/adapters used in the measurement. For every power in
%   opt.calPowers the script asks you to set the generator, then reads
%   opt.calSamples raw ADC values. A least-squares line is fitted in the
%   linear range opt.calFitRange, and the result is printed as the two
%   constants used in firmware/main/main.ino:
%       power_dBm = A * analogRead(RF_PIN) + B      (currently A = 0.2722, B = -97.115)
%   This replaces the old constants and removes the ~3.5 dB mismatch noted
%   in the README between the firmware and the report (eq. 4.3).

res = newResult("T08", "AD8313 calibration (ADC -> dBm)");
P   = opt.calPowers(:);
adc = nan(size(P)); sd = nan(size(P));
for k = 1:numel(P)
    if b.Simulated
        b.Rig.GeneratorDbm = P(k) - opt.calCableLossDb;
    else
        input(sprintf("  Set the generator to %+.1f dBm and press Enter... ", P(k)), "s");
    end
    v = b.raw(opt.calSamples);
    adc(k) = mean(v); sd(k) = std(v);
end
Pin = P - opt.calCableLossDb;                         % power at the detector

use = Pin >= opt.calFitRange(1) & Pin <= opt.calFitRange(2);
c   = polyfit(adc(use), Pin(use), 1);                  % Pin = A*adc + B
A   = c(1); B = c(2);
resid = Pin(use) - polyval(c, adc(use));
mVperDb = 1000 * 5/1023 / A;

res.values = struct("powerDbm", Pin, "adc", adc, "adcStd", sd, "A", A, "B", B, ...
                    "residualDb", resid, "mVperDb", mVperDb);
res.lines = [
    sprintf("Fit over %.0f..%.0f dBm (%d points): power_dBm = %.4f * ADC %+.3f", ...
            opt.calFitRange, nnz(use), A, B)
    sprintf("Slope %.2f mV/dB (datasheet ~18-19 mV/dB) | max residual %.2f dB | ADC noise %.1f LSB", ...
            mVperDb, max(abs(resid)), mean(sd))
    sprintf("Firmware now: 0.2722 * ADC - 97.115 -> reads %+.2f dB off at a true -30 dBm", ...
            0.2722*((-30 - B)/A) - 97.115 + 30)
    sprintf("Paste into main.ino capture_sensor_data(): power_dBm = raw * %.4f + (%.3f);", A, B)
    ];
good = max(abs(resid)) <= opt.maxCalResidualDb && mVperDb > 15 && mVperDb < 23;
res.status = pick(good, "PASS", "FAIL");

res.fig = figure("Color", "w", "Name", res.id);
subplot(2,1,1);
plot(Pin, adc, "o", "DisplayName", "measured"); hold on;
xx = linspace(min(adc(use)), max(adc(use)), 50);
plot(polyval(c, xx), xx, "-", "LineWidth", 1.2, "DisplayName", "fit");
xlabel("Input power (dBm)"); ylabel("ADC counts"); grid on; legend("Location", "northwest");
title("AD8313 transfer curve");
subplot(2,1,2);
stem(Pin(use), resid, "filled"); grid on;
xlabel("Input power (dBm)"); ylabel("Residual (dB)");
end
