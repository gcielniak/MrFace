data_path = 'GooglePicassa\A_TestSet\';
data_path = 'GooglePicassa\H_TestSet\';
data_path = 'GooglePicassa\I_TestSet\';

c = dir([data_path '*.txt']);

tp = [];
fn = [];
fp = [];

for i = 1:length(c)
    fid = fopen([data_path c(i).name]);
    tp(i) = fscanf(fid,'TP = %d'); fgetl(fid);
    fn(i) = fscanf(fid,'FN = %d'); fgetl(fid);
    fp(i) = fscanf(fid,'FP = %d');
    fclose(fid);
end

fprintf('Dataset: %s\n',data_path);
fprintf('precision %.2f, recall %.2f\n',sum(tp)/(sum(tp)+sum(fp)),sum(tp)/(sum(tp)+sum(fn)))