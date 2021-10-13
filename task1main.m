function task1main
img1 = imread('face1.jpg');
img2 = imread('face2.jpg');
model = getFaceModel();
figure;
subplot(2,3,1);
imshow(img1);
title('original image 1');
subplot(2,3,4);
imshow(img2);
title('original image 2');

img1 = rgb2hsv(img1);
Bi1 = getBiFaceImg(img1, model);
final1 = getMorphFace(Bi1);
subplot(2,3,2);
imshow(Bi1);
title('binary image 1');
subplot(2,3,3);
imshow(final1);
title('morphological image 1');

img2 = rgb2hsv(img2);
Bi2 = getBiFaceImg(img2, model);
final2 = getMorphFace(Bi2);
subplot(2,3,5);
imshow(Bi2);
title('binary image 2');
subplot(2,3,6);
imshow(final2);
title('morphological image 2');



function faceModel = getFaceModel()

%for the first image
img1 = rgb2hsv(imread('1.png'));
H1 = img1(:,:,1);
S1 = img1(:,:,2);
%for the second image
img2 = rgb2hsv(imread('2.png'));
H2 = img2(:,:,1);
S2 = img2(:,:,2);
%for the fourth iamge 
img4 = rgb2hsv(imread('4.png'));
H4 = img4(:,:,1);
S4 = img4(:,:,2);
%get the histgram of all images 
hs_H = hist(H1(:),100) + hist(H2(:),100) + hist(H4(:),100);
hs_S = hist(S1(:),100) + hist(S2(:),100) + hist(S4(:),100);
size_of_H = sum(hs_H);
size_of_S = sum(hs_S);
%eliminate the white pixels 
hs_H(1,1) = 0;
hs_S(1,1) = 0;
%based on the histogram, roughly get the range 
H_start = 5; H_end = 5;
S_start = 30; S_end = 30;
sum_of_S = sum(hs_S(1, S_start:S_end));
sum_of_H = sum(hs_H(1, H_start:H_end));
% for both H and S, enlarge the range of model if the pixels being covered deosn't 0.8 of the total
while sum_of_H < 0.8*size_of_H
    if H_start == 1
        break
    end
    H_start = H_start - 1;
    H_end = H_end + 1;
    sum_of_H = sum_of_H + hs_H(1,H_start) + hs_H(1,H_end);
end
while sum_of_S < 0.8*size_of_S
    if S_start == 1
        break
    end
    S_start = S_start - 1;
    S_end = S_end + 1;
    sum_of_S = sum_of_S + hs_S(1,S_start) + hs_S(1,S_end);
end
H_start = H_start/hs_H(2);
H_end = H_end/hs_H(2);
S_start = S_start/hs_S(2);
S_end = S_end/hs_S(2);

faceModel = [H_start H_end S_start S_end];


%binarized image where white pixels denote the face and black pixels denote background.
function BiFaceImg = getBiFaceImg(testImg, faceModel)
sz = size(testImg(:,:,1));
imgH = testImg(:,:,1);
imgS = testImg(:,:,2);
BiFaceImg = testImg;
for i = 1 : sz(1)
    for j = 1 : sz(2)
        if (imgH(i,j) > faceModel(1) && imgH(i,j) < faceModel(2) && imgS(i,j) > faceModel(3) && imgS(i,j) < faceModel(4))
            BiFaceImg(i,j,:) = 1;
        else 
            BiFaceImg(i,j,:) = 0;
        end
    end
end

%Morphological closing or morphological opening. Connected component analysis. Other methods that could remove noise in binary images.
function FinalImg = getMorphFace(BiImg)
se = strel('square',5);
FinalImg = imclose(BiImg,se);