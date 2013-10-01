function rez = getphinfo(fname)
    global USEMPCU % use old/bad timing
    cmd = [ 'tail -5 ' fname ' > mytmp.txt' ];

    system(cmd);

    alllines = readlines( 'mytmp.txt' );

    tnum = sscanf( alllines{5}, '%d');

    if( 6003 ~= tnum)
      disp('physio file corrupted, plesse check') %KH: some physio files seem to be corrupted and will not have proper ending
      rez = [];
      return;
    end

    LogStartLine=1;
    LogEndLine=2;
    if(USEMPCU==1)
        fprintf('WARNING: using MPCUTime instead of MDHTime, set USEMPCU=0 to undo\n');
        LogStartLine=3;
        LogEndLine=4;
    end
    tmp = textscan( alllines{LogStartLine}, '%s %d'); %KH: I changed to to capture LogStartMDHTime and LogendMDHTime, as LogStartMPCUTime of physio system seems off.
    rez.tb = tmp{2};	
    tmp = textscan( alllines{LogEndLine}, '%s %d');
    rez.te = tmp{2};


end