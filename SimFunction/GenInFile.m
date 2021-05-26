function []=GenInFile(SetParam,SSP,isdep,path_output)
cd(path_output);
ictr = 1;
icrv = 1;

fid = fopen('Gbm.in','w');
fprintf( fid , 'GBM test\n' );
fprintf( fid , '%4.1f %4.1f %4.1f\n' , [SetParam.fre SetParam.zs SetParam.zr(1)] );
fprintf( fid , '%4.1f %4.1f %4.1f\n' , [SetParam.rmax SetParam.ds SetParam.rdr] );
fprintf( fid , '%4.1f %4.1f %4.1f %d\n' , [SetParam.zmax SetParam.dz SetParam.bathdr ictr] );
fprintf( fid , '%d %4.1f %4.1f %4.1f\n' , [icrv SetParam.the1 SetParam.the2 SetParam.thei] );
fprintf( fid , '%4.1f %4.1f %4.1f %4.1f\n' , [SetParam.cdr SetParam.cz1 SetParam.cz2 SetParam.cdz] );

fprintf( fid , '%4.2f %4.2f\n' , [0:SetParam.rdr:SetParam.rmax ; SetParam.depth] );
fprintf( fid , '-1 -1\n');
fprintf( fid , '%4.2f %4.2f\n' , [SSP(1:length(find(SSP(:,2)~=0)),1) SSP(1:length(find(SSP(:,2)~=0)),2)]' );
fprintf( fid , '-1 -1\n');
fprintf( fid , '%4.1f\n%4.1f\n%4.1f\n' , [SetParam.cb(1) SetParam.thob(1) SetParam.alphab(1)] );

switch isdep
    case 'true'
    for i = 1 : 1 : SetParam.rmax/SetParam.rdr
        
        fprintf( fid , '%4f\n' , i*SetParam.rdr );
        fprintf( fid , '%4.2f %4.2f\n' , [SSP(1:length(find(SSP(:,i+2)~=0)),1) SSP(1:length(find(SSP(:,i+2)~=0)),i+2)]' );
        fprintf( fid , '-1 -1\n');
        fprintf( fid , '%4.1f\n%4.1f\n%4.1f\n' , [SetParam.cb(i+1) SetParam.thob(i+1) SetParam.alphab(i+1)] );
        
    end

    case 'false'   
end

fclose(fid);

end