function fr_sr = extract_sr(gp_out, gp_id, fr_id, gp_up, vt)
% gp_out - prefix for finding the split ratio file
% gp_id - link id used to construct split ratio file name
% fr_id - off-ramp id
% vt - vehicle type

fname = sprintf('%s%d.txt', gp_out, gp_id);
fid = fopen(fname, 'rt');
A = textscan(fid, '%d\t%d\t%d\t%d\t%f', ...
               'Delimiter', '\t', 'CollectOutput', 1, 'HeaderLines', 0);
fclose(fid);


D = A{1, 1}';
fr_sr = A{1, 2}';

idx = find(D(2, :) == gp_up);
D = D(:, idx);
fr_sr = fr_sr(idx);

idx = find(D(3, :) == fr_id);
D = D(:, idx);
fr_sr = fr_sr(idx);

idx = find(D(4, :) == vt);
D = D(:, idx);
fr_sr = fr_sr(idx);

fr_sr = fr_sr(2:end);

return;


