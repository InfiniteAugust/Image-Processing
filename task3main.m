function task3main
I = imread('1.tif');
G = rgb2gray(I);
bw1 = edge(G, 'canny', 0.1, 0.4);
se = strel('square',4);
FinalImg = imclose(bw1,se);
figure, imshow(FinalImg);