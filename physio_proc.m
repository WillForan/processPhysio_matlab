
function rez = physio_proc(subid, physioinput,dicominput,outputdir)
% NAME:
% Time-stamp: <>
% DESCRIPTION:
% EXAMPLES:
% BUGS:
% TYPE:
% AUTHOR: 
% ------------------------------------------------------------------

%addpath(pwd);
%addpath([pwd '/arne']); %CV - all the other .m files this program calls are in 'arne' folder
% ------------------------------------------------------------------

%***PLEASE NOTE***  This was originally written by Costin, I haven't
%altered the code in anyway, just put commenting in.  The comments I have
%entered will be marked with a 'CV' at the beginning
%Comments by Kai Hwang will be marked with KH

% dicom and physio data
% KH - output directory
root=pwd
w_dir = [pwd '/' outputdir '/']  %CV - w_dir, the directory to which files will be written

% replace with your dicom folderf and your physio file
dser = [pwd '/' dicominput]
%CV - getting the exact name for the correct path is very important,
%initially this step proved to be the most problematic since it will not
%indicate if the path is incorrect
%Currently, the way the path is entered in this example means that the top folder
%containing the dicom data is in the same folder as 'proc_pair.m'
%The folder containing the dicom data has the following format:
%MM.DD.YYYY-HR:MIN:SEC/PATIENTID/GROUPING_OF_IMAGES_IN_A_SPECIFIC_CATEGORY

%/disk/mace2/scan_data/WPC-3623/06.12.2009-16:33:27

physiopath = [pwd '/' physioinput]

%CV - this is the path of the physio FILE, it needs a file ending with
%'.puls' '.ecg' '.ext' or '.resp' -KH I have revised it so it will look for
% .puls .resp automatically

%Also the files are named with the following format:
%RESEARCHERCODE_PATIENTID_DATE.*
%but altering the file name is fine, only the end file extensions matter


% ------------------------------------------------------------------
% exam specifics: geting some info
% ------------------------------------------------------------------
alldcmlist = dir( [dser '/MR.*']);
clear( 'alldcm');
for ii=1:length(alldcmlist)
  alldcm{ii} = [dser '/' alldcmlist(ii).name];
end


tstrt = 10^8; %CV -initializing time start and end
tend = -10^8;

%CV - This forloop makes sure the acqusition times from dicom data match up and will be
%used to crop the physio data.  The result being that after the cropping, the only data
%points presented in the new physio data file will correspond to the
%physiological measurements taken during the acquisition of the dicom data.
%Please consult attached diagram of the purpose of this program if unclear.
for ii = 1:length(alldcm)
  dinfo = dicominfo( alldcm{ii});
  acqtime = tstr2sec(dinfo.AcquisitionTime); %KH - this function will convert acquisition time into # seconds since midnight
  if( tstrt >= acqtime)
    tstrt = acqtime;
  end
  if( tend <= acqtime)
    tend = acqtime;
  end
end  

ninfo.msb = 1000*tstrt; %CV - converting time units
ninfo.mse = 1000*tend;  %KH - convert time units into msec

ext={'.puls';'.resp'};

for a =1:1:2
phyname=[physiopath,cell2mat(ext(a))];    
% read in the physio data
pinfo = getPinfo(phyname);
%CV - using 'getPinfo.m' to acquire the relevant information from the file given in 'physiopath'
%'getPinfo.m' will retrieve the type (example: *.puls *.ecg) and the path name)
%then 'getphinfo.m', to acquire the tb (start time) and te(end time) of the
%physio data which is given as part of the last 5 lines in the data file


% put a copy in the output folder
%system( ['mkdir -p ' w_dir '/raw']); 
%system( [ ' cp -u ' pinfo.nam pinfo.typ ' ' w_dir '/raw' ] );
%CV - this makes an unmodified copy of the physio data and put it in the
%folder marked 'raw'


% read the data
pdat = readphval([pinfo.nam pinfo.typ], pinfo.typ);
pinfo.tau = pdat.tau; %KH - time intervals
pinfo.y = pdat.y;   % KH - actual physio data strip of triggers (5000)
pinfo.yall = pdat.yall; % KH - all physio data including triggers (5000)
% one would want pinfo.tau*length(pinfo.y) == (pinfo.te - pinfo.tb)

%CV - the resulting 'pinfo' is a struct with 6 values:
% pinfo.tb and pinfo.te acquired by 'getphinfo.m'
% pinfo.typ and pinfo.nam from 'getPinfo.m'
% pinfo.tau and pinfo.y (a 1-D array containing the actual data values from physio files)


% output file name
outpname = [w_dir subid cell2mat(ext(a))];
%CV - this name can/should be altered according to type or the program will
%overwrite the file
%ofname = [outputdir subid cell2mat(ext(a))];
oftname = [outpname '.1D'];
chopph(ninfo, pinfo, outpname) ;
%CV - 'chopph.m' does the actual cropping of the physio data contained in
%pinfo.y (the large array with the actual physio data points).  It checks
%to make sure that 'only the MRI's completelly immerssed in a physio are considered'


chopedTS = load(outpname);
TChopedTS = transpose(chopedTS);
dlmwrite(oftname, TChopedTS); % KH: transpose choped phsysio for afni

%cmd = ['1dtranspose ' outpname ' >' oftname]; %KH - calling afni 1dtranspose function to write 1d file for RetroTS
%system(cmd);


rez.nb=ninfo.msb;
rez.ne=ninfo.mse;
rez.pb=pinfo.tb;
rez.pe=pinfo.te;
rez.y=pinfo.y;
rez.yall=pinfo.yall;
rez.Trigger=(rez.yall==5000);
rez.findT=find(rez.Trigger);
rez.totalTrigger=sum(rez.Trigger);
%rez
end
%KH - run AFNI's RetroTS to create regressors
cd(w_dir);
Opt.Respfile = [subid '.resp.1D'];
Opt.Cardfile = [subid '.puls.1D'];
Opt.VolTR = 1.5;
Opt.Nslices = 29;
Opt.PhysFS = 50;
Opt.Prefix =[subid '_RetroTS'];
Opt.SliceOrder = 'seq+z';
RetroTS(Opt);
cd(root);
pwd



