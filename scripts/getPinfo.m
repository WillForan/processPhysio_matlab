% -*-	mode: MATLAB; fill-column: 94;  -*-
% AUTHOR: Costin Tanase
% ------------------------------------------------------------------
function phinfo = getPinfo(physio_file)

% get the begin/end times from the physio-file (type independent)
phinfo = getphinfo(physio_file);

physio_types = { '.resp', '.puls', '.ecg', '.ext'};

rez = physiotype( physio_file);
phinfo.typ = rez.typ;
phinfo.nam = rez.nam;


return
