function plot_traj (mg, oper_traj, t0, t1)
% PLOT_TRAJ  Plot microgrid operation trajectories
%
% Zoom on the period t0 to t1 (in days)
% TODO: make these last two arguments optionals.

genPprod = oper_traj.gen.Pprod;
batPprod = oper_traj.bat.Pprod;
batElevel = oper_traj.bat.Elevel;
pvPprod = oper_traj.Prenew_pot;
Pshed = oper_traj.load.Pshed;
Pspill = oper_traj.Pspill;

n = length(genPprod);
t = (0:n-1)/24; % days % TODO: adapt to other time step

subplot(3,1,1)
plot(t, mg.load)
hold on
plot(t, pvPprod)
plot(t, Pshed)
plot(t, Pspill)
xlim([t0 t1])
grid on
legend("load", "pv", "shed", "spill")

subplot(3,1,2)
plot(t, genPprod)
hold on
plot(t, batPprod)
xlim([t0 t1])
grid on
legend("gen", "bat")

subplot(3,1,3)
plot(t, batElevel(1:end-1))
xlim([t0 t1])
grid on
legend("E bat")

end % function
