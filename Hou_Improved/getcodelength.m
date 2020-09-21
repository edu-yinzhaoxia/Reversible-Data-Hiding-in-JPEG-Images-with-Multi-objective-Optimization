function [ block_size ] = getcodelength( quantized_image,jpeg_info )
%GETCODELENGTH 一块的编码
%   此处显示详细说明


ZigZag_Order = uint8([
            1  9  2  3  10 17 25 18
            11 4  5  12 19 26 33 41
            34 27 20 13 6  7  14 21 
            28 35 42 49 57 50 43 36 
            29 22 15 8  16 23 30 37
            44 51 58 59 52 45 38 31 
            24 32 39 46 53 60 61 54 
            47 40 48 55 62 63 56 64]);
% Break 8x8 block into columns
Single_column_quantized_image=im2col(quantized_image, [8 8],'distinct');
%--------------------------- zigzag ----------------------------------
% using the MatLab Matrix indexing power (specially the ':' operator) rather than any function
ZigZaged_Single_Column_Image=Single_column_quantized_image(ZigZag_Order',:);
    %---------------------- Run Level Coding -----------------------------
    % construct Run Level Pair from ZigZaged_Single_Column_Image
    run_level_pairs=zeros(0);
%     [M,N] = size(Single_column_quantized_image);
    for block_index=1:1    %block by block - total 256 blocks (8x8) in the 128x128 image
        single_block_image_vector_64(1:64)=0;
        for Temp_Vector_Index=1:64
            single_block_image_vector_64(Temp_Vector_Index) = ZigZaged_Single_Column_Image(Temp_Vector_Index, block_index);  %select 1 block sequentially from the ZigZaged_Single_Column_Image
        end
        non_zero_value_index_array = find(single_block_image_vector_64~=0); % index array of next non-zero entry in a block
        if isempty(non_zero_value_index_array)
            block_size = 0;
            return;
        end
        number_of_non_zero_entries = length(non_zero_value_index_array);  % # of non-zero entries in a block

    % Case 1: if first ac coefficient has no leading zeros then encode first coefficient
        if non_zero_value_index_array(1)==1  
           run=0;   % no leading zero
            run_level_pairs=cat(1,run_level_pairs, run, single_block_image_vector_64(non_zero_value_index_array(1)));
        end

    % Case 2: loop through each non-zero entry    
        for n=2:number_of_non_zero_entries
            % check # of leading zeros (run)
            run=non_zero_value_index_array(n)-non_zero_value_index_array(n-1)-1;
            run_level_pairs=cat(1, run_level_pairs, run, single_block_image_vector_64(non_zero_value_index_array(n)));
        end
        
    % Case 3: "End of Block" mark insertion
%         run_level_pairs=cat(1, run_level_pairs, 255, 255);%cat(1,A,B)将A,B上下拼接
    end
    %---------------------------------------------------------------------
    % 分为VLC和RLV部分
    length_ac = length(run_level_pairs);
    VLC = zeros(0); %存放中间形式
    length_RLV = 0; %RLV的长度
    for i = 4:2:length_ac
        flag = 1;
        k = 0;
        while(flag)
            x = abs(run_level_pairs(i));
            k = k + 1;
            if x >= power(2,k-1) && x <= power(2,k)-1
                flag = 0;
            end
        end
        if run_level_pairs(i-1) > 15
            if run_level_pairs(i-1) > 31
                if run_level_pairs(i-1) > 47
                    VLC = [VLC,15,0,15,0,15,0,run_level_pairs(i-1)-48,k];
                else
                    VLC = [VLC,15,0,15,0,run_level_pairs(i-1)-32,k];
                end
            else
                VLC = [VLC,15,0,run_level_pairs(i-1)-16,k];
            end
        else            
            VLC = [VLC,run_level_pairs(i-1),k];
        end
        length_RLV = length_RLV + k;
    end
    %将中间形式按十六进制转换为十进制
    VLC_10 = zeros(0);
    length_vlc = length(VLC);
    for i = 1:2:length_vlc
        x = VLC(i)*16 + VLC(i+1);
        VLC_10 = [VLC_10,x];
    end
    %从ACHuffman表中查找长度
    AC_Huffman = jpeg_info.ac_huff_tables;
    counts = AC_Huffman.counts;
    symbols = AC_Huffman.symbols;
    %求counts的累加和
    sum_counts = cumsum(counts);
    length_vlc_10 = length(VLC_10);
    length_VLC = 0; %记录AC系数VLC的长度
    for i = 1:length_vlc_10
        x = find(symbols == VLC_10(i));
        if isempty(x)
            x
        end
        pos_symbols = min(x(:));
        x = find(sum_counts >= pos_symbols );
        if isempty(x)
            x
        end
        pos_counts = min(x(:));
        length_VLC = length_VLC + pos_counts;
    end
    block_size = length_VLC + length_RLV;

    %     Compressed_image_size=length(run_level_pairs);        % file size after compression

end

