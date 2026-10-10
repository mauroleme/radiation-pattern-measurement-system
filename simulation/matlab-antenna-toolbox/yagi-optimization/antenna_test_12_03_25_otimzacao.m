refLengthBounds = [0.3;                         % lower bound on reflector length
                   0.9];                        % upper bound on reflector spacing
dirLengthBounds = [0.3 0.3 0.3 0.3;             % lower bound on director length
                   0.7 0.7 0.7 0.7];            % upper bound on director length
refSpacingBounds = [0.05;                       % lower bound on reflector spacing
                    0.35];                      % upper bound on reflector spacing
dirSpacingBounds = [0.05 0.05 0.05 0.05;        % lower bound on director spacing
                    0.2 0.2 0.3 0.3];           % upper bound on director spacing
exciterLengthBounds = [0.45;                    % lower bound on exciter length
                       0.6];                    % upper bound on exciter length
exciterSpacingBounds = [.004;
                        .009];
                
LB = [refLengthBounds(1),dirLengthBounds(1,:) refSpacingBounds(1) dirSpacingBounds(1,:) exciterLengthBounds(1) exciterSpacingBounds(1)  ].*lambda;
UB = [refLengthBounds(2),dirLengthBounds(2,:) refSpacingBounds(2) dirSpacingBounds(2,:) exciterLengthBounds(2) exciterSpacingBounds(2) ].*lambda;
parameterBounds.LB = LB;
parameterBounds.UB = UB;
ang = [0 0;90 -90];                   % azimuth,elevation angles for main lobe and back lobe [az;el]


% Optimizer options
optimizerparams = optimoptions(@patternsearch);
optimizerparams.UseCompletePoll = true;    
optimizerparams.PlotFcns = @psplotbestf;
optimizerparams.UseParallel = canUseGPU();
optimizerparams.Cache = "on";
optimizerparams.MaxIter = 100;
optimizerparams.FunctionTolerance = 1e-2;

% Antenna design parameters
designparams.Antenna = yagidesign;

designparams.Bounds = parameterBounds;

% Analysis parameters
analysisparams.CenterFrequency = fc;
analysisparams.Bandwidth = BW;
analysisparams.ReferenceImpedance = Z0;
analysisparams.MainLobeDirection = ang(:,1);
analysisparams.BackLobeDirection = ang(:,2);

% Set constraints
constraints.S11min = -10;
constraints.Gmin = 10.5;
constraints.Gdeviation = 0.1;
constraints.FBmin = 15;
constraints.Penalty = 50;
optimdesign = optimizeAntennaDirect(designparams,analysisparams,constraints,optimizerparams); 


yagidesign.ReflectorLength = optimdesign(1);
yagidesign.DirectorLength = optimdesign(2:5);
yagidesign.ReflectorSpacing = optimdesign(6);
yagidesign.DirectorSpacing = optimdesign(7:10);
yagidesign.Exciter.Length = optimdesign(11);
yagidesign.Exciter.Spacing = optimdesign(12);
fig2 = figure;
pattern(yagidesign,fc)