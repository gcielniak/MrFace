function out = detector_predict(data,model)
[p_label, accuracy, dv] = svmpredict(0,data,model,'-b 1 -q');
out = dv(1);