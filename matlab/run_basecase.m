clear
close all

init_config;
warmup_time = 0;

here = fileparts(mfilename('fullpath'));
root = fileparts(here);

ORS = [];

if auto_config
% 0. Generate configuration file [optional] ................................
disp('0. Generate XML configuration file')
tic
make_config_xml2;
disp(['Done in ' num2str(toc) ' seconds.']);

% % 1. Generate XML off-ramp demand file [optional] ........................
% disp('1. Generate XML off-ramp demand file')
% tic
% write_offramp_demand_xml(xlsx_file, fr_demand_file, hov_demand_file, range);
% disp(['Done in ' num2str(toc) ' seconds.']);
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
    ptr.run_beats(struct( ...
        'SCENARIO',cfg_starter,...
        'SIM_DT',5,...
        'START_TIME',0,...
        'OUTPUT_PREFIX',fullfile(beats_out_folder,'srout'),...
        'RUN_MODE','fw_fr_split_output',...
        'OUTPUT_DT',300,...
        'SPLIT_LOGGER_PREFIX',fullfile(beats_out_folder,'sr'),...
        'SPLIT_LOGGER_DT',300,...
        'JAR',beats_jar));
else
    ptr.run_beats(struct( ...
        'SCENARIO',cfg_starter,...
        'SIM_DT',5,...
        'OUTPUT_PREFIX',fullfile(beats_out_folder,'gp'),...
        'OUTPUT_DT',300,...
        'JAR',beats_jar));
end
disp(['Done in ' num2str(toc) ' seconds.']);  

% 4. Put the result into Excel spreadsheet ...............................
disp('4. Put the result into Excel spreadsheet')
tic
[GP_V, GP_F, GP_D, HOV_V, HOV_F, HOV_D, ORD, ORF, FRD, FRF, ORQ, ORS] = extract_simulation_data(ptr,xlsx_file,range,no_ml_queue,ORS,orgf2,orgf3,orgf4);
disp(['Done in ' num2str(toc) ' seconds.']); 

if ~sr_control | 0
  return;
end

% 5. Record split ratios ...............................
disp('5. Record split ratios')
tic
collect_sr(xlsx_file, range, gp_out, gp_id, hov_id, fr_id, hot_buffer);
disp(['Done in ' num2str(toc) ' seconds.']); 

plot_simulation_data

beep,beep,beep

