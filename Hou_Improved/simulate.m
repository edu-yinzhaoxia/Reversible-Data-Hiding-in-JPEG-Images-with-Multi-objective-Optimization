function [ shift_block] = simulate(dct_block )
[m,n]=size(dct_block);
m=m/8;
n=n/8;
shift_block=dct_block;
for i=1:m
    for j=1:n
     temp=dct_block(8*(i-1)+1:8*i,8*(j-1)+1:8*j);    
        for ii=1:8           %只修改一个块
             for jj=1:8
                     if (ii+jj>2)   %只修改AC位
                            if abs(temp(ii,jj))>1    %当前这一位大于1
                                temp(ii,jj)=temp(ii,jj)+sign(temp(ii,jj));  %按规则修改  
                            end
                            if abs(temp(ii,jj))==1               %当前这一位为1或者-1
                                temp(ii,jj)=temp(ii,jj)+sign(temp(ii,jj));    %按1进行嵌入
                            end
                            
                     end
             end
        end
         shift_block(8*(i-1)+1:8*i,8*(j-1)+1:8*j)=temp;
    end
end







        


end

