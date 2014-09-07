
cfg_folder = fullfile(root,'config','680S_+RM_2025');

xlsx_file        = fullfile(cfg_folder,'I680SB_override.xlsx');
cfg_starter      = fullfile(cfg_folder,'680S_nooverride.xml');
sr_initial_guess = fullfile(cfg_folder,'680S_sr.xml');

range = [2 147];  % 680 SB

hov_prct = 0.135;

pm_dir = -1;
