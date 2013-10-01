% NAME:
% Time-stamp: <>
% DESCRIPTION:
% EXAMPLES:
% BUGS:
% TYPE:
% AUTHOR: 
% ------------------------------------------------------------------
clear;
addpath(pwd);
addpath([pwd '/arne']);
% ------------------------------------------------------------------

% dicom and physio data
w_dir = [pwd '/arnedata'];

% replace with your dicom folderf and your physio file
dser = ['./06.12.2009-16:33:27/44963/cardtask_34sli_384x384.13/'];


%/disk/mace2/scan_data/WPC-3623/06.12.2009-16:33:27

physiopath = ['./ExampleData/wp3623_44963_061209.puls'];

%./Examples

% ------------------------------------------------------------------
% exam specifics: geting some info
% ------------------------------------------------------------------
alldcmlist = dir( [dser '/MR.*'])
clear( 'alldcm');
for ii=1:length(alldcmlist)
  alldcm{ii} = [dser '/' alldcmlist(ii).name];
end


tstrt = 10^8;
tend = -10^8;

for ii = 1:length(alldcm)
  dinfo = dicominfo( alldcm{ii});
  acqtime = tstr2sec(dinfo.AcquisitionTime);
  if( tstrt >= acqtime)
    tstrt = acqtime;
  end
  if( tend <= acqtime)
    tend = acqtime;
  end
end

ninfo.msb = 1000*tstrt;
ninfo.mse = 1000*tend;

% read in the physio data
pinfo = getPinfo(physiopath);


% put a copy in the output folder
system( ['mkdir -p ' w_dir '/raw']);
system( [ ' cp -u ' pinfo.nam pinfo.typ ' ' w_dir '/raw' ] );

% read the data
pdat = readphval([pinfo.nam pinfo.typ], pinfo.typ);

pinfo.tau = pdat.tau;
pinfo.y = pdat.y;

% one would want pinfo.tau*length(pinfo.y) == (pinfo.te - pinfo.tb)
% output file name

outpname = [w_dir '/chopped.dat']

chopph(ninfo, pinfo, outpname) 
