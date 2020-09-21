function [num1,num_1] = jpeg_hist(dct_coef)
[m,n] = size(dct_coef);
ac_arrays = zeros();
%%存储所有非零ac系数
t = 0;
for i = 1:m
    for j = 1:n
        if (mod(i,8) ~= 1) || (mod(j,8) ~= 1) %去掉dc系数
            if dct_coef(i,j) ~= 0 %排除为0 的ac系数
                t = t + 1;
                ac_arrays(t) =  dct_coef(i,j);%存储非零ac系数
            end
        end
    end
end
hist_info=tabulate(ac_arrays(:));%统计直方图
figure;bar(hist_info(:,1),hist_info(:,2),0.1);title('Histogram of all nonzero AC coefficients of the Lena image with QF = 80');
num1 = hist_info(find(hist_info(:,1)==1),2);
num_1 = hist_info(find(hist_info(:,1)== -1),2);
end