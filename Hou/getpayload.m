 function payload = getpayload(S)
 [m,n] = size(S);
 payload=0;
 for i=1:m
    for j=1:n
        if mod(i,8) == 1 && mod(j,8) == 1
        elseif S(i,j) == 1 || S(i,j) == -1
            payload = payload + 1;
        end
    end
 end
        