function rez=readphval(fname, typ)

rez = [];

fd = fopen(fname, 'r');
C = textscan(fd, '%s', 'delimiter', '\n', 'bufSize', 2^24);
fclose(fd);


if( strcmp( '.ecg', typ ))
  %disp( 'is an ecg');
  rez.tau = 2.5; 
  rez.y = [];
  strt = strfind( C{1}{1}, '6002')
  ennd = strfind( C{1}{1}, '5003')

  if( isempty(strt) )
    return;
  end

  if( length(strt) > 1 )
    return;
  end

  if( isempty(ennd) )
    return;
  end
  
  if( (strt+5) >= (ennd-1) )
    return;
  end
  
  tmp = textscan( C{1}{1}(strt+5:ennd-1), '%d', 'delimiter', ' ' );
  fidx = ( tmp{1} < 5000);
  %   tmp2 = cumsum( ( fidx));
  %   rez.pts = tmp2(fidx);
  rez.y = double(tmp{1}(fidx));
  
end

if( strcmp( '.ext', typ ))
  %disp( 'is an ext');
  rez.tau = 5; 
  strt = length('1 2 40 280');
  ennd = strfind( C{1}{1}, '5003');
  tmp = textscan( C{1}{1}(strt+1:ennd-1), '%d', 'delimiter', ' ' );
  fidx = ( tmp{1} < 5000);
%   tmp2 = cumsum( ( fidx));
%   rez.pts = tmp2(fidx);
  rez.y = tmp{1}(fidx);
end

if( strcmp( '.puls', typ ))
  %disp( 'is an puls');
  rez.tau = 20; 
  strt = length('1 2 40 280');
  ennd = strfind( C{1}{1}, '5003');
  tmp = textscan( C{1}{1}(strt+1:ennd-1), '%d', 'delimiter', ' ' );
  fidx = ( tmp{1} < 5000);
%   tmp2 = cumsum( ( fidx));
%   rez.pts = tmp2(fidx);
  rez.y = tmp{1}(fidx);
  rez.yall = tmp{1}; % KH - to save all values including triggers (5000)
end

if( strcmp( '.resp', typ ))
  %disp( 'is an resp');
  rez.tau = 20; 
  strt = length('1 2 20 2');
  ennd = strfind( C{1}{1}, '5003');
  tmp = textscan( C{1}{1}(strt+1:ennd-1), '%d', 'delimiter', ' ' );
  fidx = ( tmp{1} < 5000);
%   tmp2 = cumsum( ( fidx));
%   rez.pts = tmp2(fidx);
  rez.y = tmp{1}(fidx);
  rez.yall = tmp{1};
end

  
