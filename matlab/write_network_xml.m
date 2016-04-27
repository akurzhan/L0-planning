function [gp_id, hov_id, or_id, fr_id] = write_network_xml(fid, xlsx_file, range, ORS)
% fid - file descriptor for the output xml
% xlsx_file - full path to the configuration spreadsheet
% range - row range to be read from the spreadsheet
% ORS - configuration table for specially treated on-ramps
%
% gp_id - array of GP link IDs
% hov_id - array of HOV link IDs
% or_id - array of on-ramp link IDs
% fr_id - array of off-ramp link IDs

disp('  A. Generating road network...');

aux_const = 0.47368421052632;

% Link IDs
gp_id = xlsread(xlsx_file, 'Configuration', sprintf('a%d:a%d', range(1), range(2)))';
hov_id = xlsread(xlsx_file, 'Configuration', sprintf('b%d:b%d', range(1), range(2)))';
or_id = xlsread(xlsx_file, 'Configuration', sprintf('o%d:o%d', range(1), range(2)))';
fr_id = xlsread(xlsx_file, 'Configuration', sprintf('v%d:v%d', range(1), range(2)))';
nodes = xlsread(xlsx_file, 'Configuration', sprintf('y%d:y%d', range(1), range(2)))';
gates = xlsread(xlsx_file, 'Configuration', sprintf('c%d:c%d', range(1), range(2)))';

% Lanes
aux_lanes = xlsread(xlsx_file, 'Configuration', sprintf('h%d:h%d', range(1), range(2)))';
gp_lanes = xlsread(xlsx_file, 'Configuration', sprintf('i%d:i%d', range(1), range(2)))';
hov_lanes = xlsread(xlsx_file, 'Configuration', sprintf('j%d:j%d', range(1), range(2)))';
or_lanes = xlsread(xlsx_file, 'Configuration', sprintf('p%d:p%d', range(1), range(2)))';
fr_lanes = xlsread(xlsx_file, 'Configuration', sprintf('w%d:w%d', range(1), range(2)))';

% Length
llen = xlsread(xlsx_file, 'Configuration', sprintf('e%d:e%d', range(1), range(2)))';

sz = range(2) - range(1) + 1;
last_node_id = 10000 + gp_id(sz);
last_node_id2 = -10000 - hov_id(sz);

fprintf(fid, ' <NetworkSet id="1" project_id="1">\n');
fprintf(fid, '  <network id="1" name="Auto-generated network">\n');
fprintf(fid, '   <description>Generated from %s at %s</description>\n', xlsx_file, datestr(now));
fprintf(fid, '   <position>\n'); 
fprintf(fid, '    <point elevation="0" lat="0" lng="0"/>\n'); 
fprintf(fid, '   </position>\n');

% Node list
fprintf(fid, '   <NodeList>\n');
% First terminal node
write_node_xml(fid, gp_id(1), 1, [], gp_id(1));
for i = 2:sz
  in_links = gp_id(i-1);
  if hov_id(i-1) ~= 0
    in_links = [in_links hov_id(i-1)];
  end
  if (or_id(i) ~= 0) & (i > 2)
    ors = find_or_struct(ORS, or_id(i));
    if isempty(ors)
      in_links = [in_links or_id(i)];
      write_node_xml(fid, or_id(i), 1, [], or_id(i)); % on-ramp terminal
    else
      if isempty(ors.feeders)
        in_links = [in_links ors.peers];
        in_count = size(ors.peers, 2); 
        for j = 1:in_count
          write_node_xml(fid, ors.peers(j), 1, [], ors.peers(j)); % on-ramp terminal
        end
      else
        in_links = [in_links or_id(i)];
        in_count = size(ors.feeders, 2); 
        for j = 1:in_count
          write_node_xml(fid, ors.feeders(j), 1, [], ors.feeders(j)); % on-ramp terminal
        end
        write_node_xml(fid, ors.id, 1, ors.feeders, ors.id); % internal node
      end
    end
  end
  out_links = gp_id(i);
  if hov_id(i) ~= 0
    out_links = [out_links hov_id(i)];
  end
  if fr_id(i) ~= 0
    out_links = [out_links fr_id(i)];
    write_node_xml(fid, fr_id(i), 1, fr_id(i), []); % off-ramp terminal
  end
  %write_node_xml(fid, gp_id(i), in_links, out_links); % internal node
  write_node_xml(fid, nodes(i-1), gates(i), in_links, out_links); % internal node
end
% Last terminal node
write_node_xml(fid, last_node_id, 1, gp_id(sz), []);
if hov_id(sz) ~= 0
  write_node_xml(fid, last_node_id2, 1, hov_id(sz), []);
end
fprintf(fid, '   </NodeList>\n');

% Link list
fprintf(fid, '   <LinkList>\n');
for i = 1:(sz-1)
  %write_link_xml(fid, gp_id(i), '<link_type id="1" name="Freeway"/>', gp_lanes(i) + aux_const*aux_lanes(i), llen(i), gp_id(i), gp_id(i+1));
  %if hov_id(i) ~= 0
  %  write_link_xml(fid, hov_id(i), '<link_type id="6" name="HOV"/>', hov_lanes(i), llen(i), gp_id(i), gp_id(i+1));
  %end
  if i==1
    write_link_xml(fid, gp_id(i), '<link_type id="1" name="Freeway"/>', gp_lanes(i) + aux_const*aux_lanes(i), llen(i), gp_id(i), nodes(i));
    if hov_id(i) ~= 0
      write_link_xml(fid, hov_id(i), '<link_type id="6" name="HOV"/>', hov_lanes(i), llen(i), gp_id(i), nodes(i));
    end
  else
    write_link_xml(fid, gp_id(i), '<link_type id="1" name="Freeway"/>', gp_lanes(i) + aux_const*aux_lanes(i), llen(i), nodes(i-1), nodes(i));
    if hov_id(i) ~= 0
      write_link_xml(fid, hov_id(i), '<link_type id="6" name="HOV"/>', hov_lanes(i), llen(i), nodes(i-1), nodes(i));
    end
  end
  if (or_id(i) ~= 0) & (i > 2)
    ors = find_or_struct(ORS, or_id(i));
    if isempty(ors)
      %write_link_xml(fid, or_id(i), '<link_type id="3" name="On-Ramp"/>', or_lanes(i), 0.2, or_id(i), gp_id(i));
      write_link_xml(fid, or_id(i), '<link_type id="3" name="On-Ramp"/>', or_lanes(i), 0.2, or_id(i), nodes(i-1));
    else
      if isempty(ors.feeders)
        in_count = size(ors.peers, 2); 
        for j = 1:in_count
          write_link_xml(fid, ors.peers(j), '<link_type id="3" name="On-Ramp"/>', ors.peer_lanes(j), 0.2, ors.peers(j), gp_id(i));
        end
      else
        in_count = size(ors.feeders, 2); 
        for j = 1:in_count
          write_link_xml(fid, ors.feeders(j), '<link_type id="3" name="On-Ramp"/>', ors.feeder_lanes(j), 0.2, ors.feeders(j), ors.id);
        end
        write_link_xml(fid, ors.id, '<link_type id="3" name="On-Ramp"/>', ors.merge_lanes, ors.merge_length, ors.id, gp_id(i)); % merge link
      end
    end
  end
  if fr_id(i) ~= 0
    %write_link_xml(fid, fr_id(i), '<link_type id="4" name="Off-Ramp"/>', fr_lanes(i), 0.2, gp_id(i), fr_id(i));
    write_link_xml(fid, fr_id(i), '<link_type id="4" name="Off-Ramp"/>', fr_lanes(i), 0.2, nodes(i-1), fr_id(i));
  end
end
% Last link
%write_link_xml(fid, gp_id(sz), '<link_type id="1" name="Freeway"/>', gp_lanes(sz) + aux_const*aux_lanes(i), llen(i), gp_id(sz), last_node_id);
%if hov_id(sz) ~= 0
%  write_link_xml(fid, hov_id(sz), '<link_type id="6" name="HOV"/>', hov_lanes(sz), llen(i), gp_id(sz), last_node_id2);
%end
write_link_xml(fid, gp_id(sz), '<link_type id="1" name="Freeway"/>', gp_lanes(sz) + aux_const*aux_lanes(i), llen(i), nodes(sz-1), last_node_id);
if hov_id(sz) ~= 0
  write_link_xml(fid, hov_id(sz), '<link_type id="6" name="HOV"/>', hov_lanes(sz), llen(i), nodes(sz-1), last_node_id2);
end
if or_id(sz) ~= 0
  write_link_xml(fid, or_id(sz), '<link_type id="3" name="On-Ramp"/>', or_lanes(sz), 0.2, or_id(sz), gp_id(sz));
end
fprintf(fid, '   </LinkList>\n');

fprintf(fid, '  </network>\n');
fprintf(fid, ' </NetworkSet>\n\n');

return;









function write_node_xml(fid, node_id, gate, in_links, out_links)
% fid - file descriptor for output XML
% node_id - node ID
% in_links - array of input links
% out_links - array of output links

if gate == 0
  fprintf(fid, '    <node id="%d" has_managed_lane_barrier="true">\n', node_id);
else
  fprintf(fid, '    <node id="%d">\n', node_id);
end

if isempty(in_links) | isempty(out_links)
  fprintf(fid, '     <node_type id="0" name="terminal"/>\n');
else
  fprintf(fid, '     <node_type id="4" name="simple"/>\n');
end

sz = size(in_links, 2);
if sz > 0
  fprintf(fid, '     <inputs>\n');
  for i = 1:sz
    fprintf(fid, '      <input link_id="%d"/>\n', in_links(i));
  end
  fprintf(fid, '     </inputs>\n');
else
  fprintf(fid, '     <inputs/>\n');
end

sz = size(out_links, 2);
if sz > 0
  fprintf(fid, '     <outputs>\n');
  for i = 1:sz
    fprintf(fid, '      <output link_id="%d"/>\n', out_links(i));
  end
  fprintf(fid, '     </outputs>\n');
else
  fprintf(fid, '     <outputs/>\n');
end

fprintf(fid, '     <position>\n');
fprintf(fid, '      <point elevation="0" lat="0" lng="0"/>\n');
fprintf(fid, '     </position>\n');

fprintf(fid, '    </node>\n');

return;






function write_link_xml(fid, link_id, type_str, lanes, llen, bnid, enid)
% fid - file descriptor of the output XML
% link_id - link ID
% type_str - XML string describing link type
% lanes - number of lanes
% llen - link length
% bnid - begin node ID
% enid - end node ID

if lanes == floor(lanes)
  fprintf(fid, '    <link id="%d" lanes="%d" length="%f">\n', link_id, lanes, llen);
else
  fprintf(fid, '    <link id="%d" lanes="%f" length="%f">\n', link_id, lanes, llen);
end
fprintf(fid, '     <begin node_id="%d"/>\n', bnid);
fprintf(fid, '     <end node_id="%d"/>\n', enid);
fprintf(fid, '     %s\n', type_str);
fprintf(fid, '    </link>\n');

return;




