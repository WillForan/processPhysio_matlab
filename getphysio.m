%
% Wrapper for physio_proc_wallace, see comments there
%  give subj, date, and studyname (stdnm) 
%  and it will write out physio for each group
%
%

function rez=getphysio(subj,date,stdnm)
    %global USEMPCU; 
    %USEMPCU=0;
    %%% there are two time stamps in phys, set to 1 to use
    %%% the one NOT recommened, otherwise we'll use what we should
  
    %addpath('scripts/'); % use local scirpt functions, not the ones in
                          % nitools

    for studyname={'Reward','MultiModal','WorkingMemory'}
        studyname=studyname{1}; 
        study.(studyname).savdir  = ['/data/Luna1/' studyname '/Physio/' subj '/' date '/'];
        study.(studyname).physdir = ['/data/Luna1/Raw/Physio/organized/' studyname '/' subj '/' date '/'];

        % Reward has funny raw name:
        if(strcmp(studyname,'Reward')); 
            study.(studyname).dcmdir  = ['/data/Luna1/Raw/MRRC_Org/' subj '/' date '/'];
        else
            study.(studyname).dcmdir  = ['/data/Luna1/Raw/' studyname '/' subj '_' date '/'];
        end

    end
    
    %fprintf('  physio_proc_walalce(''%s'',''%s'',''%s'')\n',...
    %        study.(stdnm).dcmdir,study.(stdnm).physdir,study.(stdnm).savdir);
        
    rez=physio_proc_wallace(study.(stdnm).dcmdir,  ...
                            study.(stdnm).physdir, ...
                            study.(stdnm).savdir); 


end