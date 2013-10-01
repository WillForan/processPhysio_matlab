function rez = tstr2sec(tstr)
if( 1 == isstr( tstr) )
  rez = str2num(tstr(1:2))*3600+str2num(tstr(3:4))*60+str2num(tstr(5:6))+...
        str2num(tstr(8:10))/1000;
  return
end

if( 1 == iscell( tstr) )
  for kk=1:length(tstr)
    tempstr = tstr{kk};
    rez(kk) = str2num(tempstr(1:2))*3600+str2num(tempstr(3:4))*60+str2num(tempstr(5:6))+...
        str2num(tempstr(8:10))/1000;
  end
  return
end


    
    
