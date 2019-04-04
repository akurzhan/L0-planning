function collect_sr(data_file, range, gp_out, gp_id, hov_id, fr_id, hot_buffer, warmup_time)


warmup_steps = round(warmup_time/300);
numTime = 288+warmup_steps;

SR = [];
HSR = [];
GHSR = [];
GHSR_i = zeros(1, numTime);

sz = size(gp_id, 2);

nodes = xlsread(data_file, 'Configuration', sprintf('y%d:y%d', range(1), range(2)))';


HGSR = zeros(sz, numTime);
hot_gates = zeros(1, sz);
if hot_buffer
  HGSR = xlsread(data_file, 'HOV_SplitRatios', sprintf('i%d:kj%d', range(1), range(2)));
  hot_gates = (max(abs(HGSR')) > 0);
end


for i = 1:sz
  if fr_id(i) ~= 0
    %SR = [SR; extract_sr(gp_out, gp_id(i), fr_id(i), gp_id(i-1), 1)];
    %HSR = [HSR; extract_sr(gp_out, gp_id(i), fr_id(i), gp_id(i-1), 0)];
    SR = [SR; extract_sr(gp_out, nodes(i-1), fr_id(i), gp_id(i-1), 1)];
    HSR = [HSR; extract_sr(gp_out, nodes(i-1), fr_id(i), gp_id(i-1), 0)];
  else
    SR = [SR; zeros(1, numTime)];
    HSR = [HSR; zeros(1, numTime)];
  end
  if hot_gates(i) ~= 0 & 0
    GHSR = [GHSR; extract_sr(gp_out, gp_id(i), hov_id(i), gp_id(i-1), 0)];
    GHSR_i = [GHSR_i; extract_sr(gp_out, gp_id(i), gp_id(i), hov_id(i-1), 0)];
  else
    GHSR = [GHSR; zeros(1, numTime)];
    GHSR_i = [GHSR_i; zeros(1, numTime)];
  end
end
%GHSR = GHSR - GHSR_i;

SR = SR(:,warmup_steps+1:end);
GHSR = GHSR(:,warmup_steps+1:end);

% write data to spreadsheet
if 1
fprintf('Writing data to %s...\n', data_file);
xlswrite(data_file, SR, 'Off-Ramp_SplitRatios', sprintf('k%d:kl%d', range(1), range(2)));
%xlswrite(data_file, HSR, 'HOV_Off-Ramp_SplitRatios', sprintf('k%d:kl%d', range(1), range(2)));
if hot_buffer
  xlswrite(data_file, GHSR, 'HOV_SplitRatios', sprintf('i%d:kj%d', range(1), range(2)));
end
end
