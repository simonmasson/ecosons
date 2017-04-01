%Writes a matrix to a PGM binary image
function matrix2PGM(M, imgF, min_v, max_v)

 %This limit can be changed according to the PNM standard
 % not too portable though
 maxGray=255;

 imgF=fopen(imgF, 'w');

 %PNM header: graymap
 fprintf(imgF, 'P5\n');
 fprintf(imgF, '#min_v=%g -> 1, max_v=%g -> %d, NaN set to 0\n', min_v, max_v, maxGray);
 fprintf(imgF, '%d %d\n', size(M,2), size(M,1));
 fprintf(imgF, '%d\n', maxGray);

 pnmArray=zeros(1,length(M));
 if( maxGray<256 )
  pfmt='uint8';
 else
  pfmt='uint16';
 endif

 M( M(:)<min_v ) = min_v;
 M( M(:)>max_v ) = max_v;
 M=M';
 mnan=isnan(M(:));

 pnmArray( ~mnan )=floor(1+(maxGray-1)*(M(~mnan)-min_v)/(max_v-min_v));
 pnmArray(  mnan )=0;
 
 fwrite(imgF, pnmArray, pfmt, 0, 'ieee-le');

 fclose(imgF);

endfunction
