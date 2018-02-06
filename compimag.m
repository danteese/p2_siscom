function o_ = compimag( name, format, umbral )
    % Processing of all practice 2
    %% Open and convert the image to 255 grayscale
    fullname_ = strcat( name, '.', format);
    imdata = imread(fullname_);
    imgv = rgb2gray(imdata);
    figure(1);
    imshow(imgv);
    title(fullname_);
    
    %% Entrophy
    % Calculate histogram
    prob = calculateHistogram(imgv);
    figure(2);
    values = min(imgv(:)):max(imgv(:));
    bar(values, prob);
    title('Histograma P(x)');
    
    % Calculate ammount of information
    % ** Remember: Sum of all the probabilities has to be 1.0
    e = calculateEntropy(prob);
    real = entropy(imgv);
    if floor(e) == floor(real)
        result = 'Son iguales';
    end
    if floor(e) ~= floor(real)
        result = 'Difieren';
    end
    result = strcat(result, " (BH):", num2str(e), " BITS., (Matlab):", num2str(real), " BITS.\n");
    fprintf(result);
    
    %% Crop image in blocks of 8x8 pixels and apply DCT
    
    % Use of blockproc from https://la.mathworks.com/matlabcentral/answers/119281-what-blkproc-i-8-8-dct2-means
    fun = @(block_struct) dct2(block_struct.data);
    b = blockproc(imgv,[8,8],fun);
    % Create mask 
    [r c] = find(abs(b) > 10);
    % Round to the nearest value and delete < 10
    b = round(b);
    b(abs(b) < 10) = 0;
    % Crop values
    b(b > 255) = 255;
    
    %% Calculate new entropy with new matrix
    figure(4)
    [counts, binLocations] = imhist(b);
    sum(counts.*log2(.1/counts))
    
%     b = abs(b);
%     r_freq = calculateHistogram(b);
%     figure(3);
%     dct_values = min(b(:)):max(b(:));
%     bar(dct_values, r_freq.*b);
%     title('Histograma P(x)');
%     n_entropy = calculateEntropy(r_freq);
    n_real = entropy(b);
    fprintf("DCT\n\tBy hand: %2.5f | Matlab: %2.5f\n", n_entropy, n_real);
    
    o_ = gray;
end

function relativeFrequency = calculateHistogram(imgv)
    % Get the relative frequency and plot
    values = min(imgv(:)):max(imgv(:));
    dist = histc(imgv(:), values);
    prob = dist / max(dist);
    relativeFrequency = prob;
end

function entropy = calculateEntropy(prob)
    % Get the probability of each point and returns the entropy of full image 
    tot_ = sum(prob); 
    prob = prob/tot_;
    innDist = 1./prob;
    l = log2( innDist );
    l(~isfinite(l)) = 0;
    I = prob.*l;
    entropy = sum(I);
end

%% Maybe used for the rect using imcrop
function rects = getRectsForCrop(sizeW, sizeL)
    coords = [];
    for m = 0:8:(sizeW-1)
        for n = 0:8:(sizeL-1)
            temp = [m,n,8,8];
            coords = vertcat(coords, temp);
        end     
    end
    rects = coords;
end