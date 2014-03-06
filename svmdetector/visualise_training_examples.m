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
scores = scores(ii);
labels_train = labels_train(ii);
data_train = data_train(ii,:);

%% balance the number of pos and neg
pos_ind = find(labels_train);
neg_ind = find(labels_train==0);
%take top scoring negative examples of the same length as positive
neg_ind = neg_ind(1:length(pos_ind));

%%visualise positive examples
figure;
for i = 1:80
    subplot(8,10,i), display_face([-data_train(pos_ind(i),1:68); -data_train(pos_ind(i),1+68:68+68)]'); title(sprintf('%.f2',scores(pos_ind(i))));
end

%%visualise positive examples
figure;
for i = 1:80
    subplot(8,10,i), display_face([-data_train(neg_ind(i),1:68); -data_train(neg_ind(i),1+68:68+68)]'); title(sprintf('%.f2',scores(neg_ind(i))));
end
