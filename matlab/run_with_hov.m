clear
close all

init_config;

ORS = [];



if auto_config
% 1. Generate configuration file [optional] ................................
disp('1. Generate XML configuration file')
tic
make_config_xml2;
disp(['Done in ' num2str(toc) ' seconds.']);
if 0
	return
end

% 1. Generate XML off-ramp demand file [optional] ........................
%disp('1. Generate XML off-ramp demand file')
%tic
%write_offramp_demand_xml(xlsx_file, fr_demand_file, hov_demand_file, range);
%disp(['Done in ' num2str(toc) ' seconds.']);
end

% 2. Load basic network ..................................................
disp('2. Load basic network');
tic
ptr = BeatsSimulation;
ptr.load_scenario(cfg_starter);
disp(['Done in ' num2str(toc) ' seconds.']);

% 3. Run simulation ...................................................
disp('3. Run simulation');
tic
if sr_control
  %%%%%%%%%%%%% double run %%%%%%%%%%%%%%
  disp('  A. Run with nominal split ratios');
  system(['java -jar ' beats_jar opt_minus_s beatsprop_gp]);
  ptr.simulation_done = true;
  ptr.load_simulation_output('../beats_output/gp');

  disp('  B. Aggregate GP/HOV split ratios to 5min');
  is_5min_gp = 1;
  ptr.scenario_ptr.scenario.SplitRatioSet = compute_5min_splits_from_sim(ptr, gp_out, is_5min_gp, 0:(destination_commodities+1));
  ptr.scenario_ptr.save(cfg_gp);

  disp('  C. Run with off-ramp flows');
  system(['java -jar ' beats_jar opt_minus_s beatsprop_sr_out]);
  ptr.simulation_done = true;
  ptr.load_simulation_output('../beats_output/srout');
else
  system(['java -jar ' beats_jar opt_minus_s beatsprop_gp]);
  ptr.simulation_done = true;
  ptr.load_simulation_output('../beats_output/gp');
end
disp(['Done in ' num2str(toc) ' seconds.']);  

% 4. Put the result into Excel spreadsheet ...............................
disp('4. Put the result into Excel spreadsheet')
tic
[GP_V, GP_F, GP_D, HOV_V, HOV_F, HOV_D, ORD, ORF, FRD, FRF, ORQ, ORS] = extract_simulation_data(ptr,xlsx_file,range,no_ml_queue,ORS,destination_commodities,orgf2,orgf3,orgf4);
disp(['Done in ' num2str(toc) ' seconds.']); 

if ~sr_control | 1
  return;
end

% 5. Record split ratios ...............................
disp('5. Record split ratios')
tic
warmup_time = 0;
collect_sr(xlsx_file, range, gp_out, gp_id, hov_id, fr_id, hot_buffer, warmup_time);
disp(['Done in ' num2str(toc) ' seconds.']); 
