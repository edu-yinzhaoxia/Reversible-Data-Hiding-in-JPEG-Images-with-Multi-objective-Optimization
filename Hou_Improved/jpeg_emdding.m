 function [S_stego] = jpeg_emdding(Data,S,x)
 %函数功能：将秘密信息Data按照x选好的块来嵌入到载体S中
 %函数输入：秘密信息Data，载体S（原始DCT块），每块是否嵌入的标记x
 %函数输出：含有秘密信息的DCT块S_stego
 
 payload = length(Data);
 [M,N] = size(S);
 [m,n] = size(S{1,1});
%选择好哪些进行嵌入后，开始嵌入算法
numData = 1;
for i = 1:M
    if numData > payload
        break;
    end
    for j = 1:N
        if numData > payload
            break;
        end
        if x(i,j) == 1
        for ii = 1:m
            if numData > payload
                break;
            end
            for jj = 1:n
                if numData > payload
                    break;
                end
                %% 直方图平移嵌入
                 if S{i,j}(ii,jj) > 1
                     S{i,j}(ii,jj) = S{i,j}(ii,jj) + 1;
                 elseif S{i,j}(ii,jj) < -1
                     S{i,j}(ii,jj) = S{i,j}(ii,jj) - 1;
                 elseif S{i,j}(ii,jj) == 1
                      S{i,j}(ii,jj) = S{i,j}(ii,jj)+Data(numData); %嵌入数据
                      numData = numData + 1;
                 elseif S{i,j}(ii,jj) == -1 
                      S{i,j}(ii,jj) = S{i,j}(ii,jj)-Data(numData);
                      numData = numData + 1;
                 end               
            end
        end
        end
    end
end
S_stego = S;

end