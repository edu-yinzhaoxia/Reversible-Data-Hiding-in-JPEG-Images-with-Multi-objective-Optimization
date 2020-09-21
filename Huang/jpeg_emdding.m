function [jpeg_info_stego] = jpeg_emdding(Data,oriBlockdct,jpeg_info,payload,zeronum)
jpeg_info_stego = jpeg_info;
[M,N] = size(oriBlockdct);
numData = 0;
flag=1;
for i = 1:M*N
    if flag==0
        break;
    end
    row=zeronum(i,1);
    col=zeronum(i,2);
    for j = 1:63
        if oriBlockdct{row,col}(j+1)==1
            numData = numData+1;
            oriBlockdct{row,col}(j+1)=oriBlockdct{row,col}(j+1)+Data(numData);            
        elseif oriBlockdct{row,col}(j+1)==-1
            numData = numData+1;
            oriBlockdct{row,col}(j+1)=oriBlockdct{row,col}(j+1)-Data(numData);           
        elseif oriBlockdct{row,col}(j+1)>1
            oriBlockdct{row,col}(j+1)=oriBlockdct{row,col}(j+1)+1;
        elseif oriBlockdct{row,col}(j+1)<-1
            oriBlockdct{row,col}(j+1)=oriBlockdct{row,col}(j+1)-1;
        end
        if(numData==payload)
            flag=0;
            break;
        end
    end
end
stegodct=cell2mat(oriBlockdct);
jpeg_info_stego.coef_arrays{1,1} = stegodct; %修改后的dct系数 写回 JPEG信息
end