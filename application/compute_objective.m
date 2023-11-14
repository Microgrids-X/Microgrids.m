function [objective] = compute_objective(x, mg, w_shed, w_co2)
% COMPUTE_OBJECTIVE  Compute the objective function to be minimized
% Mono objective: "socialized annualized project cost" in M$
% Inputs:
% - x: sizing vector [gen.power_rated, bat.energy_rated, pv.power_rated]
% - mg: base microgrid project description
% - w_shed, w_co2: weighting of unserved energy ($/kWh) and CO2 emissions ($/tCO2)

% Set sizing in mg description:
mg.gen.power_rated = x(1);
mg.bat.energy_rated = x(2);
mg.pv.power_rated  = x(3);

[costs, oper_stats, ~] = sim_mg(mg);

co2_per_liter = 2.5e-3; % tCO2/liter

objective = costs.annualized_cost ...
          + w_shed*oper_stats.load.Eshed ...
          + w_co2*oper_stats.gen.fuel*co2_per_liter;

objective = objective/1e6; % $/y to M$/y    

end % function
