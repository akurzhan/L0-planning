% 680N Scenario 3: Scenario 2b + SR-4 Interconnect modification

cfg_folder       = fullfile(root,'config','680N_S3_2013');

xlsx_file        = fullfile(cfg_folder,'I680NB_S3.xlsx');
cfg_starter      = fullfile(cfg_folder,'680N_generated.xml');

range = [2 149];  % 680 NB

pm_dir = 1;

orgf2 = 0;

rm_control = 1;

hot_offramps = 1;

special_onramps = 1;
