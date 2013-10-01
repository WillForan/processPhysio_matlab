%%%%%%
%
% adapted from Kai Hwang's mods of script commented by CV (Jennings lab), written by
% Costin (Physcist at MRC)
%
% 1. reads physio in with "readphval" and "getPinfo" -- USE MDHTime, not MPCUTime
% 2. get each protocol's start/end time by reading all dicoms (MR*) in scan
% 3. chop physio to each protocol
% 4. save 
%     .puls/.resp           truncated
%     .puls.1D/.resp.1D     for transposed for afni
%      _RetroTS.slibase.1D  RetroTS output
%
%
% need physio resp and card
%   e.g.
%   /data/Luna1/Raw/Physio/organized/MultiModal/10997/20130329/wpc5640_10997_032913.*
% need a dicom dir
%   e.g. /data/Luna1/Raw/MultiModal/10997_20130329/*/MR*
%   dicominfo('/data/Luna1/Raw/MultiModal/10997_20130329/MultimodallWM_v1_run4_768x720.8/MR.1.3.12.2.1107.5.2.32.35217.2013032913395535903893786')
% 
% parse all the dicoms to get the start and end time of the scanning
%  use dicominfo--> AcquisitionTime (SeriesDescription ProtocolName)
% 
% break up physio by this start and end time
%
%%%%%%

%% initial params -- no longer used: set by function b/c studies have diff struct
% rawscandir    = '/data/Luna1/Raw/MultiModal/';
% rawphysiodir  = '/data/Luna1/Raw/Physio/organized/MultiModal/';
% physiosavedir = '/data/Luna1/MultiModal/Physio/';
% subj='10997'; date='20130329';
% 
% subjscandir=[rawscandir subj '_' date '/'];
% subjphysiodir=[rawphysiodir subj '/' date '/' ];
% subjphysiosavedir = [ physiosavedir subj '_' date '/' ];
%
%% examples
% tic
%physio_proc_wallace('10997','20130329', ...
%                     '/data/Luna1/Raw/MultiModal/10997_20130329/', ...
%                     '/data/Luna1/Raw/Physio/organized/MultiModal/10997/20130329/',...
%                     '/data/Luna1/MultiModal/Physio/10997_20130329/' );
%toc
% 108.7 seconds

% tic;physio_proc_wallace('10776','20100327','/data/Luna1/Raw/MRRC_Org/10776/20100327/','/data/Luna1/Raw/Physio/organized/Reward/10776/20100327/','/data/Luna1/Reward/Physio/10776/20100327/');toc
%191.9 seconds

% FOR ALL Reward
% phys='/data/Luna1/Raw/Physio/organized/Reward/';  
% savdir='/data/Luna1/Reward/Physio/';
% scandir='/data/Luna1/Raw/MRRC_Org/'; 
% sdvd=cell(0,0); 
% for sd=dir(phys)'; for vd=dir([phys '/' sd.name])'; if(regexp([sd.name vd.name],'\.')); continue; end; sdvd=[sdvd; {sd.name, vd.name}]; end; end
% tic;
% savdir='/data/Luna1/Reward/Physio/';scandir='/data/Luna1/Raw/MRRC_Org/';for
% sv=sdvd'; try rez.(['s' sv{1} '_' sv{2}]) =
% physio_proc_wallace(sv{1},sv{2},sprintf('%s/%s/%s',scandir,sv{1},sv{2}), sprintf('%s/%s/%s',phys,sv{1},sv{2}), sprintf('%s/%s/%s',savdir,sv{1},sv{2}) ); catch rez.(['s' sv{1} '_' sv{2}]) = 'fail'; end;toc;end
% 
%% rez returns per protocol dicom info, physio info, and RetroTRs
function rez = physio_proc_wallace(subjscandir,subjphysiodir, subjphysiosavedir) 
    
    % already have this visit
    if(exist(subjphysiosavedir,'dir') && length(dir(subjphysiosavedir))>2 )
        rez=sprintf('already have %d physio files in %s',length(dir(subjphysiosavedir)), subjphysiosavedir);
        fprintf('%s\n',rez);
        return;
        %error('pysioproc:filecheck', '%s already exists and has stuff\n', subjphysiosavedir);
    end
    %% check subj info exists
    
    for dirnameT={subjscandir,subjphysiodir}
      dirnameT=dirnameT{1};
      if(~exist(dirnameT,'dir') )
          rez=sprintf('%s DNE',dirnameT);
          fprintf('%s\n',rez)
          return;
          %error('pysioproc:filecheck', '%s DNE!', dirnameT);
      end
    end
    
    % create physio directory
    if(~exist(subjphysiosavedir,'dir')); mkdir(subjphysiosavedir); end

    %% get the physio file information (tb, te, type, nam)
    %%% and data (tau y yall)
    %%% for both resp and card
    for ext={'resp','puls'}
     ext=ext{1};
     tmp = dir([ subjphysiodir '/*' ext ]);
     if(length(tmp)<1)
          rez=sprintf('no physio in %s',[ subjphysiodir '/*' ext ] );
          fprintf('%s\n',rez)
          return;
         %error('pysioproc:filecheck','no physio in %s',[ subjphysiodir '/*' ext ] );
     end
     name = [ subjphysiodir '/' tmp(1).name ];
     pinfo = getPinfo( name );
     pdat  = readphval(name, pinfo.typ);

     % merge into one unified structure with tb te typ nam tau y  yall 
     physiofile.(ext) = cell2struct( [ struct2cell(pinfo); struct2cell(pdat) ], [fieldnames(pinfo);fieldnames(pdat)],1 );

     % add some trigger info
     physiofile.(ext).Trigger=(pdat.yall==5000);
     physiofile.(ext).totalTrigger=sum(physiofile.(ext).Trigger);
    end



    %% UGLY -- there is no glob or find in matlab?
    % find all the dicoms like: subjscandir/*/MR*
    % as cell of char vecs in "dicoms" variable
    scandirs = dir([ subjscandir '/*']);
    scandirs = {scandirs(3:end).name}; % grab only the name, skip . and ..
    dicoms={};
    for d=scandirs;
        f=dir([subjscandir '/' d{1} '/MR*']);
        % TODO: to speed up, we can probably only take the first and last
        %       MR* in each directory 
        % f=[f(1) f(end)]
        dicoms=[ dicoms cellfun(@(x) ([subjscandir '/' d{1} '/' x ]), {f.name},'UniformOutput',false) ];
    end


    %% for every dicom
    % run dicominfo to get Acquisition Time and ProtocolName
    % takes a long time! -- should probably just look at the first and last MR*
    % in each directory
    %
    % this gives us a start, end, te, and tr for each protcol
    protocolInfo=struct();
    for dcmfile=dicoms

      d        = dicominfo(dcmfile{1});

      % FIX BUG where protocol occurs twice, but with different index
      % by appending .## in scandir to protocol name
      fn=struct();
      fn       = regexp( dirname(d.Filename), '\.(?<protocolrunnum>\d+)$','names');

      protocol = [ regexprep(d.ProtocolName,' ','_')  '_' fn.protocolrunnum ];
      acqtime  = tstr2sec(d.AcquisitionTime);

      % doesnt exist yet, initialize start and end
      if(~ any(strcmp(protocol,fieldnames(protocolInfo))))
          protocolInfo.(protocol).start=acqtime;
          protocolInfo.(protocol).end=acqtime;
          protocolInfo.(protocol).Te=d.EchoTime;
          protocolInfo.(protocol).Tr=d.RepetitionTime/1000;
          protocolInfo.(protocol).alltiming=acqtime;
      % otherwise check start and end, update if needed    
      else
          protocolInfo.(protocol).alltiming=[protocolInfo.(protocol).alltiming acqtime];

         if(protocolInfo.(protocol).start>acqtime) 
             protocolInfo.(protocol).start=acqtime;
         elseif(protocolInfo.(protocol).end<acqtime) 
             protocolInfo.(protocol).end=acqtime;
         end

      end
    end


    %%
    % for each protocol, spit out the physio
    %%%

    for protocol=fieldnames(protocolInfo)'

        protocol=protocol{1};

        Opt.Nslices    = 29; %TODO grab this from dicom?
        Opt.PhysFS     = 50;
        Opt.SliceOrder = 'seq+z';    

        % there maybe a protocol that doesn't have a good tr
        % eg. mprage, OFC_Prescribe, etc
        % we should skip it
        if(~ any(strcmp('Tr',fieldnames(protocolInfo.(protocol)))) || ...
             protocolInfo.(protocol).Tr<=0.5  )
          fprintf('No or small TR for %s,skipping\n',protocol);
          continue
        end

        % chopph wants at least 516 samples
        if(protocolInfo.(protocol).end - protocolInfo.(protocol).start < 1/Opt.PhysFS *512  )
          fprintf('protcol duration is too short for %s,skipping\n',protocol);
          continue
        end

        % put time in ms, ninfo var name taken from old code?
        ninfo.msb = 1000* protocolInfo.(protocol).start;
        ninfo.mse = 1000* protocolInfo.(protocol).end;  
        fileprefix=[ subjphysiosavedir '/' protocol ]; 
        %set options
        Opt.Respfile   = [fileprefix '.resp.1D'];
        Opt.Cardfile   = [fileprefix '.puls.1D'];
        Opt.Prefix     = [fileprefix '_RetroTS'];
        Opt.VolTR      = protocolInfo.(protocol).Tr;
        Opt.ShowGraphs = 0; 

        fprintf('%s, tr=%f\n',fileprefix,protocolInfo.(protocol).Tr );

        for physio=fieldnames(physiofile)'
            
            %   TODO: find what is
            % killing the .puls/.resp files.
            % They are empty after the run
            %
            
            % grab the physio file we read in
            pinfo=physiofile.(physio{1});

            outpname = [fileprefix pinfo.typ];
            oftname  = [fileprefix pinfo.typ '.1D'];
            % create the physio file for this run
            chopph(ninfo, pinfo, outpname) ;

            % transpose for afni
            chopedTS = load(outpname);
            TChopedTS = transpose(chopedTS);
            dlmwrite(oftname, TChopedTS);
            
        end
        %rez.(protocol) = struct();
        try
         rez.(protocol).RTS=RetroTS(Opt);
        catch
         rez.(protocol).RTS='RetroTS fail';
        end
        rez.(protocol).physio=physiofile;
        rez.(protocol).Opt=Opt;
        rez.(protocol).protocolInfo=protocolInfo.(protocol);
        
    end
end