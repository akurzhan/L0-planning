fid = fopen(cfg_starter, 'w+');

fprintf(fid, '<?xml version="1.0" encoding="utf-8"?>\n');
fprintf(fid, '<scenario id="1" name="Auto-generated scenario" schemaVersion="1.0.0">\n');
fprintf(fid, ' <settings>\n  <units>US</units>\n </settings>\n\n');
fprintf(fid, ' <VehicleTypeSet id="1" project_id="1">\n');
fprintf(fid, '  <vehicleType id="0" name="HOV" size_factor="1"/>\n');
fprintf(fid, '  <vehicleType id="1" name="SOV" size_factor="1"/>\n');
fprintf(fid, '  <vehicleType id="2" name="RTP" size_factor="1"/>\n');
for i = 1:destination_commodities
  fprintf(fid, '  <vehicleType id="%d" name="Destination%d" size_factor="1"/>\n', 2+i, i);
end
fprintf(fid, ' </VehicleTypeSet>\n\n');


ORS = [];
if special_onramps
  ORS = xlsread(xlsx_file, 'On-Ramp_SpecialConfig');
  ORS = process_or_special_config(ORS(2:end, :));
end

[gp_id, hov_id, or_id, fr_id] = write_network_xml(fid,xlsx_file, range, ORS);

write_fd_set_xml(fid, xlsx_file, range, rm_control, gp_id, hov_id, or_id, fr_id, ORS);

or_id(1) = gp_id(1);
write_demand_set_hot_xml(fid,sr_control, xlsx_file, range, or_id, ORS, destination_commodities, orgf2, orgf3, orgf4, warmup_time);

[nodes, gates] = write_sr_set_hot_xml(fid, xlsx_file, range, gp_id, hov_id, or_id, fr_id, ORS, hot_offramps, destination_commodities, warmup_time);

fprintf(fid, ' <ControllerSet id="1" project_id="1">\n');
if destination_commodities > 0
  write_commodity_controllers(fid, xlsx_file, range, gp_id, hov_id, fr_id, nodes, gates);
end

hot_ctrl_fid = fopen('10W_HOT_Controller.xml');
tline = fgetl(hot_ctrl_fid);
while ischar(tline)
  fprintf(fid, '%s\n', tline);
  tline = fgetl(hot_ctrl_fid);
end
fclose(hot_ctrl_fid);

fprintf(fid, ' </ControllerSet>\n\n');


fprintf(fid, '</scenario>\n');
fclose(fid);
