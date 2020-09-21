 function payload = getpayload_HS(S)
 [m,n] = size(S);
 payload=zeros(m,n);
 for i=1:m
    for j=1:n
        payload(i,j)=sum(sum(abs(S{i,j})==1)); %此块中为1的个数
%         payload(i,j)=sum(S{i,j}(:)~=0); %此块中不为0的个数        
        if abs(S{i,j}(1,1))==1
            payload(i,j)=payload(i,j)-1;
        end
    end
 end
        