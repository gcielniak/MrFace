function [] = generate_svmdata(data_path)

addpath functions
load('cAAM.mat'); %new version striped out of all unnecessary stuff to save memory

%parameters
overlap = 0.5;

d = dir(data_path);
isub = [d(:).isdir]; %# returns logical vector
folder_names = {d(isub).name}';
folder_names(ismember(folder_names,{'.','..'})) = [];
num = length(folder_names);

index = 1;
%initialise the approx. size of the result matrices
svm_labels = zeros(num*20,1);
scores =  zeros(num*20,1);
svm_shapes = zeros(num*20,136);
tic;
for i = 1:num
    file_path = [data_path '/image' num2str(i)];
 
    faces = dir([file_path '/faces/' '*.pts']);

    try
        image = imread([file_path '/image.jpg']);
    catch
        image = imread([file_path '/image.png']);
    end
    
    for j=1:length(faces)
        pts(:,:,j) = read_shape([file_path '/faces/' faces(j).name],68);
    end
    NRC = importdata([file_path '/normC_Results.txt']);
    
    simg = size(image);mpts = mean(pts);sNRC = size(NRC);
    for j=1:length(faces)
        face_coo(:,:,j) = round([mpts(1,2,j)/simg(1)*sNRC(1) mpts(1,1,j)/simg(2)*sNRC(2)]);
        pts_rs(:,:,j) = round([pts(:,1,j)/simg(2)*sNRC(2) pts(:,2,j)/simg(1)*sNRC(1)]);
    end
    
    grid_size = importdata([file_path '/grid_size.txt']);
    grid_length = grid_size(1)*grid_size(2);
    RP_results = importdata([file_path '/RP_Results.txt']);
    
    final_shapes = zeros(grid_length,136);
    for count_rp=1:grid_length
        try
            final_shapes(count_rp,:) = cAAM.shape{2}.s0(:) + cAAM.shape{2}.S * RP_results(count_rp,5:7)' + cAAM.shape{2}.Q * RP_results(count_rp,1:4)';
        catch
            final_shapes(count_rp,:) = [ones(1,34) 3*ones(1,34) ones(1,34) 3*ones(1,34)];
        end
    end
    
    boxes1 = zeros(grid_length,1);
    boxes2 = zeros(grid_length,1);
    boxes3 = zeros(grid_length,1);
    boxes4 = zeros(grid_length,1);
    boxes5 = zeros(grid_length,1);
    for count=1:grid_length
        try
            boxes1(count,1) = min(final_shapes(count,1:68));
            boxes2(count,1) = min(final_shapes(count,69:136));
            boxes3(count,1) = max(final_shapes(count,1:68));
            boxes4(count,1) = max(final_shapes(count,69:136));
            indx = round([mean(final_shapes(count,69:136)) mean(final_shapes(count,1:68))]);
            boxes5(count,1) = NRC(indx(1),indx(2));
        catch
            boxes5(count,1) = 0;
            indx = [1,1];
            NRC(indx(1),indx(2)) = 0;
        end
    end
    boxes=[boxes1,boxes2,boxes3,boxes4,boxes5];
    pick = nms(boxes,overlap);
    
    for nms_count=1:length(pick)
        
        r1_test = min(final_shapes(pick(nms_count),1:68));
        c1_test = min(final_shapes(pick(nms_count),69:136));
        r2_test = max(final_shapes(pick(nms_count),1:68));
        c2_test = max(final_shapes(pick(nms_count),69:136));
        area_test = (r2_test - r1_test + 1) * (c2_test-c1_test + 1);
        indx = round([mean(final_shapes(pick(nms_count),69:136)) mean(final_shapes(pick(nms_count),1:68))]);
        
        try
            dummyValue = NRC(indx(1),indx(2));
        catch
            r1_test = 1;
            c1_test = 1;
            r2_test = 2;
            c2_test = 2;
            area_test = (r2_test - r1_test + 1) * (c2_test-c1_test + 1);
            indx = [1,1];
            NRC(1,1) = 0;
        end
        best_overlap = 0;
        for face_count=1:length(faces)
            r1_face = min(pts_rs(:,1,face_count));
            c1_face = min(pts_rs(:,2,face_count));
            r2_face = max(pts_rs(:,1,face_count));
            c2_face = max(pts_rs(:,2,face_count));
            area_face = (r2_face - r1_face + 1) * (c2_face-c1_face + 1);
            
            r1_o = max(r1_test,r1_face);
            c1_o = max(c1_test,c1_face);
            r2_o = min(r2_test,r2_face);
            c2_o = min(c2_test,c2_face);
            
            if (r1_o <= r2_face && r1_o >= r1_face && r1_o <= r2_test && r1_o >= r1_test && c1_o <= c2_face && c1_o >= c1_face && c1_o <= c2_test && c1_o >= c1_test && r2_o <= r2_face && r2_o >= r1_face && r2_o <= r2_test && r2_o >= r1_test && c2_o <= c2_face && c2_o >= c1_face && c2_o <= c2_test && c2_o >= c1_test)
                area_overlap = (r2_o-r1_o + 1) * (c2_o - c1_o + 1);
            else
                area_overlap = 0;
            end
            best_overlap = max(best_overlap,area_overlap/(area_test + area_face - area_overlap));
        end
        
        dummy_shape = cAAM.shape{2}.s0(:) + cAAM.shape{2}.S * RP_results(pick(nms_count),5:7)';
        dummy_shape1 = cAAM.shape{2}.s0(:) + cAAM.shape{2}.Q * RP_results(pick(nms_count),1:4)' + cAAM.shape{2}.S * RP_results(pick(nms_count),5:7)';
        
        %%filter out weird locations - perhaps worth checking the code
        %%generating that data!
        loc1 = round(mean(dummy_shape1(69:136)));
        loc2 = round(mean(dummy_shape1(1:68)));
        if (loc1 > 0) & (loc1 < 1000) & (loc2 > 0) & (loc2 < 1000)
            svm_shapes(index,:) = dummy_shape;       
            scores(index) = NRC(loc1,loc2);

            if (best_overlap > overlap)
                svm_labels(index) = 1;
            else
                svm_labels(index) = 0;                
            end

            index = index + 1;
        end
    end
    fprintf('folder %d out of %d, %d%%, ETA %d s\n',i,num,round(100*i/num),round((num-i)*(toc/i)));
end

%rescale back the result matrices
svm_labels = svm_labels(1:index-1);
scores = scores(1:index-1);
svm_shapes = svm_shapes(1:index-1,:);
dataset = [svm_labels, svm_shapes];

%saving
save dataset dataset scores;