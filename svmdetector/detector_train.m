load dataset;

labels_train = dataset(:,1);
data_train = dataset(:,2:end);

%% remove nans
nan_ind = find(isnan(scores));
scores(nan_ind) = [];
labels_train(nan_ind) = [];
data_train(nan_ind,:) = [];

%%sort according to the score
[vv, ii] = sort(scores,'descend');
labels_train = labels_train(ii);
data_train = data_train(ii,:);

%% balance the number of pos and neg
pos_ind = find(labels_train);
neg_ind = find(labels_train==0);
%take top scoring negative examples of the same length as positive
neg_ind = neg_ind(1:length(pos_ind));

labels_train = labels_train([pos_ind; neg_ind],:);
data_train = data_train([pos_ind; neg_ind],:);

%%
labels_test = labels_train;
data_test = data_train;

%% scale
%data_train = scale_svm(data_train);
%data_test = scale_svm(data_test);

%% train + test
fprintf('Training... ');
model = svmtrain(labels_train,data_train,'-b 1 -q');
fprintf('done\n');

save svm_model model;

%%IF YOU WANT TO USE DETECTOR IN YOUR CODE WITH A SINGLE SHAPE DO THE
%%FOLLOWING:
%% load svm_model;
%% probability = detector_predict(data_test(i,:),model)

fprintf('Testing... ');
[p_label, accuracy, dv] = svmpredict(labels_test,data_test,model,'-b 1 -q');
fprintf('done\n');

%% report errors
pos_ind = find(labels_test==1);
pos_ratio = (length(pos_ind) - sum(abs(p_label(pos_ind) - labels_test(pos_ind))))/length(pos_ind);
neg_ind = find(labels_test==0);
neg_ratio = (length(neg_ind) - sum(abs(p_label(neg_ind) - labels_test(neg_ind))))/length(neg_ind);
fprintf('pos %.2f, neg %.2f, all %.2f\n',pos_ratio*100,neg_ratio*100,accuracy(1));