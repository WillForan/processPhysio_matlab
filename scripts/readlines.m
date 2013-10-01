function rez = readlines(inname, comment_str)

fid = fopen(inname, 'r');
C = textscan(fid, '%s', 'delimiter', '\n','bufSize',10^8);
rez1 = C{1};
fclose(fid);

if( isempty(rez1) )
  rez = rez1;
  return;
end


if( nargin > 1 )
  jj = 1;
  for ii=1:length(rez1)
    if( isempty( rez1{ii}) )
      continue;
    end
    if( comment_str == rez1{ii}(1) )
      continue;
    end
    rez{jj} = rez1{ii};
    jj = jj + 1;
  end
else
  rez = rez1(:);
end

  