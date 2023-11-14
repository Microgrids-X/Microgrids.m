function [mg] = define_mg()
% DEFINE_MG  Create a Microgrid system description structure with default values.
%
% This is the 2022 version of define_mg, using Ouessant_data_2016 data
% and the cost parameters from May 2021 HOMER Ouessant experiments.

data_file = ['data' filesep 'Ouessant_data_2016.csv'];
data = dlmread(data_file, ',', 2,1);

% Desired load (kW)
mg.load=data(1:8760,1)'; % (kW)


% Microgrid project information:
mg.project.lifetime = 25; % project lifetime (y)
mg.project.discount_rate = 0.05; % discount rate in [0,1]
mg.project.dispatch = "LF"; % energy dispatch strategy: load following
mg.project.timestep = 1.0; % operation time step (h)


% Dispatchable power source (e.g. Diesel generator, Gas turbine, Fuel cell)
mg.gen.power_rated =  1800; % rated power (kW)

mg.gen.fuel_intercept = 0.00; % fuel consumption curve intercept (L/h/kW_max)
mg.gen.fuel_slope = 0.24; % fuel consumption curve slope (L/h/kW)
mg.gen.fuel_price = 1.0; % fuel price ($/L)
mg.gen.fuel_unit = "L"; % fuel quantity unit (used in fuel price and consumption curve parameters)

mg.gen.investment_price = 400; % initial investiment price ($/kW)
mg.gen.om_price_hours = 0.02; % operation & maintenance price ($/kW/h of operation)
mg.gen.replacement_price_ratio = 1.0; % replacement price, relative to initial investment
mg.gen.salvage_price_ratio = 1.0; % salvage price, relative to initial investment

mg.gen.lifetime_hours = 15000; % generator lifetime (h of operation)
mg.gen.load_ratio_min = 0.0; % minimum load ratio in [0,1]


% Battery energy storage (including AC/DC converter)
mg.bat.energy_rated = 9000; % rated energy capacity (kWh)

mg.bat.investment_price = 350; % initial investiment price ($/kWh)
mg.bat.om_price = 10; % operation & maintenance price ($/kWh/y)
mg.bat.replacement_price_ratio = 1.0; % replacement price, relative to initial investment
mg.bat.salvage_price_ratio = 1.0; % salvage price, relative to initial investment

mg.bat.lifetime_calendar = 15; % calendar lifetime (y)
mg.bat.lifetime_cycles = 3000; % maximum number of cycles over life

mg.bat.efficiency = sqrt(0.90); % Charge/discharge efficiency in [0,1]. Remark: round-trip efficiency is efficiency^2
mg.bat.charge_rate = 1; % max charge power for 1 kWh (kW/kWh = h^-1)
mg.bat.discharge_rate = 1; % max discharge power for 1 kWh (kW/kWh = h^-1)
mg.bat.SoC_min = 0.0; % minimum State of Charge in [0,1]
mg.bat.SoC_ini = 0.0; % initial State of Charge in [0,1]


% Solar photovoltaic generator (including AC/DC converter)
mg.pv.power_rated = 6000; % Rated PV power (kW)
mg.pv.irradiance = data(1:8760,2)'/1000; % global solar irradiance incident on the PV array (kW/m²)

mg.pv.investment_price = 1200; % initial investiment price ($/kW)
mg.pv.om_price = 20; % operation & maintenance price ($/kW/y)
mg.pv.replacement_price_ratio = 1.0; % replacement price, relative to initial investment
mg.pv.salvage_price_ratio = 1.0; % salvage price, relative to initial investment

mg.pv.lifetime = 25; % lifetime (y)

end



 




 
 

 
