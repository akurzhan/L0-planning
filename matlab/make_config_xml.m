fid = fopen(cfg_starter, 'w+');

fprintf(fid, '<?xml version="1.0" encoding="utf-8"?>\n');
fprintf(fid, '<scenario id="1" name="Auto-generated I680 scenario" schemaVersion="1.0.0">\n');
fprintf(fid, ' <settings>\n  <units>US</units>\n </settings>\n\n');
fprintf(fid, ' <VehicleTypeSet id="1" project_id="1">\n');
fprintf(fid, '  <vehicleType id="0" name="HOV" size_factor="1"/>\n');
fprintf(fid, '  <vehicleType id="1" name="SOV" size_factor="1"/>\n');
fprintf(fid, ' </VehicleTypeSet>\n\n');


ORS = [];
if special_onramps
  ORS = xlsread(xlsx_file, 'On-Ramp_SpecialConfig');
  ORS = process_or_special_config(ORS(2:end, :));
end


[gp_id, hov_id, or_id, fr_id] = write_network_xml(fid, xlsx_file, range, ORS);

write_fd_set_xml(fid, xlsx_file, range, rm_control, gp_id, hov_id, or_id, fr_id, ORS);

write_demand_set_xml(fid, xlsx_file, range, or_id, ORS, orgf2, orgf3, orgf4);

write_sr_set_xml(fid, xlsx_file, range, gp_id, hov_id, or_id, fr_id, ORS);


if rm_control
  write_sensor_set_xml(fid, xlsx_file, range, gp_id);

  metered = write_actuator_set_xml(fid, xlsx_file, range, or_id, ORS);
  
  write_rm_controller_set_xml(fid, xlsx_file, range, gp_id, or_id, metered, ORS);

  write_event_set_xml(fid);
end


fprintf(fid, '</scenario>\n');
fclose(fid);
