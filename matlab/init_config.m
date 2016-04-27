
root = fileparts(fileparts(mfilename('fullpath')));
beats_jar = fullfile(fileparts(root), 'beats', 'target', 'beats-0.1-SNAPSHOT-jar-with-dependencies.jar');

auto_sr = 0;
auto_config = 1;
rm_control = 0;
sr_control = 0;
hov_control = 0;
no_ml_queue = 1;
special_onramps = 0;
hot_offramps = 0;
hot_buffer = 0;


orgf2 = 0;
orgf3 = 0;
orgf4 = 0;

destination_commodities = 0;

%init_210E
init_210E_HOT
%init_210W

%init_680N_2013
%init_680S_2013

%init_680N_rm_override_2013
%init_680S_rm_override_2013
%init_680N_rm_nooverride_2013
%init_680S_rm_nooverride_2013

%init_680N_2013_S1_0
%init_680S_2013_S1_0
%init_680N_2013_S1
%init_680S_2013_S1

%init_680N_2013_S2a
%init_680S_2013_S2a

%init_680N_2013_S2b
%init_680S_2013_S2b

%init_680N_2013_S3
%init_680S_2013_S3

%init_680N_2013_S4
%init_680S_2013_S4

%init_680N_S4_Incident




%init_680N_2025
%init_680S_2025

%init_680N_2025_S1_0
%init_680S_2025_S1_0
%init_680N_2025_S1
%init_680S_2025_S1

%init_680N_2025_S2a
%init_680S_2025_S2a

%init_680N_2025_S2b
%init_680S_2025_S2b

%init_680N_2025_S3
%init_680S_2025_S3

%init_680N_2025_S4
%init_680S_2025_S4

%init_680N_rm_override_2025
%init_680S_rm_override_2025
%init_680N_rm_nooverride_2025
%init_680S_rm_nooverride_2025






%init_680N_2030
%init_680S_2030

beats_out_folder = fullfile(root,'beats_output');
cfg_gen_folder = fullfile(cfg_folder,'generated');

beatsprop_gp     = fullfile(cfg_folder,'beats_gp_5min.properties');
beatsprop_gp0     = fullfile(cfg_folder,'beats_gp_5min_0.properties');
beatsprop_sr_out = fullfile(cfg_folder,'beats_srout.properties');
act_cntrl        = fullfile(cfg_folder,'actuators_and_controllers.xml');
cfg_gp           = fullfile(cfg_folder,'generated2.xml');
cfg_srout        = fullfile(cfg_gen_folder,'srout.xml');
fr_demand_file   = fullfile(cfg_gen_folder,'fr_demand.xml');
hov_demand_file   = fullfile(cfg_gen_folder,'hov_demand.xml');
gp_out           = fullfile(beats_out_folder,'sr');
ppt_report_file  = fullfile(cfg_gen_folder,'compare_fr_flows');

opt_minus_s = ' -s ';
%opt_minus_s = ' ';

warmup_time = 0;


