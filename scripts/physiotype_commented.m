%CV - Called by Pinfo to match and retrieve the 'type' of the physio data
%indicated by the end file extensions example *.puls for the patient's pulse

function rez=physiotype(fname)

rez.typ = '';
rez.nam = fname;


if( fname(end-4) == '.')
  if( strcmp( 'puls', fname(end-3:end)) )
    rez.typ = '.puls';
    rez.nam = fname(1:end-5);;
    return;
  end
  if( strcmp( 'resp', fname(end-3:end)) )
    rez.typ = '.resp';
    rez.nam = fname(1:end-5);;
    return;
  end
end

if( '.' == fname(end-3))
  if( strcmp( 'ext', fname(end-2:end)) )
    rez.typ = '.ext';
    rez.nam = fname(1:end-4);;
    return;
  end
  if( strcmp( 'ecg', fname(end-2:end)) )
    rez.typ = '.ecg';
    rez.nam = fname(1:end-4);;
    return;
  end
end



  
