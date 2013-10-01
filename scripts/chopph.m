function pdat = chopph(ninfo, pinfo, outppname, offst)

xtra = 0;
if( nargin > 3)
  xtra = offst;
end


% now take each physio and chop it for each MRI
% only the MRI's completelly immerssed in a physio are considered
  
% if not fully immersed in the physio, skip it
if( ninfo.msb < pinfo.tb )
  disp('exiting because: ninfo.msb < pinfo.tb. Physio started before imaging acquisition!?!?');
  return;
end

if( ninfo.mse > pinfo.te )
  disp('exiting because: ninfo.mse > pinfo.te. Physio ended before imaging acquisition ended?!?!');
  return;
  %ninfo.mse=pinfo.te-20000		%KH:just for testing, do not use for REAL analyses
  %ninfo.msb=ninfo.mse-300000	%KH:just for testing, don not use for REAL analyses
  
  
  
end

% find the pos in the physio stream
posb = round((ninfo.msb - pinfo.tb)/pinfo.tau) ;

if( posb < 1 )
  posb = 1;
end

pose = posb + round((ninfo.mse - ninfo.msb)/pinfo.tau);
posb;
pose;
tsteps=round((ninfo.mse-ninfo.msb)/pinfo.tau);
yl=length(pinfo.y);
    
if( pose > length(pinfo.y) )
  pose = length(pinfo.y);
end
    
% physio dat pts indices  KH - how many samples in physio data
idx = 1:(pose - posb + 1);
  
% physio time  KH - length of the window
t = double(pinfo.tau) * double(idx-1.);
  
% physiodata
y = pinfo.y(posb + idx);

y_temp=y(1:512);
t_temp=t(1:512);

%figure();
%plot(t,y);
%figure();
%plot(t_temp,y_temp);


fid = fopen(outppname, 'w');
for kk=1:length(y)
  fprintf(fid, '%12.3f, %6d\n', y(kk));
end
fclose(fid);
      
    
  
return
