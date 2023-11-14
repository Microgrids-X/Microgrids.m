function [costs] = sim_economics(mg, oper_stats)
% SIM_ECONOMICS  Simulate economic performance  given operational statistics
% inputs: mg, oper_stats (from aggregate_oper)
% output: costs structure with:
% - LCOE
% - NPC
% - table of cost factors
% - sys: cost factors for the entire system
% - cost factors per component: gen, bat, pv

%% Prepare table of costs:
% - one line per component, with one last line for total
% - one column for each cost component: Initial investment, Replacement,
%   O&M, Fuel, Salvage, and Sum (i.e. NPC of component)
table_rows = {"Generator" "Battery" "Solar PV" "System"};
RGEN = 1;
RBAT = 2;
RPV = 3;
RSYS = 4;
table_cols = {"Initial" "Replacement" "O&M" "Fuel" "Salvage" "Total by component"};
CINI = 1;
CREP = 2;
COM = 3;
CFUE = 4;
CSAL = 5;
CTOT = 6;
costs_table = zeros(RSYS, CTOT);


%% Discount and Capital Recovery factors

mg_lifetime = mg.project.lifetime; % (y)
discount_rate = mg.project.discount_rate; % in [0,1]

% Discount factor for each year of the project:
discount_factors = zeros(mg_lifetime,1);
for i = 1:mg_lifetime
    discount_factors(i) = 1/(1 + discount_rate)^i;
end

% Sum of discount is like an effective project lifetime:
sum_discounts = sum(discount_factors); % (y)
% Capital Recovery Factor
CRF = 1/sum_discounts; % (y^-1)


%% Costs of the Dispatchable generator (e.g. Diesel)

rating = mg.gen.power_rated;
% effective lifetime of the generator:
lifetime = mg.gen.lifetime_hours / oper_stats.gen.hours; % h / (h/y) → y
% nominal costs:
investment = mg.gen.investment_price * rating;
replacement = investment * mg.gen.replacement_price_ratio;
salvage = investment * mg.gen.salvage_price_ratio;
om_annual = mg.gen.om_price_hours * oper_stats.gen.hours * rating;
fuel_annual = mg.gen.fuel_price * oper_stats.gen.fuel;
% conversion to net present cost factors
gen_costs = component_costs(mg.project, lifetime,...
                            investment, replacement, salvage,...
                            om_annual, fuel_annual);

costs_table(RGEN, :) = gen_costs;


%% Costs of the Battery

rating = mg.bat.energy_rated;
% effective lifetime of the battery (calendar and cycling):
lifetime = min([mg.bat.lifetime_calendar, ...
                mg.bat.lifetime_cycles/oper_stats.bat.cycles]);
% nominal costs:
investment = mg.bat.investment_price * rating;
replacement = investment * mg.bat.replacement_price_ratio;
salvage = investment * mg.bat.salvage_price_ratio;
om_annual = mg.bat.om_price * rating;
fuel_annual = 0;
% conversion to net present cost factors
bat_costs = component_costs(mg.project, lifetime,...
                            investment, replacement, salvage,...
                            om_annual, fuel_annual);

costs_table(RBAT, :) = bat_costs;


%% Costs of the Solar PV plant

rating = mg.pv.power_rated;
% lifetime of PV plant
lifetime = mg.pv.lifetime;
% nominal costs:
investment = mg.pv.investment_price * rating;
replacement = investment * mg.pv.replacement_price_ratio;
salvage = investment * mg.pv.salvage_price_ratio;
om_annual = mg.pv.om_price * rating;
fuel_annual = 0;
% conversion to net present cost factors
pv_costs = component_costs(mg.project, lifetime,...
                           investment, replacement, salvage,...
                           om_annual, fuel_annual);

costs_table(RPV, :) = pv_costs;


%% Costs for the entire system (sum of all components)
sys_costs = gen_costs + bat_costs + pv_costs;
assert(all(abs(sys_costs - sum(costs_table, 1)') < 1e-10)); % check consistency of the summation
costs_table(RSYS, 1:end) = sys_costs;

% Net Present Cost of the system:
NPC = sys_costs(CTOT);

% Cost of energy (LCOE)
annualized_cost = NPC * CRF;
LCOE = annualized_cost / oper_stats.load.Eserv;

%% Cost output structure:

% Cost factors stored as structure of cost factors:
costs.gen = gen_costs;
costs.bat = bat_costs;
costs.pv = pv_costs;
costs.sys = sys_costs;

% Cost factors as a table:

costs.table = costs_table;
costs.table_rows = table_rows;
costs.table_cols = table_cols;

% NPC and LCOE (+ CRF for easy conversion to annualized costs)
costs.CRF = CRF; % y^-1 (perhaps CRF should belong to mg description?)
costs.LCOE = LCOE;
costs.annualized_cost = annualized_cost;
costs.NPC = NPC;

end % function