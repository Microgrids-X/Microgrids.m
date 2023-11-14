function [oper_traj] = sim_operation(mg)
% SIM_OPERATION  Simulate the Microgrid operation (e.g. energy dispatch) over 1 year
%
% Implement: LF dispatch, with Pgen_min assumed 0, without operating reserve,
% with constant efficiency battery model, with SOC_min

%% 1. Import mg parameters as local variables

load = mg.load; % desired load

nsteps = length(load); % likely 8760
dt = mg.project.timestep; % operation timestep (h)

% PV production
pvPprod = mg.pv.irradiance*mg.pv.power_rated;
% Total renewable power potential:
Prenew_pot = pvPprod; % add wind here when implemented

% Battery
batErated = mg.bat.energy_rated; % battery capacity
batEffi = mg.bat.efficiency; % battery efficiency
batEini = mg.bat.SoC_ini*batErated; % battery initial energy level
batEmin = mg.bat.SoC_min*batErated; % battery min energy level
assert(batEini >= batEmin);
batPChargeMax = -mg.bat.charge_rate*batErated; % max power when charging (negative flow)
batPDischargeMax = mg.bat.discharge_rate*batErated; % max power when discharging

% Generator
genPrated = mg.gen.power_rated;
genPmin = mg.gen.load_ratio_min * genPrated; % Not implemented in dispatch below!


%% 2. Initialization of time series vectors:
genPprod = zeros(1,nsteps);
batPprod = zeros(1,nsteps);
batElevel = zeros(1,nsteps+1); % Energy level (kWh)
Pshed = zeros(1,nsteps); % Load shedding: power not served to the load
Pspill = zeros(1,nsteps); % Spillage of non-dispatchable (e.g. renewables) power when battery is full

% Initial state of energy:
batElevel(1) = batEini;


%% 3. Simulate operation with LF energy dispatch:
netLoad = load - Prenew_pot;
for i = 1:nsteps % for each operation instant
    % A. Compute the min/max of controllable generation (battery+generator)
    
    % Battery charge/discharge limits due to energy level over upcoming timestep:
    % (this enforces the constraint that batEmin <= batElevel(i) <= batErated)
    diffDischargeMax = (batElevel(i)-batEmin)*batEffi/dt;
    diffChargeMax = (batElevel(i)-batErated)/batEffi/dt; % negative
    % Battery charge/discharge limits due to both energy level and power limits:
    batMaxDischarge = min(batPDischargeMax, diffDischargeMax);
    batMaxCharge = max(batPChargeMax, diffChargeMax); % note: both terms are <= 0, so it's a min of absolute values
    
    % Limits of controllable generation:
    prodCtrlMax = genPrated + batMaxDischarge;
    prodCtrlMin = batMaxCharge;
    
    % B. Decide last recourse actions: load shedding and curtailment of renewables
    if netLoad(i) > prodCtrlMax % Not enough energy
        Pshed(i) = netLoad(i) - prodCtrlMax; % amount of load shedding
        Pspill(i) = 0;
    elseif netLoad(i) < prodCtrlMin % Excess of energy
        Pshed(i) = 0;
        Pspill(i) = prodCtrlMin - netLoad(i); % curtailment of renewables
    else % neither load shedding nor curtailment of renewables
        Pshed(i) = 0;
        Pspill(i) = 0;
    end
    
    % C. Energy dispatch (Load following strategy: battery first, then generator)
    netLoadActual = netLoad(i) - Pshed(i) + Pspill(i);
    if netLoadActual >= 0 % battery discharging
        if netLoadActual <= batMaxDischarge % battery alone is enough
            batPprod(i) = netLoadActual;  % >= 0
            genPprod(i) = 0;
        else
            batPprod(i) = batMaxDischarge;
            genPprod(i) = netLoadActual - batMaxDischarge;
        end
        % Battery energy level dynamics, during discharge:
        batElevel(i+1) =  batElevel(i) - batPprod(i)/batEffi*dt;
        
    else % (netLoad<0), i.e. battery charging, generator off
        genPprod (i) = 0;
        batPprod (i) = netLoadActual;
        % Battery energy level dynamics, during charge:
        batElevel(i+1) = batElevel(i) - batPprod(i)*batEffi*dt;
    end
end % for each operation instant

%% Save operation time series outputs:
oper_traj.gen.Pprod = genPprod;
oper_traj.bat.Pprod = batPprod;
oper_traj.bat.Elevel = batElevel;
oper_traj.Prenew_pot = Prenew_pot;
oper_traj.Pspill = Pspill;
oper_traj.load.Pshed = Pshed;

end % function