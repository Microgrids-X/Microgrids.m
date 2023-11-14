% Application script: optimize the sizing of microgrid project
% (mono-objective version, based on a weighted objective function)
% TODO: change the cost function to work on LCOE rather than annualized cost

% add the microgrid simulator to path:
mg_path = [ '..' filesep 'engine'];
addpath(mg_path)


% Base Microgrid description:
mg = define_mg; % Ouessant 2016 data

% Objective function wrapped with parameter values:
w_shed = 1; % $/kWh
w_co2 = 0; % $/tCO2

f = @(x) compute_objective(x, mg, w_shed, w_co2);

% Optimization bounds:
Pmax = max(mg.load);
lb = [0 0 0];
ub = [1.2*Pmax 10*Pmax 10*Pmax];

% Test objective function wrapper, with timing:
% tic
% for i=1:1000
% f(ub);
% end
% toc
% Octave: 0.2 s per simulator call.
% Matlab R2022a under VirtualBox: 0.5 ms per simulator call (400x speed up).

%% Optimization (Matlab version)
options = optimoptions('particleswarm', ...
    'SwarmSize', 150 , ...
    'MaxIterations', 100);
% activate live plotting of the cost function convergence:
%options = optimoptions(options, 'PlotFcn',@pswplotbestf);

[x,fval,exitflag,output] = particleswarm(f, 3, lb, ub, options);
display(x) % x=[1.2560 6.7034 4.0164]*1e3 for w_shed = 1 $/kWh, w_co2=0

%% Optimize with Nlopt (e.g. Octave)
% opt.algorithm = NLOPT_GN_DIRECT;
% opt.min_objective = f;
% opt.lower_bounds = lb;
% opt.upper_bounds = ub;
% opt.xtol_rel = 1e-3;
% opt.maxeval = 1000;

%[xopt, fmin, retcode] = nlopt_optimize(opt, ub/10);
% 1707.0   7602.3   5690.0
%fmin = 1.7977
% retcode = 5;
