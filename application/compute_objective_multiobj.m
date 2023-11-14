function [objectives] = compute_objective_multiobj(x, mg, variant, shed_max, w_shed_max, LCOE_max, w_LCOE_max)
% COMPUTE_OBJECTIVE_MULTIOBJ  Compute the multiobjective function to be minimized
% 
% Variant 1:
%   min LCOE, shedding
%   s.t. shedding <= shedMax
%        LCOE     <= LCOE_max
%
% Variant 2:
%   min LCOE, 1-renewRate
%   s.t. shedding <= shedMax
%        LCOE     <= LCOE_max
%
% Inputs:
% - x: sizing vector [gen.power_rated, bat.energy_rated, pv.power_rated]
% - mg: base microgrid project description
% - variant: choice of objectives to be minimized (1 or 2)
% - shed_max: maximum allowed load shedding rate in energy, in [0,1]
% - w_shed_max: penalty weight for shedRate-shed_max (when > 0)
% - LCOE_max: maximum allowed LCOE ($/kWh)
% - w_LCOE_max: penalty weight for LCOE-LCOE_max (when > 0)


% Set sizing in mg description:
mg.gen.power_rated = x(1);
mg.bat.energy_rated = x(2);
mg.pv.power_rated  = x(3);

[costs, oper_stats, ~] = sim_mg(mg);

% Penalty for load shedding > shedMax and LCOE > LCOE_max
penalty = 0;
over_shed = oper_stats.load.shedRate - shed_max;
if over_shed>0
    penalty = penalty + w_shed_max*over_shed;
end

over_LCOE =  costs.LCOE - LCOE_max;
if over_LCOE>0
    penalty = penalty + w_LCOE_max*over_LCOE;
end

% Choice of the two objectives to be minimized:
if variant == 1 % min LCOE, shedding
    f1 = costs.LCOE + penalty;
    f2 = oper_stats.load.shedRate + penalty;
elseif variant == 2 % min LCOE, 1-renewRate
    f1 = costs.LCOE + penalty;
    f2 = 1-oper_stats.renewRate + penalty;
else
    error('variant should be 1 or 2')
end

objectives = [f1 f2];

end % function
