function [ order,vd_distor] = select_block2(simulate_dct,dct,table,counter_1)    %按照贪心算法产生嵌入序列
%函数的功能为按照贪心准则产生一个合适的嵌入序列
[m,n]=size(dct);
m=m/8;
n=n/8;
distor=zeros(1,m*n);  %一共有m*n个块需要计算失真
vd_distor=zeros(1,m*n);  %计算VD失真
%bd_distor=zeros(1,m*n);  %计算BD失真
k=0;
for i=1:m
    for j=1:n
        temp_1=dct(8*(i-1)+1:8*i,8*(j-1)+1:8*j);     %选择8×8的dct块
        temp_2=simulate_dct(8*(i-1)+1:8*i,8*(j-1)+1:8*j); %选择模拟后8*8的块
        temp=table.*(temp_2-temp_1);            %乘以量化表的系数差
        pixel_d=IDCT(temp);                    %反变换空域——像素差
         k=k+1;                                    %当前为几号块待计算
        distor(k)=sum(sum(pixel_d.^2));    %计算当前块失真
       vd_distor(k)=distor(k);%./counter_1(k);           %按照VD失真/像素
%        bd_distor(k)=counter_0(k)/counter_1(k);
    end
end
          
        
       
 %%%%%%%%%%%%%%%%%对distor进行排序,按嵌入信息量记录块索引%%%%%%%%%%%%%%
 [vd_distor,order]=sort(vd_distor);            %嵌入索引
% order=fliplr(order);                          %翻转，变成降序
 




        
        
        
        
      
        
    
end

