function [add,Dis] = getadd_psnr_HS(S,R,jpeg_info)
Q = jpeg_info.quant_tables{1,1};%获取量化表

[m,n] = size(S);
add = zeros(m,n);
Dis = zeros(m,n);
SS = S;
for i = 1:m
    for j = 1:n
        numData = 1;
        a = S{i,j}(1,1);
        Data = round(rand(1,R(i,j))*1);
        S{i,j}(1,1) = 0;
        for ii = 1:8
            for jj = 1:8
                 if S{i,j}(ii,jj) > 1
                      S{i,j}(ii,jj) = S{i,j}(ii,jj) + 1; %平移
                 elseif S{i,j}(ii,jj) < -1 
                      S{i,j}(ii,jj) = S{i,j}(ii,jj) - 1; %平移
                 elseif S{i,j}(ii,jj) == 1
                     S{i,j}(ii,jj) = S{i,j}(ii,jj) + Data(numData);
                     numData = numData + 1;
                 elseif S{i,j}(ii,jj) == -1
                     S{i,j}(ii,jj) = S{i,j}(ii,jj) - Data(numData);
                      numData = numData + 1;
                 end
            end
        end
        S{i,j}(1,1) = a;
        temp = (S{i,j}-SS{i,j}).*Q;
        pixel_d=IDCT(temp);                    %反变换空域——像素差
        Dis(i,j)=sum(sum(pixel_d.^2));    %计算当前块失真
        %文件膨胀度计算
        size1 = getcodelength( S{i,j},jpeg_info );
     	size2 = getcodelength( SS{i,j},jpeg_info );
        if size2 == 0
        else
            add(i,j) = (size1 - size2);%
        end
    end
end
end