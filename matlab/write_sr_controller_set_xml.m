function write_sr_controller_set_xml(fid, fr_demand_file, a_id)
% fid - file descriptor for the output xml
% fr_demand_file - full path to the off-ramp demand XML
% a_id - array of actuator IDs

disp('  G. Generating split ratio controller set...');


fprintf(fid, ' <ControllerSet id="1" project_id="1">\n');
fprintf(fid, '  <controller dt="5" enabled="true" id="23" name="SR_Generator" type="SR_Generator">\n');
fprintf(fid, '   <parameters><parameter name="fr_flow_file" value="%s"/></parameters>\n', fr_demand_file);
fprintf(fid, '   <target_actuators>\n');

sz = size(a_id, 2);
for i = 1:sz
  fprintf(fid, '    <target_actuator id="%d"/>\n', a_id(i));
end

fprintf(fid, '   </target_actuators>\n');
fprintf(fid, '  </controller>\n </ControllerSet>\n');


return;
