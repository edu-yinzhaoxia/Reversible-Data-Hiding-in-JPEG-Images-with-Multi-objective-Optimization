function [ add,vd_distor] = get_psnring(simulate_dct,dct,jpeg_info)    %按照贪心算法产生嵌入序列
%函数的功能为按照贪心准则产生一个合适的嵌入序列
table = jpeg_info.quant_tables{1};
[m,n]=size(dct);
add=zeros(m,n);
distor=zeros(m,n);  %一共有m*n个块需要计算失真
vd_distor=zeros(m,n);  %计算VD失真
for i=1:m
    for j=1:n
        temp_1=dct{i,j};     %选择8×8的dct块
        temp_2=simulate_dct{i,j}; %选择模拟后8*8的块
        temp=table.*(temp_2-temp_1);            %乘以量化表的系数差
        pixel_d=IDCT(temp);                    %反变换空域——像素差
        distor(i,j)=sum(sum(pixel_d.^2));    %计算当前块失真
       vd_distor(i,j)=distor(i,j);%./counter_1(k);           %按照VD失真/像素
       %文件膨胀度计算
     	size2 = getcodelength( temp_1,jpeg_info );        
        size1 = getcodelength( temp_2,jpeg_info );
        if size2 == 0
        else
            add(i,j) = (size1 - size2);
        end
    end
end 
end

