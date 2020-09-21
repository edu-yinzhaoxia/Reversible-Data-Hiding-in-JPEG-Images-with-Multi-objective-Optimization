function [Pxy,Qxy,Qyx]=AnyDistortion(Px,Py,Dxy)



% m = 3;
% n = 3;
% Px = [0.5;1/3;0.5-1/3];
% Px0=Px;
% 
% Dxy=ones(m,n)-eye(m,n);    %Hamming distortion
% %This distortion matrix can be substituted by any other matrix
% 
% %给定失真
% %Dav=0.12;
% %[Py,Rav]=max_entropy_br_dav(Px,Dxy,Dav);
% 
% %给定嵌入率
% r=0.05;
% H_X=h(Px);
% [Py]=max_entropy_br(Px,Dxy,0);
% r_max=h(Py)-H_X;
% if(r>r_max)
%     disp('too large embedding rate');
% else
%      Hy=(r+H_X)*log(2);%求嵌入率对应的H(Y)，并用自然对数表示
%      Py=min_distortion_br(Px,Dxy,Hy);
% end
% 



epsilon = 1e-5;  %very small real number
B=size(Dxy,1);
m=B;
n=B;
Py0=Py;

%=====linear programming here beagin
A = zeros(m+n,m*n);
for i=1:m
    A(i,(i-1)*n+1:i*n) = 1;
end
for i=1:n
    for j=1:m
        A(i+m,(j-1)*n+i) = 1;
    end
end
b=[Px;Py];

f=[];
for i=1:m
    f = [f,Dxy(i,:)];
end
f = f';
lb=zeros(m*n,1);

x = linprog(f,[],[],A,b,lb);

Pxy=zeros(m,n);
for i=1:m
    Pxy(i,:) = x((i-1)*n+1:i*n,1);
end
%=====linear programming here done 

for s=0:(B-1)
    for y=0:(B-1)
        Qxy(s+1,y+1)= Pxy(s+1,y+1)/(Px(s+1)+eps);
        Qyx(s+1,y+1)= Pxy(s+1,y+1)/(Py(y+1)+eps);
    end
end
Qyx=Qyx';
end









