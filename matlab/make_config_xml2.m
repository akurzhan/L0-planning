fid = fopen(cfg_starter, 'w+');

fprintf(fid, '<?xml version="1.0" encoding="utf-8"?>\n');
fprintf(fid, '<scenario id="1" name="Auto-generated I210 scenario" schemaVersion="1.0.0">\n');
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

[gp_id, hov_id, or_id, fr_id] = write_network_xml(fid,xlsx_file, range, ORS);

write_fd_set_xml(fid, xlsx_file, range, rm_control, gp_id, hov_id, or_id, fr_id, ORS);

or_id(1) = gp_id(1);
write_demand_set_xml3(fid,sr_control, xlsx_file, range, or_id, ORS, orgf2, orgf3, orgf4,warmup_time);

write_sr_set_xml2(fid, xlsx_file, range, gp_id, hov_id, or_id, fr_id, ORS, hot_offramps,warmup_time);

% if sr_control
%   %write_sensor_set_xml(fid, xlsx_file, range, gp_id);
% 
%   a_id = write_actuator_set_xml2(fid, xlsx_file, range,gp_id, fr_id);
%   
%   write_sr_controller_set_xml(fid, fr_demand_file, a_id);
% 
%   %write_event_set_xml(fid);
% end


fprintf(fid, '</scenario>\n');
fclose(fid);
