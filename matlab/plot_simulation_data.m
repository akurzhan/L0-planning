
tt=linspace(0,24-1/12,288);

% Extracting link IDs
link_id = xlsread(xlsx_file, 'GP_Speed', sprintf('a%d:e%d', range(1), range(2)));
gp_id = link_id(:, 1)'; % GP link IDs
pm = pm_dir*link_id(:, 2)'; % postmiles
llen = link_id(:, 3)'; % link lengths in miles
ffspeeds = link_id(:, 5)'; % free flow speeds

sz = size(llen, 2);
%pm(1) = 0;
for i = 2:sz
  pm(i) = pm(i-1) + llen(i-1);
end

colormap gray

figure(1);
hold on;
pcolor(pm, tt, ORQ');
colorbar;
axis([pm(1), pm(end), 0, 24]);
xlabel('Abs. Postmile');
ylabel('Time');
title('On-ramp Queues');
colormap gray

if 1
figure(2);
hold on;
pcolor(pm, tt, -HOV_F');
shading flat;
colorbar;
axis([pm(1), pm(end), 0, 24]);
xlabel('Abs. Postmile');
ylabel('Time');
title('HOV Flow');
colormap gray

figure(3);
hold on;
pcolor(pm, tt, HOV_V');
shading flat;
colorbar;
axis([pm(1), pm(end), 0, 24]);
xlabel('Abs. Postmile');
ylabel('Time');
title('HOV Speed');
grid on;
colormap gray
end

if 0
plot([pm(26) pm(26) pm(33) pm(33) pm(26)], [tt(192) tt(228) tt(228) tt(192) tt(192)], 'w');
plot([pm(43) pm(43) pm(58) pm(58) pm(43)], [tt(192) tt(228) tt(228) tt(192) tt(192)], 'w');
end

if 0
plot([pm(29) pm(29) pm(50) pm(50) pm(29)], [tt(72) tt(108) tt(108) tt(72) tt(72)], 'w');
plot([pm(66) pm(66) pm(78) pm(78) pm(66)], [tt(79) tt(110) tt(110) tt(79) tt(79)], 'w');
plot([pm(66) pm(66) pm(78) pm(78) pm(66)], [tt(186) tt(220) tt(220) tt(186) tt(186)], 'w');
plot([pm(78) pm(78) pm(83) pm(83) pm(78)], [tt(83) tt(105) tt(105) tt(83) tt(83)], 'w');
end



figure(4);
hold on;
pcolor(pm, tt, -GP_F');
shading flat;
colorbar;
axis([pm(1), pm(end), 0, 24]);
xlabel('Abs. Postmile');
ylabel('Time');
title('GP Flow');
colormap gray

figure(5);
hold on;
pcolor(pm, tt, GP_V');
shading flat;
colorbar;
axis([pm(1), pm(end), 0, 24]);
xlabel('Abs. Postmile');
ylabel('Time');
title('GP Speed');
grid on;
colormap gray

if 0
plot([pm(26) pm(26) pm(33) pm(33) pm(26)], [tt(192) tt(228) tt(228) tt(192) tt(192)], 'w');
plot([pm(43) pm(43) pm(58) pm(58) pm(43)], [tt(192) tt(228) tt(228) tt(192) tt(192)], 'w');
plot([pm(71) pm(71) pm(97) pm(97) pm(71)], [tt(180) tt(216) tt(216) tt(180) tt(180)], 'w');
end

if 0
plot([pm(29) pm(29) pm(50) pm(50) pm(29)], [tt(72) tt(108) tt(108) tt(72) tt(72)], 'w');
plot([pm(66) pm(66) pm(78) pm(78) pm(66)], [tt(79) tt(110) tt(110) tt(79) tt(79)], 'w');
plot([pm(66) pm(66) pm(78) pm(78) pm(66)], [tt(186) tt(220) tt(220) tt(186) tt(186)], 'w');
plot([pm(78) pm(78) pm(83) pm(83) pm(78)], [tt(83) tt(105) tt(105) tt(83) tt(83)], 'w');
end

if 0
plot([pm(52) pm(52) pm(122) pm(122) pm(52)], [tt(185) tt(231) tt(231) tt(185) tt(185)], 'w');
end

if 0
plot([pm(2) pm(2) pm(32) pm(32) pm(2)], [tt(72) tt(96) tt(96) tt(72) tt(72)], 'w');
plot([pm(42) pm(42) pm(73) pm(73) pm(42)], [tt(78) tt(114) tt(114) tt(78) tt(78)], 'w');
plot([pm(74) pm(74) pm(111) pm(111) pm(74)], [tt(90) tt(114) tt(114) tt(90) tt(90)], 'w');
end

