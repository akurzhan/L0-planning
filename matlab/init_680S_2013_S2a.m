% 680S Scenario 2a: Scenario 1 + Ramp Metering

cfg_folder       = fullfile(root,'config','680S_S2a_2013');

xlsx_file        = fullfile(cfg_folder,'I680SB_S2a.xlsx');
cfg_starter      = fullfile(cfg_folder,'680S_generated.xml');

range = [2 146];  % 680 SB

pm_dir = -1;

orgf2 = 1;

rm_control = 1;

special_onramps = 1;

