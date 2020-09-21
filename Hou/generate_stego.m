function [ stego_dct,tag] = generate_stego(order,dct,embed,msslen)
%通过嵌入序列和随机产生的嵌入信息产生隐写图片
[m,n]=size(dct);
m=m/8;
n=n/8;
select_num=length(order);
s=0;
t=0;
tag=1;                         %标志是否还要嵌入比特
stego_dct=dct;
useful_block=zeros(8*select_num,8);
for i=1:select_num
    k=order(i);
    col=mod(k-1,n)+1; 
    row=floor((k-1)/n)+1;
    temp=dct(8*(row-1)+1:8*row,8*(col-1)+1:8*col);
     for ii=1:8
         for jj=1:8
                   if (ii+jj>2)                 %排除DC系数
                            if abs(temp(ii,jj))>1
                                t=t+1;           
                                temp(ii,jj)=temp(ii,jj)+sign(temp(ii,jj));    
                            end
                            if tag&&abs(temp(ii,jj))==1
                                s=s+1;
                                temp(ii,jj)=temp(ii,jj)+embed(1,s)*sign(temp(ii,jj)); 
                                if s==msslen
                                    tag=0;
                                end
                            end
                   end
          end
      end
if tag==0
         useful_block(8*(i-1)+1:8*i,1:8)=temp;
         break;
else
         useful_block(8*(i-1)+1:8*i,1:8)=temp;
end
end
for p=1:select_num
    k=order(p);
    row=floor((k-1)/n)+1;
    col=mod(k-1,n)+1; 
    stego_dct(8*(row-1)+1:8*row,8*(col-1)+1:8*col)=useful_block(8*(p-1)+1:8*p,1:8);
end
end