function [costs, oper_stats, oper_traj] = sim_mg(mg)
  % SIM_MG  simulates the microgrid described by mg structure

  oper_traj = sim_operation(mg);
  oper_stats = aggregate_oper(mg, oper_traj);
  costs = sim_economics(mg, oper_stats);

end
