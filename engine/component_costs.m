function [cost_factors] = component_costs(mg_project, lifetime, ...
    investment, replacement, salvage, om_annual, fuel_annual)
% LIFETIME_COSTS  Compute cost factors of a component over the microgrid lifetime
%
% These cost factor are net present $ for each factor presented below.
% Parameters:
% - mg_project: microgrid project description (e.g. with discount rate and lifetime)
% - lifetime: effective lifetime *of the component*
% - investment: initial investment
% - replacement: nominal cost for each replacement
% - salvage: nominal salvage value if component is sold at zero aging
% - om_annual: nominal O&M cost per year
% - fuel_annual: nominal total cost of fuel per year
%
% Output: cost factors, a vector of 6 costs:
% 1. Initial investment cost ($)
% 2. Replacement(s) cost ($)
% 3. O&M over microgrid project lifetime ($)
% 4. Fuel cost over microgrid project lifetime ($)
% 5. Salvage cost (negative)
% 6. Total (initial + replacement + O&M + fuel + salvage), i.e. NPC for component

CINI = 1;
CREP = 2;
COM = 3;
CFUE = 4;
CSAL = 5;
CTOT = 6;

cost_factors = zeros(CTOT,1);

% Microgrid project parameters:
mg_lifetime = mg_project.lifetime; % (y)
discount_rate = mg_project.discount_rate; % in [0,1]

% Discount factor for each year of the project:
discount_factors = zeros(mg_lifetime,1);
for i = 1:mg_lifetime
    discount_factors(i) = 1/(1 + discount_rate)^i;
end
% Sum of discount is like an effective project lifetime:
sum_discounts = sum(discount_factors); % (y)

% Initial investment:
cost_factors(CINI) = investment;

% Operation and maintenance cost
cost_factors(COM) = om_annual * sum_discounts;
cost_factors(CFUE) = fuel_annual * sum_discounts;

%% Replacement and salvage:

replacements_number = ceil(mg_lifetime/lifetime) - 1;
% discount factors for the replacement years:
replacement_factors = zeros(replacements_number,1);
for i = 1:replacements_number
    % year of replacement (can be non integer)
    y = i*lifetime;
    replacement_factors(i) = 1/(1 + discount_rate)^y;
end

if replacements_number == 0
    cost_factors(CREP) = 0;
else
    cost_factors(CREP) = replacement * sum(replacement_factors);
end

% Effective salvage value (considering the remaining lifetime of the component
% at the end of the project)
if lifetime < Inf
  % component remaining life at the project end
  remaining_life = lifetime*(1+replacements_number) - mg_lifetime;
  % effective nominal salvage value based on remaining life:
  salvage_effective = salvage * remaining_life / lifetime;
else % infinite lifetime (e.g. for generator of size 0)
  remaining_life = Inf;
  salvage_effective = salvage;
end

% salvage cost with discount:
cost_factors(CSAL) = -salvage_effective*discount_factors(mg_lifetime);

% Total cost, i.e. net present cost:
cost_factors(CTOT) = sum(cost_factors);

end