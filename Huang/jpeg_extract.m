function [re_jpeg_info,extData] = jpeg_extract(stego_jpeg_info,payload,zeronum)
oridct = stego_jpeg_info.coef_arrays{1,1}; %获取载密图像的dct系数
[M,N] = size(oridct);
dct_coef = mat2cell(oridct,8 * ones(1,M/8),8 * ones(1,N/8)); %把原来的图像矩阵分割成N个8*8的Block
[M,N] = size(dct_coef);
numData = 0;
extData = zeros();
flag = 1;
for i = 1:M*N
    if flag==0
        break;
    end
    row=zeronum(i,1);
    col=zeronum(i,2);
    for j = 1:63
        if dct_coef{row,col}(j+1)==1
            numData = numData+1;
            extData(numData) = 0;
        elseif dct_coef{row,col}(j+1)==2
            numData = numData+1;
            extData(numData) = 1;
            dct_coef{row,col}(j+1)=dct_coef{row,col}(j+1)-1;
        elseif dct_coef{row,col}(j+1)==-1
            numData = numData+1;
            extData(numData) = 0;
        elseif dct_coef{row,col}(j+1)==-2
            numData = numData+1;
            extData(numData) = 1;
            dct_coef{row,col}(j+1)=dct_coef{row,col}(j+1)+1;
        elseif dct_coef{row,col}(j+1)>2
            dct_coef{row,col}(j+1)=dct_coef{row,col}(j+1)-1;
        elseif dct_coef{row,col}(j+1)<-2
            dct_coef{row,col}(j+1)=dct_coef{row,col}(j+1)+1;
        end
        if(numData==payload)
            flag=0;
            break;
        end
    end
end
re_jpeg_info = stego_jpeg_info;
re_jpeg_info.coef_arrays{1,1} = cell2mat(dct_coef); 

end