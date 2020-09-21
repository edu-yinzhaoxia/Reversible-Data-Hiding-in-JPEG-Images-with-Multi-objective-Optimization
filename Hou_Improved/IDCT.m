function [pixel_d]=IDCT(Q)         % 对一个8*8的DCT块反变换
pixel_d=zeros(8);
for x=0:7
 for y=0:7
    temp=0;
       for u=0:7
           if u==0
           cu=1/(2^(0.5));
           else
           cu=1;
           end
          for v=0:7 
             if v==0
              cv=1/(2^(0.5));
             else
              cv=1;
             end    
                diff=cu*cv*Q(u+1,v+1)*cos((2*x+1)*u*pi/16 )*cos((2*y+1)*v*pi/16 ); 
              temp=temp+diff;
          end
        end
            pixel_d(x+1,y+1)=0.25*temp;
 end
end
pixel_d=double(pixel_d);

end