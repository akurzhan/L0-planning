function write_commodity_controller_set(fid, xlsx_file, range, gp_id, hov_id, fr_id, nodes, gates)
% fid - file descriptor for the output xml
% xlsx_file - full path to the configuration spreadsheet
% range - row range to be read from the spreadsheet
% gp_id - array of GP link IDs
% hov_id - array of HOV/T link IDs
% fr_id - array of off-ramp link IDs
% nodes - array of node IDs
% gates - array of gate indicators: each nonzero entry represents
%         number of srved off-ramps

disp('  G. Generating commodity swap controller set...');

sz = range(2) - range(1) + 1;

fprintf(fid, ' <ControllerSet id="1" project_id="1">\n');

for i = 2:sz
  if gates(i) > 0
    fprintf(fid, '  <controller dt="5" enabled="true" id="%d" type="Vehicle_Type_Swapper">\n', nodes(i-1));
    fprintf(fid, '   <parameters><parameter name="link_id" value="%d"/></parameters>\n', hov_id(i-1));
    
    j = i + 1;
    cnt = 0;
    while (gates(j) == 0) & (j < sz)
      if fr_id(j) ~= 0
        cnt = cnt + 1;
        fprintf(fid, '   <switchRatio vehicle_type_in="0" vehicle_type_out="%d" reference_inlink="%d" reference_outlink="%d" reference_vehtype="1"></switchRatio>\n', (cnt+1), gp_id(j-1), fr_id(j));
      end
      j = j + 1;
    end
    
    fprintf(fid, '  </controller>\n');
  end
end


fprintf(fid, ' </ControllerSet>\n\n');

return;
