% Application script: optimize the sizing of microgrid project
% Multi-objective variant 1: min LCOE, shedding, s.t. shedding ≤ shedMax
% Pierre Haessig, 2023

% add the microgrid simulator to path:
mg_path = [ '..' filesep 'engine'];
addpath(mg_path) 


% Base Microgrid description:
mg = define_mg; % Ouessant 2016 data

% Objective function, wrapped with given parameter values:

variant = 1; % min LCOE, shedding
%variant = 2; % min LCOE, 1-renewRate
%shed_max = 0.05;
shed_max = 0.90;
w_shed_max = 1e4;
% no constraint on LCOE:
LCOE_max = 0; % €/kWh
w_LCOE_max = 0; % no constraint on LCOE:

f = @(x) compute_objective_multiobj(x, mg, variant, ...
             shed_max, w_shed_max, ...
             LCOE_max, w_LCOE_max);

% Optimization bounds:
Pmax = max(mg.load);
lb = [0 0 0];
ub = [1.2*Pmax 10*Pmax 10*Pmax];

% Test objective function wrapper, with timing:
% tic
% for i=1:1000
% f(ub/2);
% end
% toc
% Octave: 0.2 s per simulator call.
% Matlab R2022a under VirtualBox: 0.5 ms per simulator call (400x speed up).

%% Optimization (with Matlab's gamultiobj, from Global Optimization Toolbox)
options = optimoptions('gamultiobj', ...
    'PopulationSize', 200, ... % 50 is the default
    'FunctionTolerance', 1e-4, ... % 1e-4 is the default. Can take much longer with smaller values
    'MaxGenerations', 200*3); % 200*n variables is the default value
% activate live plotting of the cost function convergence:
%options = optimoptions(options, 'PlotFcn',@gaplotpareto);

disp('Optimization with gamultiobj...')
[x_ga,fval_ga,exitflag_ga,output_ga] = gamultiobj(f, 3, [],[],[],[], lb, ub, options);
fprintf('done after %d generations and %d function calls\n', output_ga.generations, output_ga.funccount)

% Extract results
LCOE_ga = fval_ga(:,1);
shedRate_ga = fval_ga(:,2);

Pgen_ga = x_ga(:,1);
Ebatt_ga = x_ga(:,2);
Ppv_ga = x_ga(:,3);

%% Optimization (with Matlab's paretosearch, from Global Optimization Toolbox)

options = optimoptions('paretosearch', ...
    'ParetoSetSize', 200, ... % 60 is the default
    'ParetoSetChangeTolerance', 1e-6, ... % 1e-4 is the default
    'MaxIterations', 100*(3+2)); % 100*(nvars+nobj) is the default value
% activate live plotting of the cost function convergence:
%options = optimoptions(options, 'PlotFcn', @psplotparetof);

disp('Optimization with paretosearch...')
[x_ps,fval_ps,exitflag_ps,output_ps] = paretosearch(f, 3, [],[],[],[], lb, ub, [], options);
fprintf('done after %d iterations and %d function calls\n', output_ps.iterations, output_ps.funccount)

% Extract results
LCOE_ps = fval_ps(:,1);
shedRate_ps = fval_ps(:,2);

Pgen_ps = x_ps(:,1);
Ebatt_ps = x_ps(:,2);
Ppv_ps = x_ps(:,3);

%% Save optimization results to file

%d_ps = table(LCOE_ps, shedRate_ps , Pgen_ps, Ebatt_ps, Ppv_ps,'VariableNames', {'LCOE','renewRate', 'Pgen', 'Ebatt', 'Ppv'});
d_ga = table(LCOE_ga, shedRate_ga , Pgen_ga, Ebatt_ga, Ppv_ga,'VariableNames', {'LCOE','renewRate', 'Pgen', 'Ebatt', 'Ppv'});
d_ga = sortrows(d_ga, 'LCOE');
csv_filename = sprintf('optim_MO-Cost-Shed-max%02.0f_ga.csv', shed_max*100);
writetable(d_ga, csv_filename)
disp(['Results saved to ' csv_filename]);

%% Plot Pareto optimal sizing results

fig1 = figure(1);
plot(shedRate_ps*100, LCOE_ps, '+')
hold on
plot(shedRate_ga*100, LCOE_ga, 'x')

legend('paretosearch', 'gamultiobj', 'Location','northwest')
xlabel('Load shedding (%)')
ylabel('LCOE (€/kWh)')
t = sprintf('Cost vs load shedding (for shedding ≤ %.1f%%)', shed_max*100);
title(t)
grid on

fig2 = figure(2);
fig2.Position(2) = 100; % move close to screen bottom
fig2.Position(3:4) = [560 560*1.5]; % size: higher than wide 


subplot(3,1,1)
plot(shedRate_ps*100, Pgen_ps, '+')
hold on
plot(shedRate_ga*100, Pgen_ga, 'x')

legend('paretosearch', 'gamultiobj', 'Location','southwest')
xlabel('Load shedding (%)')
ylabel('Pgen (kW)')
t = sprintf('Sizing vs load shedding (for shedding ≤ %.1f%%)', shed_max*100);
title(t)
grid on

subplot(3,1,2)
plot(shedRate_ps*100, Ebatt_ps/1000, '+')
hold on
plot(shedRate_ga*100, Ebatt_ga/1000, 'x')

xlabel('Load shedding (%)')
ylabel('Ebatt (MWh)')
grid on

subplot(3,1,3)
plot(shedRate_ps*100, Ppv_ps/1000, '+')
hold on
plot(shedRate_ga*100, Ppv_ga/1000, 'x')
xlabel('Load shedding (%)')
ylabel('Ppv (MWp)')
grid on
