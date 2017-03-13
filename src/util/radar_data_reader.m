function [res, Data_Vector_c] = radar_data_reader(file_path_name,seekPosition,samplesPerSegment)
%
[file_id,~]=fopen(file_path_name,'r','l','UTF-8');

res=fseek(file_id,seekPosition,'bof');
if res == -1
        Data_Vector_c = [];
        close(file_id);
        return;
end
    

Data_Vec_Interleaved=fread(file_id,2*samplesPerSegment,'int16=>double');

DataIQ=reshape(Data_Vec_Interleaved.',2,[]).';
clear Data_Vec_Interleaved
% Note I&Q are switched
Data_Vector_c=complex(DataIQ(:,2),DataIQ(:,1));

clear DataIQ

fclose(file_id);



end