%visualisation script
addpath('export_fig');
load votes_Results.txt;
load normC_Results.txt;
load normC_ResultsBinned.txt
load normCMax_Results.txt;
load normCMaxBinned_Results.txt;
load recErr_Results.txt;
load recErrAccBinned_Results.txt;
load recErrMin_Results.txt;
load recErrMinBinned_Results.txt;

%remove zero entries from error surfaces
max_error = max(max(recErrMin_Results(find(recErrMin_Results < 1000000))));
recErrMin_Results(find(recErrMin_Results >= 1000000)) = max_error;
recErrMin_Results = max_error - recErrMin_Results;

max_error = max(max(recErrMinBinned_Results(find(recErrMinBinned_Results < 1000000))));
recErrMinBinned_Results(find(recErrMinBinned_Results >= 1000000)) = max_error;
recErrMinBinned_Results = max_error - recErrMinBinned_Results;

max_error = max(max(recErr_Results(find(recErr_Results < 1000000))));
recErr_Results(find(recErr_Results >= 1000000)) = max_error;
recErr_Results = max_error - recErr_Results;

max_error = max(max(recErrAccBinned_Results(find(recErrAccBinned_Results < 1000000))));
recErrAccBinned_Results(find(recErrAccBinned_Results >= 1000000)) = max_error;

%blur error surfaces
normCMax_Results = imfilter(normCMax_Results,fspecial('average', 5),'replicate');
recErrMin_Results = imfilter(recErrMin_Results,fspecial('average', 5),'replicate');
recErr_Results = imfilter(recErr_Results,fspecial('average', 5),'replicate');

%colormap(flipud(gray));
colormap(jet);
%colormap(spring);

subplot(3,2,1); imshow(imread('image.jpg')); title('image'); axis image; axis off; colorbar; 
subplot(3,2,2); imagesc(votes_Results); title('votes'); axis image; axis off; colorbar;
subplot(3,2,3); imagesc(normCMax_Results); title('normalised corr. max'); axis image; axis off; colorbar;
subplot(3,2,4); imagesc(normC_ResultsBinned); title('normalised corr.'); axis image; axis off; colorbar;
%subplot(3,3,6); imagesc(normCMaxBinned_Results); title('normalised corr. max binned'); axis image; axis off; colorbar;
subplot(3,2,5); imagesc(recErrMin_Results); title('rec. error min'); axis image; axis off; colorbar;
subplot(3,2,6); imagesc(recErrAccBinned_Results); title('rec. error'); axis image; axis off; colorbar;
%subplot(3,2,9); imagesc(recErrMinBinned_Results); title('rec. error min binned'); axis image; axis off; colorbar;

