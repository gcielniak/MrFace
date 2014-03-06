%visualisation script
addpath('cm_and_cb_utilities');
load votes_Results.txt;
load normCMax_Results.txt;
load normC_Results.txt;
load recErrMin_Results.txt;
load recErr_Results.txt;

%remove zero entries from error surfaces
max_error = max(max(recErrMin_Results(find(recErrMin_Results < 100000))));
recErrMin_Results(find(recErrMin_Results >= 100000)) = max_error;
recErrMin_Results = max_error - recErrMin_Results;

max_error = max(max(recErr_Results(find(recErr_Results < 100000))));
recErr_Results(find(recErr_Results >= 100000)) = max_error;
recErr_Results = max_error - recErr_Results;

%blur error surfaces
recErrMin_Results = imfilter(recErrMin_Results,fspecial('average', 5),'replicate');
recErr_Results = imfilter(recErr_Results,fspecial('average', 5),'replicate');

%colormap(flipud(gray));
%colormap(jet);
colormap(spring);

subplot(2,3,1); imshow(imread('image.jpg')); title('image'); axis image; axis off; colorbar; 
subplot(2,3,4); imagesc(votes_Results); title('votes'); axis image; axis off; colorbar;
subplot(2,3,2); imagesc(normCMax_Results); title('normalised corr. max'); axis image; axis off; colorbar;
subplot(2,3,5); imagesc(normC_Results); title('normalised corr.'); axis image; axis off; colorbar;
subplot(2,3,3); imagesc(recErrMin_Results); title('rec. error min (inverted, blurred (5x5))'); axis image; axis off; colorbar;
subplot(2,3,6); imagesc(recErr_Results); title('rec. error (inverted, blurred (5x5))'); axis image; axis off; colorbar;



