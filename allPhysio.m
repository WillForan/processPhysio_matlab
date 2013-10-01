%
% Wrapper for getphysio, which is itself a wrapper for physio_proc_wallace
% see comments in physio_proc_wallace.m
%
% Given a study name
%  * find all subjects that still need physio
%  * send each to getphysio.m
%  * return an object for each subject
%
%
function rez = allPhysio(study)
    sdvdsep='/';
    %sdvdsep='_';
    %if(strcmp(study,'Reward')); sdvdsep='/'; end;

    phys=['/data/Luna1/Raw/Physio/organized/' study '/'];
    procdir=['/data/Luna1/' study '/Physio/' ];
    fprintf('%s\n\t->\n%s\n',phys,procdir);
    
    %if(strcmp(study,'MultiModal')); procdir='/data/Luna1/Multimodal/Physio/';end;
    
    for dirtest={phys; procdir}
        if(~exist(dirtest{1},'dir'))
            error('allPhysio:filecheck','%s DNE\n',dirtest{1})
        end
    end
    
    for sd=dir(phys)'; 
        if(regexp(sd.name,'\.')); continue; end; 
        for vd=dir([phys '/' sd.name])'; 
            % skip . and ..
            if(regexp([sd.name vd.name],'\.')); continue; end; 
            
            % skip if already have parsed physio
            sdvd_procdir=[ procdir '/' sd.name sdvdsep vd.name ];
            if(exist( sdvd_procdir, 'dir')); continue;  end
            
            % build list of 'subjdir/visitdir'
            subj=sd.name;
            visit=vd.name;
            fprintf('run %s%s%s\n',subj,sdvdsep,visit);
            %fprintf(' getphysio(%s,%s,%s)\n',subj,visit,study);
              try 
                 rez.(['s' subj '_' visit]) = getphysio(subj,visit,study);
              catch
                 rez.(['s' subj '_' visit]) = 'fail';
              end;
        end;
    end
end

