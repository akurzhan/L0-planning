function [] = write_offramp_demand_xml(xlsx_file,fr_demand_file,hov_demand_file,range)

fprintf('Generating off-ramp & HOV demand config...\n');
fr_id = xlsread(xlsx_file, 'Off-Ramp_CollectedFlows', sprintf('g%d:g%d', range(1), range(2)))';
FRD = xlsread(xlsx_file, 'Off-Ramp_CollectedFlows', sprintf('k%d:kl%d', range(1), range(2)));
FRK = xlsread(xlsx_file, 'Off-Ramp_Knobs', sprintf('k%d:kl%d', range(1), range(2)));
%hov_id = xlsread(xlsx_file, 'HOV_Demand', sprintf('b%d:b%d', range(1), range(2)))';
%HVD = (1/3600) * xlsread(xlsx_file, 'HOV_Demand', sprintf('i%d:kj%d', range(1), range(2)));
%HVD = xlsread(xlsx_file, 'HOV_Demand', sprintf('i%d:kj%d', range(1), range(2)));
%FRD = (1/3600) * FRD .* FRK;
FRD = (1/3600) * FRD .* FRK;
has_fr_dem = find(max(FRD,[],2)>0);
%has_hov_dem = find(max(HVD,[],2)>0);

dp = generate_mo('demandProfile');
dp.demand = generate_mo('demand');
dp.demand.CONTENT = '';
dp.demand.ATTRIBUTE.vehicle_type_id = 1;     % ignored
dps = repmat(dp,1,length(has_fr_dem) );

for i=1:length(has_fr_dem) 
    dps(i).ATTRIBUTE.id = i;
    dps(i).ATTRIBUTE.link_id_org = fr_id(has_fr_dem(i));
    dps(i).demand.CONTENT = writecommaformat(FRD(has_fr_dem(i),:),'%.6f');
end

DemandSet = generate_mo('DemandSet');
DemandSet.ATTRIBUTE.id = 2;
DemandSet.ATTRIBUTE.project_id = 1;
DemandSet.ATTRIBUTE.name = 'offramps';
DemandSet.demandProfile = dps;
xml_write(fr_demand_file,DemandSet);
