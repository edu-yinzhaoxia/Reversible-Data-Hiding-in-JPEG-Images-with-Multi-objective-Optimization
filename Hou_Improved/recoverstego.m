function [ stego_dct] = recoverstego(dct,stego1_dct,sel_index)
%按照stego1_dct产生和dct产生最终的stego_dct
[m,n]=size(dct);
m=m/8;
n=n/8;
stego_dct=dct;
for i=1:m
    for j=1:n
        temp1=stego_dct(8*(i-1)+1:8*i,8*(j-1)+1:8*j);
        temp2=stego1_dct(8*(i-1)+1:8*i,8*(j-1)+1:8*j);         %选块
           for p=1:length(sel_index)                         %对块的嵌入位进行修改
                 row=ceil((sel_index(p)+1)/8);
                 col=mod(sel_index(p),8)+1;
                 temp1(row,col)=temp2(row,col);
           end
          stego_dct(8*(i-1)+1:8*i,8*(j-1)+1:8*j)=temp1;
    end
end
                           
end

