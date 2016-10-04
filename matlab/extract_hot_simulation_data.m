function [GP_V, GP_F, GP_D, HOV_V, HOV_F, HOV_D, ORD, ORF, FRD, FRF, ORQ, ORS_updated] = extract_hot_simulation_data(ptr,data_file,range,no_ml_queue,ORS,dc,orgf2,orgf3,orgf4)

% Extracting link data
link_id = xlsread(data_file, 'GP_Speed', sprintf('a%d:f%d', range(1), range(2)));
gp_id = link_id(:, 1)'; % GP link IDs
pm = link_id(:, 2)'; % postmiles
llen = link_id(:, 3)'; % link lengths in miles
ffspeeds = link_id(:, 5)'; % free flow speeds
gp_cap = xlsread(data_file, 'GP_Flow', sprintf('e%d:e%d', range(1), range(2)));
gp_cap = gp_cap';
link_id = xlsread(data_file, 'HOV_Flow', sprintf('a%d:e%d', range(1), range(2)));
hov_id = link_id(:, 1)'; % HOV link IDs
hov_cap = link_id(:, 5)'; % HOV link capacities

gp_cd = round(gp_cap ./ ffspeeds);
hov_cd = round(hov_cap ./ ffspeeds);


or_id = xlsread(data_file, 'On-Ramp_CollectedFlows', sprintf('g%d:g%d', range(1), range(2)));
or_id = or_id';
ORD = xlsread(data_file, 'On-Ramp_CollectedFlows', sprintf('k%d:kl%d', range(1), range(2)));
ORK = xlsread(data_file, 'On-Ramp_Knobs', sprintf('k%d:kl%d', range(1), range(2)));
ORGF = xlsread(data_file, 'On-Ramp_GrowthFactors', sprintf('k%d:kl%d', range(1), range(2)));
if orgf2 | orgf3 | orgf4
  ORGF2 = xlsread(data_file, 'On-Ramp_GrowthFactors_2', sprintf('k%d:kl%d', range(1), range(2)));
  if orgf3 | orgf4
    ORGF3 = xlsread(data_file, 'On-Ramp_GrowthFactors_3', sprintf('k%d:kl%d', range(1), range(2)));
    if orgf4
      ORGF4 = xlsread(data_file, 'On-Ramp_GrowthFactors_4', sprintf('k%d:kl%d', range(1), range(2)));
      ORGF3 = ORGF3 .* ORGF4;
    end
    ORGF2 = ORGF2 .* ORGF3;
  end
  ORGF = ORGF .* ORGF2;
end
ORD = ORD .* ORK .* ORGF;
has_or = find(max(ORD,[],2)>0);
has_or = has_or';


fr_id = xlsread(data_file, 'Off-Ramp_CollectedFlows', sprintf('g%d:g%d', range(1), range(2)));
fr_id = fr_id';
FRD = xlsread(data_file, 'Off-Ramp_CollectedFlows', sprintf('k%d:kl%d', range(1), range(2)));
FRK = xlsread(data_file, 'Off-Ramp_Knobs', sprintf('k%d:kl%d', range(1), range(2)));
FRD = FRD .* FRK;
has_fr = find(max(FRD,[],2)>0);
has_fr = has_fr';


link_id = ptr.scenario_ptr.link_id_begin_end(:, 1)';

% initialization
m = size(gp_id, 2);
GP_V = zeros(m, 288);
GP_F = zeros(m, 288);
GP_D = zeros(m, 288);
HOV_V = zeros(m, 288);
HOV_F = zeros(m, 288);
HOV_D = zeros(m, 288);


% data extraction
fprintf('Extracting simulation data - speeds and flows...\n');
for i = 1:m
  idx = find(link_id == gp_id(i));
  den = ptr.density_veh{1}(2:289, idx) + ptr.density_veh{2}(2:289, idx)  + ptr.density_veh{3}(2:289, idx);
  outflow = ptr.outflow_veh{1}(:, idx) + ptr.outflow_veh{2}(:, idx) + ptr.outflow_veh{3}(:, idx);
  inflow = ptr.inflow_veh{1}(:, idx) + ptr.inflow_veh{2}(:, idx) + ptr.inflow_veh{3}(:, idx);
  for j = 1:dc
    den =  den + ptr.density_veh{3+j}(2:289, idx);
    outflow = outflow + ptr.outflow_veh{3+j}(:, idx);
    inflow = inflow + ptr.inflow_veh{3+j}(:, idx);
  end
  den = den' ./ (llen(i)*ones(1, 288));
  outflow = 12*outflow';
  V = outflow ./ den;
  V = max([V; zeros(1, 288)]);
  V = min([V; ffspeeds(i)*ones(1, 288)]);
  GP_V(i, :) = V;
  GP_D(i, :) = den;
  inflow = 12*inflow';
  GP_F(i, :) = inflow;

  if hov_id(i) ~= 0
    idx = find(link_id == hov_id(i));
    den = ptr.density_veh{1}(2:289, idx) + ptr.density_veh{2}(2:289, idx)  + ptr.density_veh{3}(2:289, idx);
    outflow = ptr.outflow_veh{1}(:, idx) + ptr.outflow_veh{2}(:, idx) + ptr.outflow_veh{3}(:, idx);
    inflow = ptr.inflow_veh{1}(:, idx) + ptr.inflow_veh{2}(:, idx) + ptr.inflow_veh{3}(:, idx);
    for j = 1:dc
      den = den + ptr.density_veh{3+j}(2:289, idx);
      outflow = outflow + ptr.outflow_veh{3+j}(:, idx);
      inflow = inflow + ptr.inflow_veh{3+j}(:, idx);
    end
    den = den' ./ (llen(i)*ones(1, 288));
    outflow = 12*outflow';
    V = outflow ./ den;
    V = max([V; zeros(1, 288)]);
    V = min([V; ffspeeds(i)*ones(1, 288)]);
    HOV_V(i, :) = V;
    HOV_D(i, :) = den;
    inflow = 12*inflow';
    HOV_F(i, :) = inflow;
  end
end

GP_F(1, :) = zeros(1, 288);
GP_V(1, :) = zeros(1, 288);
GP_D(1, :) = zeros(1, 288);
HOV_F(1, :) = zeros(1, 288);
HOV_V(1, :) = zeros(1, 288);
HOV_D(1, :) = zeros(1, 288);

GP_V = round(GP_V);
GP_F = round(GP_F);
GP_D = round(GP_D);
HOV_V = round(HOV_V);
HOV_F = round(HOV_F);
HOV_D = round(HOV_D);

%%% HACK begin %%%

GP_V(end, :) = GP_V(end-1, :);
HOV_V(end, :) = HOV_V(end-1, :);

for i = 1:m
  for j = 1:288
    if abs(ffspeeds(i) - GP_V(i, j)) < 2
      GP_V(i, j) = ffspeeds(i);
    end
    if abs(ffspeeds(i) - HOV_V(i, j)) < 2
      HOV_V(i, j) = ffspeeds(i);
    end
    if GP_D(i, j) < 1
      GP_V(i, j) = ffspeeds(i);
    end
    if hov_id(i) ~= 0
      if HOV_D(i, j) < 1
        HOV_V(i, j) = ffspeeds(i);
      end
      if (i == m) | ((HOV_D(i, j) < hov_cd(i)) && (HOV_D(i+1, j) < hov_cd(i+1)))
        HOV_V(i, j) = ffspeeds(i);
      end
    end
  end
end
%%% HACK end %%%


GP_V(1, :) = zeros(1, 288);
GP_F(1, :) = zeros(1, 288);
m = size(has_or, 2);

fprintf('Extracting simulation data - ramp flows...\n');
ORF = ORD;
ORQ = ORD;
ORS_updated = [];
for i = 1:m
  ors = find_or_struct(ORS, or_id(has_or(i)));
  if isempty(ors)
    idx = find(link_id == or_id(has_or(i)));
    outflow = ptr.outflow_veh{1}(:, idx) + ptr.outflow_veh{2}(:, idx);
    outflow = 12*outflow';
    ORF(has_or(i), :) = outflow;
    den = ptr.density_veh{1}(2:289, idx) + ptr.density_veh{2}(2:289, idx);
    ORQ(has_or(i), :) = round(den');
  else
    if isempty(ors.feeders)
      links = ors.peers;
    else      
      links = ors.feeders;
    end
    in_count = size(links, 2);
    ord = zeros(1, 288);
    orf = zeros(1, 288);
    orq = zeros(1, 288);
    for j = 1:in_count
      sz2 = 4;
      if orgf4
        sz2 = 6;
      elseif orgf3
        sz2 = 5;
      end
      % Demand for special onramps:
      % +1 - collected flows
      % +2 - knobs
      % +3 - growth factors
      % +4 - growth factors 2
      % +5 - growth factors 3
      % +6 - growth factors 4
      dmnd = ors.data((j-1)*sz2 + 1, :) .* ors.data((j-1)*4 + 2, :) .* ors.data((j-1)*4 + 3, :);
      if orgf2 | orgf3 | orgf4
        dmnd = dmnd .* ors.data((j-1)*sz2 + 4, :);
        if orgf3 | orgf4
          dmnd = dmnd .* ors.data((j-1)*sz2 + 5, :);
          if orgf4
            dmnd = dmnd .* ors.data((j-1)*sz2 + 6, :);
          end
        end
      end
      dmnd = round(dmnd);
      ord = ord + dmnd;
      idx = find(link_id == links(j));
      outflow = ptr.outflow_veh{1}(:, idx) + ptr.outflow_veh{2}(:, idx);
      outflow = round(12*outflow');
      ors.output((j-1)*2 + 1, 1:288) = outflow;
      orf = orf + outflow;
      den = ptr.density_veh{1}(2:289, idx) + ptr.density_veh{2}(2:289, idx);
      den = round(den');
      den = compute_or_queues(dmnd-outflow);
      ors.output((j-1)*2 + 2, 1:288) = den;
      orq = orq + den;
    end
    ORS_updated = [ORS_updated ors];
    ORD(has_or(i), :) = ord;
    ORQ(has_or(i), :) = orq;
    if isempty(ors.feeders)
      ORF(has_or(i), :) = orf;
    else
      idx = find(link_id == or_id(has_or(i)));
      outflow = ptr.outflow_veh{1}(:, idx) + ptr.outflow_veh{2}(:, idx);
      outflow = 12*outflow';
      ORF(has_or(i), :) = outflow;
    end
  end
end

m = size(has_fr, 2);
FRF = FRD;
for i = 1:m
  idx = find(link_id == fr_id(has_fr(i)));
  inflow = ptr.inflow_veh{1}(:, idx) + ptr.inflow_veh{2}(:, idx) + ptr.inflow_veh{3}(:, idx);
  for j = 1:dc
    inflow = inflow + ptr.inflow_veh{j+3}(:, idx);
  end
  inflow = 12*inflow';
  FRF(has_fr(i), :) = inflow;
end

ORQ = compute_or_queues(ORD-ORF);
ORF = round(ORF);
FRF = round(FRF);

if no_ml_queue
  ORQ(2, :) = zeros(1, 288);
end


% write data to spreadsheet
if 1
fprintf('Writing data to %s...\n', data_file);
xlswrite(data_file, GP_V, 'GP_Speed', sprintf('i%d:kj%d', range(1), range(2)));
pause(2);
xlswrite(data_file, GP_F, 'GP_Flow', sprintf('i%d:kj%d', range(1), range(2)));
pause(2);
xlswrite(data_file, GP_D, 'GP_Density', sprintf('i%d:kj%d', range(1), range(2)));
pause(2);
xlswrite(data_file, gp_cd', 'GP_Density', sprintf('e%d:e%d', range(1), range(2)));
pause(2);
xlswrite(data_file, HOV_V, 'HOV_Speed', sprintf('i%d:kj%d', range(1), range(2)));
pause(2);
xlswrite(data_file, HOV_F, 'HOV_Flow', sprintf('i%d:kj%d', range(1), range(2)));
pause(2);
xlswrite(data_file, HOV_D, 'HOV_Density', sprintf('i%d:kj%d', range(1), range(2)));
pause(2);
xlswrite(data_file, hov_cd', 'HOV_Density', sprintf('e%d:e%d', range(1), range(2)));
pause(2);
xlswrite(data_file, ORF, 'On-Ramp_Flow', sprintf('k%d:kl%d', range(1), range(2)));
pause(2);
xlswrite(data_file, FRF, 'Off-Ramp_Flow', sprintf('k%d:kl%d', range(1), range(2)));
pause(2);
xlswrite(data_file, ORQ, 'On-Ramp_Queue', sprintf('k%d:kl%d', range(1), range(2)));
sz = size(ORS_updated, 2);
cursor = 2;
for i =  1:sz
  in_count = size(ORS_updated(i).output, 1);
  pause(2);
  xlswrite(data_file, ORS_updated(i).output, 'On-Ramp_SpecialData', sprintf('e%d:kf%d', cursor, cursor+in_count-1));
  cursor = cursor + in_count;
end
end
