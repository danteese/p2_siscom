function compimag(name, format, umbral)

    file = strcat( name, '.', format);
    original = imread(file);
    grayScale = rgb2gray(original);

    showImage(grayScale,file,1,1);
    
    probability1 = getProbability(grayScale);
    
    e1 = getEntropy(probability1);
    
    compressedImage = zipImage(grayScale,umbral);
    
    probability2 = getProbability(compressedImage);
    
    e2 = getEntropy(probability2);
    
    showImage(compressedImage,"Compressed Image",1,2);
    
    decompressedImage = unzipImage(compressedImage);
    
    showImage(decompressedImage,"Uncompressed Image",1,3);
    
    clc;
    fprintf("Entropia 1: %d\n", e1);
    fprintf("Entropia 1 matlab: %d\n", entropy(grayScale));
    fprintf("Entropia 2: %d\n", e2);
    fprintf("Entropia 2 matlab: %d\n", entropy(compressedImage));
    
    fprintf("El error es: %f\n", getError(decompressedImage, grayScale));
    
    fprintf("Porcentaje de compresión: %f\n", getPercentage(decompressedImage, grayScale, umbral));
  
end

function percomp = getPercentage(decompressedImage, grayScale, umbral)

    mask2 = decompressedImage;
    mask2(abs(mask2) < umbral) = 1;
    mask2(abs(mask2) >= umbral) = 0;
   
    s2 = sum(sum(mask2));
    
    t = length(grayScale(:));
    percomp = (1 - ((t - s2)/t)) * 100;

end

function err = getError(decompressedImage, grayScale)

    emc = immse(decompressedImage, grayScale);
    pot = sum(sum(decompressedImage.^2));
    err = (emc /pot) * 100;

end

function showImage(image,tit,fig,sub)
    
    figure(fig);
    subplot(2,2,sub);
    imshow(image);
    title(tit)

end

function newImage = unzipImage(image)

    fun = @(block_struct) idct2(block_struct.data);
    newImage = uint8(blockproc(image,[8,8],fun));

end

function newImage = zipImage(image,umbral)

    fun = @(block_struct) dct2(block_struct.data);
    newImage = round(blockproc(image,[8,8],fun));
    newImage(abs(newImage) < umbral) = 0;
   
end

function entropy = getEntropy(probability)

    probability = probability/sum(probability);
    I = log2(1./probability).*probability;
    I(~isfinite(I)) = 0;
    entropy = sum(I);
    
end

function probability = getProbability(image)

    histogram = imhist(image);
    probability = histogram / max(histogram);
    
end
