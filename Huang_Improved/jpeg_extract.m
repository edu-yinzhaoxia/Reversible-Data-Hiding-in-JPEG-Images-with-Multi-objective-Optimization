function [S_re,exD] = jpeg_extract(S,x,payload)
[m,n] = size(S);
exD = zeros(0); %存放提取的数据
numData = 1;
for i = 1:m
    if numData > payload
        break;
    end
    for j = 1:n
        if numData > payload
            break;
        end
        if x(i,j) == 1
            a = S{i,j}(1,1);
            S{i,j}(1,1) = 0;
            for ii = 1:8
                if numData > payload
                    break;
                end
                for jj = 1:8
                    if numData > payload
                        break;
                    end
                    if S{i,j}(ii,jj) == 1
                        exD(numData) = 0; %提取数据
                        numData = numData + 1;
                    elseif S{i,j}(ii,jj) == 2
                        exD(numData) = 1; %提取数据
                        S{i,j}(ii,jj) = S{i,j}(ii,jj) - 1;
                        numData = numData + 1;
                    elseif S{i,j}(ii,jj) > 2
                        S{i,j}(ii,jj) = S{i,j}(ii,jj) - 1;
                    elseif S{i,j}(ii,jj) == -1
                        exD(numData) = 0; %提取数据
                        numData = numData + 1;
                    elseif S{i,j}(ii,jj) == -2
                        exD(numData) = 1; %提取数据
                        S{i,j}(ii,jj) = S{i,j}(ii,jj) + 1;
                        numData = numData + 1;
                    elseif S{i,j}(ii,jj) < -2
                        S{i,j}(ii,jj) = S{i,j}(ii,jj) + 1;
                    end
                end
            end
            S{i,j}(1,1) = a;
        end
    end
end
S_re = S;

end