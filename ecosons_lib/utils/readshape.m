function [xyzs, shns] = readshape(fname)
  f=fopen(fname, 'rb');
  
  mgk=fread(f, 1, 'uint32', 'ieee-be');
  fread(f, 5, 'uint32');
  fsz=2*fread(f, 1, 'uint32', 'ieee-be');
  vsn=fread(f, 1, 'uint32', 'ieee-le');
  shp=fread(f, 1, 'uint32', 'ieee-le');
  
  xmin=fread(f, 1, 'double');
  xmax=fread(f, 1, 'double');
  ymin=fread(f, 1, 'double');
  ymax=fread(f, 1, 'double');
  fread(f, 4, 'double');
  
  xyzs=[];
  shns=[];
  shn=0;
  while( ftell(f) < fsz )
    shn=fread(f,1, 'uint32', 'ieee-be');
    lgt=fread(f,1, 'uint32', 'ieee-be');
    
    sty=fread(f,1, 'uint32', 'ieee-le');
    xyz=[];
    
    %!!disp(['sty: ' num2str( sty ) ', len: ' num2str(lgt)])
  
    switch(sty)
      case 0 %Null shape
        xyz=[0,0,0];
      case 1 %Point
        xyz=fread(f, 2, 'double');
      case {3,5} %PolyLine | Polygon
        bb=fread(f, 4, 'double');
        ne=fread(f,1, 'uint32', 'ieee-le');
        np=fread(f,1, 'uint32', 'ieee-le');
        i0s=fread(f,ne, 'uint32', 'ieee-le');
        xyz=reshape(fread(f,2*np, 'double'), [2,np])';
        ni=0;
        for i=1+i0s
          if( i>1)
            xyz(i+ni+1:end+1,:)=xyz(i+ni:end,:);
            xyz(i+ni,:)=NaN;
            ni=ni+1;
          endif
        endfor
      case 8 %MultiPoint
        bb=fread(f, 4, 'double');
        np=fread(f,1, 'uint32', 'ieee-le');
        xyz=reshape(fread(f,2*np, 'double'), [2,np])';
      case 11 %PointZ
        xyz=fread(f, 4, 'double');
      case {13,15} %PolyLineZ | PolygonZ
        bb=fread(f, 4, 'double');
        ne=fread(f,1, 'uint32', 'ieee-le');
        np=fread(f,1, 'uint32', 'ieee-le');
        i0s=fread(f,ne, 'uint32', 'ieee-le');
        xyz=reshape(fread(f,2*np, 'double'), [2,np])';
        bz=fread(f, 2, 'double');
        xyz(:,3)=fread(f,np, 'double');
        %!!disp(['lgt: ' num2str(2*lgt-4) ' >? ' num2str(4*(2*4+1+1+ne+2*2*np+2*2+2*np))])
        if( 2*lgt-4 > 4*(2*4+1+1+ne+2*2*np+2*2+2*np) ) %includes measure?
          bm=fread(f, 2, 'double');
          xyz(:,4)=fread(f,np, 'double')
        endif
        ni=0;
        for i=1+i0s
          if( i>1)
            xyz(i+ni+1:end+1,:)=xyz(i+ni:end,:);
            xyz(i+ni,:)=NaN;
            ni=ni+1;
          endif
        endfor
      case 18 %MultiPointZ
        bb=fread(f, 4, 'double');
        np=fread(f,1, 'uint32', 'ieee-le');
        xyz=reshape(fread(f,2*np, 'double'), [2,np])';
        bz=fread(f, 2, 'double');
        xyz(:,3)=fread(f, np, 'double');
        if( 2*lgt-4 > 4*(2*4+1+2*2*np+2*2+2*np) ) %includes measure?
          bm=fread(f, 2, 'double');
          xyz(:,4)=fread(f, np, 'double');
        endif
      case {21,25} %PolyLineM | PolygonM
        bb=fread(f, 4, 'double');
        ne=fread(f,1, 'uint32', 'ieee-le');
        np=fread(f,1, 'uint32', 'ieee-le');
        i0s=fread(f,ne, 'uint32', 'ieee-le');
        xyz=reshape(fread(f,2*np, 'double'), [2,np])';
        bm=fread(f, 2, 'double');
        xyz(:,3)=fread(f,np, 'double');
        ni=0;
        for i=1+i0s
          if( i>1)
            xyz(i+ni+1:end+1,:)=xyz(i+ni:end,:);
            xyz(i+ni,:)=NaN;
            ni=ni+1;
          endif
        endfor
      otherwise
        warning(['Unsupported shape: ' num2str(sty)])
        fseek(f, 2*lgt-4, 'cof');
    endswitch
  
    xyzs=[xyzs ; xyz];
    shns=[shns ; repmat(shn, [size(xyz,1),1])];

  endwhile

  fclose(f);

endfunction
