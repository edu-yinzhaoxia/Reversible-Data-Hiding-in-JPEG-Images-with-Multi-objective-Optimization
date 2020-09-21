 function signal = getsignal(dct_coef)
 [m,n] = size(dct_coef);
 signal=cell(m/8,n/8);
 for i=1:8:m
    for j=1:8:n
        signal{fix(i/8)+1,fix(j/8)+1}=dct_coef(i:i+7,j:j+7);
    end
 end
        