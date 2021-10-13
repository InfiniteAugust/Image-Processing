function task2main
img = imread('lena.jpg');

%distorted images by gaussian noise, salt and pepper noise and gaussian convolution 
figure;
subplot(3,6,1);
img_gau = gau_noise(img);
imshow(uint8(img_gau));
title('gaussian noise');
subplot(3,6,7);
img_snp = snp_noise(img);
imshow(img_snp);
title('salt and pepper noise');
subplot(3,6,13);
img_77 = gau77(img);
imshow(uint8(img_77));
title('gaussian convolution');

%apply all filters to Gaussian noise 
subplot(3,6,2);
imshow(uint8(mean_filter(img_gau)));
title('guassian noise after mean filter');
subplot(3,6,3);
imshow(uint8(gaussian(img_gau)));
title('gussian after gaussian smoothing');
subplot(3,6,4);
imshow(uint8(median_filter(img_gau)));
title('guassian after median filter');
subplot(3,6,5);
imshow(uint8(anisotropic(img_gau)));
title('gaussian after anisotropic');
subplot(3,6,6);
imshow(uint8(bilateral(img_gau)));
title('gaussian after bilateral');

%apply all filters to salt and pepper noise
subplot(3,6,8);
imshow(uint8(mean_filter(img_snp)));
title('snp noise after mean filter');
subplot(3,6,9);
imshow(uint8(gaussian(img_snp)));
title('snp noise after gaussian smoothing');
subplot(3,6,10);
imshow(uint8(median_filter(img_snp)));
title('snp noise after median filter');
subplot(3,6,11);
imshow(uint8(anisotropic(img_snp)));
title('snp noise after anisotropic');
subplot(3,6,12);
imshow(uint8(bilateral(img_snp)));
title('snp noise after bilateral');

%apply all filters to Gaussian convolution 
subplot(3,6,14);
imshow(uint8(mean_filter(img_77)));
title('gau77 after mean filter');
subplot(3,6,15);
imshow(uint8(gaussian(img_77)));
title('gau77 after gaussian smoothing');
subplot(3,6,16);
imshow(uint8(median_filter(img_77)));
title('gau77 after median filter');
subplot(3,6,17);
imshow(uint8(anisotropic(img_77)));
title('gau77 after anisotropic');
subplot(3,6,18);
imshow(uint8(bilateral(img_77)));
title('gau77 after bilateral');


%3×3 mean filter
function img_mean = mean_filter(img)
mean_filter = [1 1 1; 1 1 1; 1 1 1]/9;
R = img(:,:,1);
G = img(:,:,2);
B = img(:,:,3);
img_mean(:,:,1) = conv2(R, mean_filter, 'same');
img_mean(:,:,2) = conv2(G, mean_filter, 'same');
img_mean(:,:,3) = conv2(B, mean_filter, 'same');

%5×5 Gaussian filter with sigma=1
function img_gau = gaussian(img)
gau_filter = fspecial('gaussian',[5,5],1);
R = img(:,:,1);
G = img(:,:,2);
B = img(:,:,3);
img_gau(:,:,1) = conv2(R, gau_filter, 'same');
img_gau(:,:,2) = conv2(G, gau_filter, 'same');
img_gau(:,:,3) = conv2(B, gau_filter, 'same');

%3×3 median filter
%local_windowX is 3*3-size neighbors for each pixel 
function img_med = median_filter(img)
R = img(:,:,1);
G = img(:,:,2);
B = img(:,:,3);
dim = size(R);

for i = 2 : dim(1)-1
    for j = 2 : dim(2)-1
        x1 = i-1; x2 = i+1; y1 = j-1; y2 = j+1;
        local_windowR = R(x1:x2, y1:y2);
        R(i, j) = median(median(local_windowR));
        
        local_windowG = G(x1:x2, y1:y2);
        G(i, j) = median(median(local_windowG));
        
        local_windowB = B(x1:x2, y1:y2);
        B(i, j) = median(median(local_windowB));
    end 
end
img_med(:,:,1) = R;
img_med(:,:,2) = G;
img_med(:,:,3) = B;


%3×3 anisotropic filter with the similarity function of 1-d/(D+c)
%localX is 3*3-size neighbors for each pixel 
%d is intensity difference, D is the maximum among them
%sX is the similarity function
function img_ani = anisotropic(img)
R = img(:,:,1);
G = img(:,:,2);
B = img(:,:,3);
dim = size(R);
c = 1e-50;
for i = 2 : dim(1)-1
    for j = 2 : dim(2)-1
        x1 = i-1; x2 = i+1; y1 = j-1; y2 = j+1;
        
        localR = R(x1:x2, y1:y2);
        d = abs(R(i,j)-localR);
        D = max(max(d));
        sR = 1-d/(D+c);
        R(i,j) = sum(sum(sR.*localR)) / sum(sum(sR));
        
        localG = G(x1:x2, y1:y2);
        d = abs(G(i,j)-localG);
        D = max(max(d));
        sG = 1-d/(D+c);
        G(i,j) = sum(sum(sG.*localG)) / sum(sum(sG));
        
        localB = B(x1:x2, y1:y2);
        d = abs(B(i,j)-localB);
        D = max(max(d));
        sB = 1-d/(D+c);
        B(i,j) = sum(sum(sB.*localB)) / sum(sum(sB));
    end
end
img_ani(:,:,1) = R;
img_ani(:,:,2) = G;
img_ani(:,:,3) = B;

%5×5 bilateral filter
%localX is 3*3-size neighbors for each pixel 
%ranegX is the matrix after applying range Gaussian function
%normX is the normalization factor
function img_bilat = bilateral(img)
R = double(img(:,:,1));
G = double(img(:,:,2));
B = double(img(:,:,3));
sigma = 10.0;
[M, N] = size(R);
gau_filter = fspecial('gaussian',[5,5],1);

for i = 3 : M-2
    for j = 3 : N-2
        x1 = i-2; x2 = i+2; y1 = j-2; y2 = j+2;
        
        localR = double(R(x1:x2, y1:y2)); 
        range1 = exp(-((localR-R(i,j)).^2)/(2*sigma^2)); 
        normR = double(sum(sum((localR.*gau_filter).*range1)));  
        R(i,j) = double(sum(sum(localR.*gau_filter.*range1.*localR))/normR);
        
        localG = double(G(x1:x2, y1:y2));
        range2 = exp(-((localG-G(i,j)).^2)/(2*sigma^2)); 
        normG = double(sum(sum(localG.*gau_filter.*range2))); 
        G(i,j) = double(sum(sum(localG.*gau_filter.*range2.*localG))/normG);
        
        localB = double(B(x1:x2, y1:y2));
        range3 = exp(-((localB-B(i,j)).^2)/(2*sigma^2)); 
        normB = double(sum(sum(localB.*gau_filter.*range3)));
        B(i,j) = double(sum(sum(localB.*gau_filter.*range3.*localB))/normB);
    end
end
img_bilat(:,:,1) = uint8(R);
img_bilat(:,:,2) = uint8(G);
img_bilat(:,:,3) = uint8(B);
        

%%Gaussian noise with sigma=20 on RGB channels of lena.jpg
function noise_gau = gau_noise(img)
R = img(:,:,1);
G = img(:,:,2);
B = img(:,:,3);
img_size = size(R);

sigma = 20;
noise = randn(img_size)*sigma;
noise_gau(:,:,1) = double(R)+noise;
noise_gau(:,:,2) = double(G)+noise;
noise_gau(:,:,3) = double(B)+noise;

%%10% of salt & pepper noise on RGB channels of lena.jpg
function noise_snp = snp_noise(img)
R = img(:,:,1);
G = img(:,:,2);
B = img(:,:,3);
noise_snp(:,:,1) = imnoise(R,'salt & pepper',0.1);
noise_snp(:,:,2) = imnoise(G,'salt & pepper',0.1);
noise_snp(:,:,3) = imnoise(B,'salt & pepper',0.1);

%%Convolute each of RGB channels of lena.jpg with a 7×7 Gaussian filter with sigma=2
function gau = gau77(img)
gau_filter = fspecial('gaussian',[7,7],2);
R = img(:,:,1);
G = img(:,:,2);
B = img(:,:,3);
gau(:,:,1) = conv2(R, gau_filter, 'same');
gau(:,:,2) = conv2(G, gau_filter, 'same');
gau(:,:,3) = conv2(B, gau_filter, 'same');
