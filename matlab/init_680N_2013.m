
cfg_folder = fullfile(root,'config','680N');

xlsx_file        = fullfile(cfg_folder,'I680NB_Data.xlsx');
cfg_starter      = fullfile(cfg_folder,'680N_generated.xml');
sr_initial_guess = fullfile(cfg_folder,'680N_sr.xml');

range = [2 149];  % 680 NB

hov_prct = 0.15;

sr_control = 1;

pm_dir = 1;

