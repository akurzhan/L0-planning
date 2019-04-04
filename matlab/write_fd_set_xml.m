function write_fd_set_xml(fid, xlsx_file, range, rm_control, gp_id, hov_id, or_id, fr_id, ORS)
% fid - file descriptor for the output xml
% xlsx_file - full path to the configuration spreadsheet
% range - row range to be read from the spreadsheet
% rm_control - flag indicating that ramp metering is on
% gp_id - array of GP link IDs
% hov_id - array of HOV link IDs
% or_id - array of on-ramp link IDs
% fr_id - array of off-ramp link IDs
% ORS - configuration table for specially treated on-ramps

disp('  B. Generating fundamental diagram set...');


% Fundamental diagram parameters
gp_cap = xlsread(xlsx_file, 'Configuration', sprintf('k%d:k%d', range(1), range(2)))';
hov_cap = xlsread(xlsx_file, 'Configuration', sprintf('l%d:l%d', range(1), range(2)))';
V = xlsread(xlsx_file, 'Configuration', sprintf('m%d:m%d', range(1), range(2)))';
W = xlsread(xlsx_file, 'Configuration', sprintf('n%d:n%d', range(1), range(2)))';

sz = range(2) - range(1) + 1;
add_cap = 50*rm_control;
add_cap = 0;


fprintf(fid, ' <FundamentalDiagramSet id="1" project_id="1">\n');
for i = 1:sz
  if ~rm_control
    fprintf(fid, '   <fundamentalDiagramProfile id="%d" link_id="%d">\n', gp_id(i), gp_id(i));
    fprintf(fid, '    <fundamentalDiagram id="0" capacity="%d" free_flow_speed="%d" congestion_speed="%d"/>\n', gp_cap(i), V(i), W(i));
  else
    fprintf(fid, '   <fundamentalDiagramProfile id="%d" link_id="%d" dt="3600" start_time="0">\n', gp_id(i), gp_id(i));
    for j = 1:6
      fprintf(fid, '    <fundamentalDiagram id="0" capacity="%d" free_flow_speed="%d" congestion_speed="%d"/>\n', gp_cap(i), V(i), W(i));
    end
    for j = 7:9
      fprintf(fid, '    <fundamentalDiagram id="0" capacity="%d" free_flow_speed="%d" congestion_speed="%d"/>\n', gp_cap(i)+add_cap, V(i), W(i));
    end
    for j = 10:15
      fprintf(fid, '    <fundamentalDiagram id="0" capacity="%d" free_flow_speed="%d" congestion_speed="%d"/>\n', gp_cap(i), V(i), W(i));
    end
    for j = 16:19
      fprintf(fid, '    <fundamentalDiagram id="0" capacity="%d" free_flow_speed="%d" congestion_speed="%d"/>\n', gp_cap(i)+add_cap, V(i), W(i));
    end
    for j = 20:24
      fprintf(fid, '    <fundamentalDiagram id="0" capacity="%d" free_flow_speed="%d" congestion_speed="%d"/>\n', gp_cap(i), V(i), W(i));
    end
  end
  fprintf(fid, '   </fundamentalDiagramProfile>\n');

  %gcap = gp_cap(i);
  gcap = hov_cap(i);
  hcap = hov_cap(i);
  if hov_id(i) ~= 0
    fprintf(fid, '   <fundamentalDiagramProfile id="%d" link_id="%d" dt="3600" start_time="0">\n', hov_id(i), hov_id(i));
    for j = 1:5
      fprintf(fid, '    <fundamentalDiagram id="0" capacity="%d" free_flow_speed="%d" congestion_speed="%d"/>\n', gcap, V(i), W(i));
    end
    fprintf(fid, '    <fundamentalDiagram id="0" capacity="%d" free_flow_speed="%d" congestion_speed="%d"/>\n', hcap, V(i), W(i));
    for j = 7:9
      fprintf(fid, '    <fundamentalDiagram id="0" capacity="%d" free_flow_speed="%d" congestion_speed="%d"/>\n', hcap+add_cap, V(i), W(i));
    end
    for j = 10:15
      fprintf(fid, '    <fundamentalDiagram id="0" capacity="%d" free_flow_speed="%d" congestion_speed="%d"/>\n', gcap, V(i), W(i));
    end
    for j = 16:19
      fprintf(fid, '    <fundamentalDiagram id="0" capacity="%d" free_flow_speed="%d" congestion_speed="%d"/>\n', hcap+add_cap, V(i), W(i));
    end
    for j = 20:24
      fprintf(fid, '    <fundamentalDiagram id="0" capacity="%d" free_flow_speed="%d" congestion_speed="%d"/>\n', gcap, V(i), W(i));
    end
    fprintf(fid, '   </fundamentalDiagramProfile>\n');
  end
  if (or_id(i) ~= 0) & (i > 2)
    ors = find_or_struct(ORS, or_id(i));
    if isempty(ors)
      fprintf(fid, '   <fundamentalDiagramProfile id="%d" link_id="%d">\n', or_id(i), or_id(i));
      fprintf(fid, '    <fundamentalDiagram id="0" capacity="1500" free_flow_speed="65" congestion_speed="10"/>\n');
      fprintf(fid, '   </fundamentalDiagramProfile>\n');
    else
      if isempty(ors.feeders)
        in_count = size(ors.peers, 2);
        for j = 1:in_count
          fprintf(fid, '   <fundamentalDiagramProfile id="%d" link_id="%d">\n', ors.peers(j), ors.peers(j));
          fprintf(fid, '    <fundamentalDiagram id="0" capacity="1500" free_flow_speed="65" congestion_speed="10"/>\n');
          fprintf(fid, '   </fundamentalDiagramProfile>\n');
        end
      else
        in_count = size(ors.feeders, 2);
        for j = 1:in_count
          fprintf(fid, '   <fundamentalDiagramProfile id="%d" link_id="%d">\n', ors.feeders(j), ors.feeders(j));
          fprintf(fid, '    <fundamentalDiagram id="0" capacity="1500" free_flow_speed="65" congestion_speed="10"/>\n');
          fprintf(fid, '   </fundamentalDiagramProfile>\n');
        end
        fprintf(fid, '   <fundamentalDiagramProfile id="%d" link_id="%d">\n', ors.id, ors.id);
        fprintf(fid, '    <fundamentalDiagram id="0" capacity="1500" free_flow_speed="65" congestion_speed="10"/>\n');
        fprintf(fid, '   </fundamentalDiagramProfile>\n');
      end
    end
  end
  if fr_id(i) ~= 0
    fprintf(fid, '   <fundamentalDiagramProfile id="%d" link_id="%d">\n', fr_id(i), fr_id(i));
    fprintf(fid, '    <fundamentalDiagram id="0" capacity="1500" free_flow_speed="65" congestion_speed="10"/>\n');
    fprintf(fid, '   </fundamentalDiagramProfile>\n');
  end
end


fprintf(fid, ' </FundamentalDiagramSet>\n\n');

return;
