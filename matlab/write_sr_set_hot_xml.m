function [nodes, gates] = write_sr_set_hot_xml(fid, xlsx_file, range, gp_id, hov_id, or_id, fr_id, ORS, hot_offramps, dc, warmup_time)
% fid - file descriptor for the output xml
% xlsx_file - full path to the configuration spreadsheet
% range - row range to be read from the spreadsheet
% gp_id - array of GP link IDs
% hov_id - array of HOV link IDs
% or_id - array of on-ramp link IDs
% fr_id - array of off-ramp link IDs
% ORS - configuration table for specially treated on-ramps
% dc - number of destination commodities

disp('  D. Generating split ratio set...');

warmup_steps = round(warmup_time/300);

% Link IDs
gates = xlsread(xlsx_file, 'Configuration', sprintf('c%d:c%d', range(1), range(2)))';
% nodes = gp_id;
nodes = xlsread(xlsx_file, 'Configuration', sprintf('y%d:y%d', range(1), range(2)))';
SR = xlsread(xlsx_file, 'Off-Ramp_SplitRatios', sprintf('k%d:kl%d', range(1), range(2)));
SR = [repmat(SR(:,1),1,warmup_steps) SR];

if hot_offramps
    HSR = xlsread(xlsx_file, 'HOT_Off-Ramp_SplitRatios', sprintf('k%d:kl%d', range(1), range(2)));
    HSR = [repmat(HSR(:,1),1,warmup_steps) HSR];
else
    HSR = SR;
end

FRGF = xlsread(xlsx_file, 'Off-Ramp_GrowthFactors', sprintf('k%d:kl%d', range(1), range(2)));
FRGF = [repmat(FRGF(:,1),1,warmup_steps) FRGF];
%SR = SR .* FRGF;
[m, n] = size(SR);
SR = min(SR, ones(m, n));


sz = range(2) - range(1) + 1;

fprintf(fid, ' <SplitRatioSet id="1" project_id="1">\n');

for i = 2:sz
    if (hov_id(i) ~= 0) | (fr_id(i) ~= 0)
        write_sr_profile_xml(fid, nodes, gp_id, hov_id, or_id, fr_id, SR, HSR, ORS, gates, i, dc, warmup_time);
    end
end

fprintf(fid, ' </SplitRatioSet>\n\n');

return;






function write_sr_profile_xml(fid, nd_id, gp_id, hov_id, or_id, fr_id, srp, hsrp, ORS, gates, idx, dc, warmup_time)
% fid - file descriptor for the output xml
% gp_id - GP link IDs
% hov_id - HOV link IDs
% or_id - on-ramp IDs
% fr_id - off-ramp IDs
% srp - array of off-ramp split ratios
% hsrp - array of off-ramp split ratios for HOT traffic
% ORS - configuration table for specially treated on-ramps

%if size(srp, 2) < 288
%    srp(288) = 0;
%end
%if size(hsrp, 2) < 288
%    hsrp(288) = 0;
%end

sov_sr_buf = '-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1';


fprintf(fid, '   <splitRatioProfile id="%d" node_id="%d" dt="300" start_time="%d">\n', nd_id(idx-1), nd_id(idx-1), -warmup_time);

for i = 0:(dc+2)
  fprintf(fid, '    <splitratio vehicle_type_id="%d" link_in="%d" link_out="%d">-1</splitratio>\n', i, gp_id(idx-1), gp_id(idx));
end

if hov_id(idx) ~= 0   % HOV output exists
  if dc == 0
    fprintf(fid, '    <splitratio vehicle_type_id="0" link_in="%d" link_out="%d">-1</splitratio>\n', gp_id(idx-1), hov_id(idx));
    fprintf(fid, '    <splitratio vehicle_type_id="1" link_in="%d" link_out="%d">%s</splitratio>\n', gp_id(idx-1), hov_id(idx), sov_sr_buf);
    fprintf(fid, '    <splitratio vehicle_type_id="2" link_in="%d" link_out="%d">-1</splitratio>\n', gp_id(idx-1), hov_id(idx));
  else
    fprintf(fid, '    <splitratio vehicle_type_id="0" link_in="%d" link_out="%d">%d</splitratio>\n', gp_id(idx-1), hov_id(idx), -sign(gates(idx)));
    fprintf(fid, '    <splitratio vehicle_type_id="1" link_in="%d" link_out="%d">0</splitratio>\n', gp_id(idx-1), hov_id(idx));
    fprintf(fid, '    <splitratio vehicle_type_id="2" link_in="%d" link_out="%d">%d</splitratio>\n', gp_id(idx-1), hov_id(idx), -sign(gates(idx)));
    for i = 3:(dc+2)
      fprintf(fid, '    <splitratio vehicle_type_id="%d" link_in="%d" link_out="%d">0</splitratio>\n', i, gp_id(idx-1), hov_id(idx));
    end
  end
end

if fr_id(idx) ~= 0   % Off-ramp exists
  fprintf(fid, '    <splitratio vehicle_type_id="0" link_in="%d" link_out="%d">%s</splitratio>\n', gp_id(idx-1), fr_id(idx), form_buffer(srp(idx, :)));
  fprintf(fid, '    <splitratio vehicle_type_id="1" link_in="%d" link_out="%d">%s</splitratio>\n', gp_id(idx-1), fr_id(idx), form_buffer(srp(idx, :)));
  fprintf(fid, '    <splitratio vehicle_type_id="2" link_in="%d" link_out="%d">%s</splitratio>\n', gp_id(idx-1), fr_id(idx), form_buffer(srp(idx, :)));
  if dc > 0
    fr_num = get_offramp_seqno(fr_id, gates, idx) + 1;  % get off-ramp number after the gate
    for i = 3:(dc+2)
      fprintf(fid, '    <splitratio vehicle_type_id="%d" link_in="%d" link_out="%d">%d</splitratio>\n', i, gp_id(idx-1), fr_id(idx), (fr_num == i));
    end
  end
end


if hov_id(idx-1) ~= 0   % HOV input exists
  if dc == 0
    fprintf(fid, '    <splitratio vehicle_type_id="0" link_in="%d" link_out="%d">-1</splitratio>\n', hov_id(idx-1), gp_id(idx));
    fprintf(fid, '    <splitratio vehicle_type_id="1" link_in="%d" link_out="%d">-1</splitratio>\n', hov_id(idx-1), gp_id(idx));
    fprintf(fid, '    <splitratio vehicle_type_id="2" link_in="%d" link_out="%d">-1</splitratio>\n', hov_id(idx-1), gp_id(idx));
  else
    for i = 0:(dc+2)
      fprintf(fid, '    <splitratio vehicle_type_id="%d" link_in="%d" link_out="%d">%d</splitratio>\n', i, hov_id(idx-1), gp_id(idx), -sign(gates(idx)));
    end
  end
    
    if hov_id(idx) ~= 0   % HOV output exists
      if dc == 0
        fprintf(fid, '    <splitratio vehicle_type_id="0" link_in="%d" link_out="%d">-1</splitratio>\n', hov_id(idx-1), hov_id(idx));
        fprintf(fid, '    <splitratio vehicle_type_id="1" link_in="%d" link_out="%d">%s</splitratio>\n', hov_id(idx-1), hov_id(idx), sov_sr_buf);
        fprintf(fid, '    <splitratio vehicle_type_id="2" link_in="%d" link_out="%d">-1</splitratio>\n', hov_id(idx-1), hov_id(idx));
      else
        fprintf(fid, '    <splitratio vehicle_type_id="0" link_in="%d" link_out="%d">-1</splitratio>\n', hov_id(idx-1), hov_id(idx));
        fprintf(fid, '    <splitratio vehicle_type_id="1" link_in="%d" link_out="%d">%d</splitratio>\n', hov_id(idx-1), hov_id(idx), sign(gates(idx))-1);
        fprintf(fid, '    <splitratio vehicle_type_id="2" link_in="%d" link_out="%d">-1</splitratio>\n', hov_id(idx-1), hov_id(idx));
        for i = 3:(dc+2)
          fprintf(fid, '    <splitratio vehicle_type_id="%d" link_in="%d" link_out="%d">%d</splitratio>\n', i, hov_id(idx-1), hov_id(idx), sign(gates(idx))-1);
        end
      end
    end
    
    if fr_id(idx) ~= 0   % Off-ramp exists
      if dc == 0
        fprintf(fid, '    <splitratio vehicle_type_id="0" link_in="%d" link_out="%d">%s</splitratio>\n', hov_id(idx-1), fr_id(idx), form_buffer(hsrp(idx, :)));
        fprintf(fid, '    <splitratio vehicle_type_id="1" link_in="%d" link_out="%d">%s</splitratio>\n', hov_id(idx-1), fr_id(idx), form_buffer(hsrp(idx, :)));
        fprintf(fid, '    <splitratio vehicle_type_id="2" link_in="%d" link_out="%d">%s</splitratio>\n', hov_id(idx-1), fr_id(idx), form_buffer(hsrp(idx, :)));
      else
        for i = 0:(dc+2)
          fprintf(fid, '    <splitratio vehicle_type_id="%d" link_in="%d" link_out="%d">0</splitratio>\n', i, hov_id(idx-1), fr_id(idx));
        end
      end
    end
end


if or_id(idx) ~= 0   % On-ramp exists
    ors = find_or_struct(ORS, or_id);
    if isempty(ors) | isempty(ors.peers)
      if dc == 0
        fprintf(fid, '    <splitratio vehicle_type_id="0" link_in="%d" link_out="%d">-1</splitratio>\n', or_id(idx), gp_id(idx));
        fprintf(fid, '    <splitratio vehicle_type_id="1" link_in="%d" link_out="%d">-1</splitratio>\n', or_id(idx), gp_id(idx));
        fprintf(fid, '    <splitratio vehicle_type_id="2" link_in="%d" link_out="%d">-1</splitratio>\n', or_id(idx), gp_id(idx));
      else
        for i = 0:(dc+2)
          fprintf(fid, '    <splitratio vehicle_type_id="%d" link_in="%d" link_out="%d">-1</splitratio>\n', i, or_id(idx), gp_id(idx));
        end
      end
        
        if hov_id(idx) ~= 0   % HOV output exists
          if dc == 0
            fprintf(fid, '    <splitratio vehicle_type_id="0" link_in="%d" link_out="%d">-1</splitratio>\n', or_id(idx), hov_id(idx));
            fprintf(fid, '    <splitratio vehicle_type_id="1" link_in="%d" link_out="%d">%s</splitratio>\n', or_id(idx), hov_id(idx), sov_sr_buf);
            fprintf(fid, '    <splitratio vehicle_type_id="2" link_in="%d" link_out="%d">-1</splitratio>\n', or_id(idx), hov_id(idx));
          else
            fprintf(fid, '    <splitratio vehicle_type_id="0" link_in="%d" link_out="%d">%d</splitratio>\n', or_id(idx), hov_id(idx), -sign(gates(idx)));
            fprintf(fid, '    <splitratio vehicle_type_id="1" link_in="%d" link_out="%d">0</splitratio>\n', or_id(idx), hov_id(idx));
            fprintf(fid, '    <splitratio vehicle_type_id="2" link_in="%d" link_out="%d">%d</splitratio>\n', or_id(idx), hov_id(idx), -sign(gates(idx)));
            for i = 3:(dc+2)
              fprintf(fid, '    <splitratio vehicle_type_id="%d" link_in="%d" link_out="%d">0</splitratio>\n', i, or_id(idx), hov_id(idx));
            end
          end
        end
        
        if fr_id ~= 0   % Off-ramp exists
          for i = 0:(dc+2)
            fprintf(fid, '    <splitratio vehicle_type_id="%d" link_in="%d" link_out="%d">0</splitratio>\n', i, or_id(idx), fr_id(idx));
          end
        end
    else
	%TODO
        if isempty(ors.feeders)
            in_count = size(ors.peers, 2);
            for j = 1:in_count
                fprintf(fid, '    <splitratio vehicle_type_id="0" link_in="%d" link_out="%d">-1</splitratio>\n', ors.peers(j), gp_id(idx));
                fprintf(fid, '    <splitratio vehicle_type_id="1" link_in="%d" link_out="%d">-1</splitratio>\n', ors.peers(j), gp_id(idx));
                
                if hov_id(idx) ~= 0   % HOV output exists
                    fprintf(fid, '    <splitratio vehicle_type_id="0" link_in="%d" link_out="%d">-1</splitratio>\n', ors.peers(j), hov_id(idx));
                    fprintf(fid, '    <splitratio vehicle_type_id="1" link_in="%d" link_out="%d">%s</splitratio>\n', ors.peers(j), hov_id(idx), sov_sr_buf);
                end
                
                if fr_id(idx) ~= 0   % Off-ramp exists
                    fprintf(fid, '    <splitratio vehicle_type_id="0" link_in="%d" link_out="%d">0</splitratio>\n', ors.peers(j), fr_id(idx));
                    fprintf(fid, '    <splitratio vehicle_type_id="1" link_in="%d" link_out="%d">0</splitratio>\n', ors.peers(j), fr_id(idx));
                end
            end
        end
    end
end


fprintf(fid, '   </splitRatioProfile>\n');

return;




function buf = form_buffer(sr)
% sr - split ratio array

sz = size(sr, 2);

buf = '';

for i = 1:sz
    if i > 1
        buf = sprintf('%s,', buf);
    end
    buf = sprintf('%s%f', buf, sr(i));
end

return;










function cnt = get_offramp_seqno(fr_id, gates, idx)
% fr_id - off-ramp IDs
% gates - array, where non-zero entries indicate gate locations
% idx -  index of the currently processed entry

i = idx - 1;
cnt = 1;

while (gates(i) == 0) & (i > 0)
  if fr_id(i) ~= 0
    cnt = cnt + 1;
  end
  if gates(i) > 0
    break;
  end
  i = i - 1;
end

return;



