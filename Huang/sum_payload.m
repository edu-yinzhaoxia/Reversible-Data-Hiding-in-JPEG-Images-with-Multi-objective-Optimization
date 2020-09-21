function [ sum_R ] = sum_payload( dct_coef )
%SUM_R 此处显示有关此函数的摘要
%   此处显示详细说明
[M,N] = size(dct_coef);
sum_R = 0;
for i = 1:M
    for j = 1:N
        if mod(i,8) == 1 && mod(j,8) == 1
        elseif dct_coef(i,j) == 1 || dct_coef(i,j) == -1
            sum_R = sum_R + 1;
        end
    end
end

end

