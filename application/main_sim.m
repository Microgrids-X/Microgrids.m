% Application script: evaluate the performance of microgrid project
% (using `sim_mg`)
% Pierre Haessig, 2023

% add the microgrid simulator to path:
mg_path = [ '..' filesep 'engine'];
addpath(mg_path)


% Sizing under test:
x = [1800 9000 6000]; % "Base" case

% Base Microgrid description:
mg = define_mg; % Ouessant 2016 data
% Simplifications:
%mg.project.discount_rate = 0.0; % no discount

% Set sizing in mg description:
mg.gen.power_rated = x(1);
mg.bat.energy_rated = x(2);
mg.pv.power_rated  = x(3);

%% Run Microgrid simulation:

[costs oper_stats oper_traj] = sim_mg(mg);

%% Display simulation results

disp("Cost table (M$):")
disp(costs.table/1e6)
fprintf("LCOE: %.4f $/kWh\n", costs.LCOE)
fprintf("Shed rate: %.4f%%\n", oper_stats.load.shedRate*100)
fprintf("Renew. rate: %.2f%%\n", oper_stats.renewRate*100)
fprintf("Fuel: %.3f kl/y\n", oper_stats.gen.fuel/1e3)

save_cost_mat = 0;

if save_cost_mat
  fname = "current.xlsx"
  disp(["Saving cost matrix: " fname])
  sheet = "costs";
  xlswrite(fname, {"Costs (M$)"}, sheet, "A1");
  xlswrite(fname, costs.cmat/1e6, sheet, "B2:G5");
  xlswrite(fname, costs.cmat_cols, sheet, "B1:G1");
  xlswrite(fname, costs.cmat_rows', sheet, "A2:A5");
  
  % TODO: also save the CRF, the sizing, and all oper_stats in other sheets
end

%% Show trajetories:

% which period to zoom on:
t0 = 100; % days
t1 = t0 + 5;
%t0 = 0;
%t1 = t0+365;

plot_traj(mg, oper_traj, t0, t1)
