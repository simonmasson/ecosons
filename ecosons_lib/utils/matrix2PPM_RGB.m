%Writes three matrices to a PPM image
function matrix2PPM_RGB(Mr, Mg, Mb, imgF, min_v, max_v)

 %This limit can be changed according to the PNM standard
 % not too portable though
 maxGray=255;

 imgF=fopen(imgF, 'w');

 %PNM header: graymap
 fprintf(imgF, 'P6\n');
 fprintf(imgF, '#min_v=%g -> 1, max_v=%g -> %d, NaN set to 0\n', min_v, max_v, maxGray);
 fprintf(imgF, '%d %d\n', size(Mr,2), size(Mr,1));
 fprintf(imgF, '%d\n', maxGray);

 pnmArray=zeros(3,length(Mr(:)));
 if( maxGray<256 )
  pfmt='uint8';
 else
  pfmt='uint16';
 endif

 %transpose to fit memory representation
 Mr( Mr(:)<min_v ) = min_v;
 Mr( Mr(:)>max_v ) = max_v;
 Mr=Mr';
 mrnan=isnan(Mr(:));
 Mg( Mg(:)<min_v ) = min_v;
 Mg( Mg(:)>max_v ) = max_v;
 Mg=Mg';
 mgnan=isnan(Mg(:));
 Mb( Mb(:)<min_v ) = min_v;
 Mb( Mb(:)>max_v ) = max_v;
 Mb=Mb';
 mbnan=isnan(Mb(:));

 pnmArray(1, ~mrnan )=floor(1+(maxGray-1)*(Mr(~mrnan)-min_v)/(max_v-min_v));
 pnmArray(1, mrnan )=0;
 pnmArray(2, ~mgnan )=floor(1+(maxGray-1)*(Mg(~mgnan)-min_v)/(max_v-min_v));
 pnmArray(2, mgnan )=0;
 pnmArray(3, ~mbnan )=floor(1+(maxGray-1)*(Mb(~mbnan)-min_v)/(max_v-min_v));
 pnmArray(3, mbnan )=0;

 fwrite(imgF, pnmArray, pfmt, 0, 'ieee-le');

 fclose(imgF);

endfunction
