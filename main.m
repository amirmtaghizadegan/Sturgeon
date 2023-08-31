clear
close all
clc


%% elements refrence
element_ref = ["As", "Arsenic"; "Cd", "Cadmium"; "Cr", "Chromium";
    "Cu", "Copper"; "Hg", "Mercury"; "Zn", "Zinc"]; % "Ag", "Silver";

standard_ref = [3 0.5 NaN NaN 1 NaN]; %from paper... 

%% making refrence table
ref = readtable("etwas.xlsx");
%ref(7, :) = [];
ref_vn = ref.Properties.VariableNames;
for i = 4:length(ref_vn)
    if class(ref.(ref_vn{i})(1)) ~= "double"
        temp = string(ref.(ref_vn{i}));
        for j = 1:length(temp)
            temp(j) = lt_drop(temp(j));
        end
        ref.(ref_vn{i}) = double(temp);
    end
end

%% making dry refrence
dry_ref = ref;
dry_ref{:, 4:end} = dry_ref{:, 4:end}*100./(100-dry_ref{:, 3});
%% loading data
data = readtable("matlab_XLR.xlsx", sheet="Results Summary");
data_vn = data.Properties.VariableNames;
lt_track = zeros(length(data_vn), height(data), 'logical');
for i = 4:length(data_vn)
    if class(data.(data_vn{i})(1)) ~= "double"
        temp = string(data.(data_vn{i}));
        for j = 1:length(temp)
            [temp(j), lt_track(j, i)] = lt_drop(temp(j));
        end
        data.(data_vn{i}) = double(temp);
    end
end
%% bar ploting data
tissues = ["MT", "Liver";
    "WM", "L"];
for k = 1:length(tissues)
    for i = 1:length(element_ref) 
        figure
        % data bar
        data_temp = data{string(data.Analyte)==element_ref(i, 2) & string(data.Units) == 'mg/kg wwt', contains(string(data_vn), tissues(1, k))};
        lt_id = (lt_track(string(data.Analyte)==element_ref(i, 2) & string(data.Units) == 'mg/kg wwt', contains(string(data_vn), tissues(1, k))));
        lt_id = lt_id(~isnan(data_temp));
        data_temp = data_temp(~isnan(data_temp));

        x = 1:length(data_temp);
        b = bar(x, data_temp, 'DisplayName', 'Data');
        % data bar settings
        title(tissues(1, k) + " " + element_ref(i, 2))
        b.FaceColor = [0 0 1]; % bar colors
        xticknames = string(number_extractor(string(data_vn(contains(string(data_vn), tissues(1, k))))));
        xticklabels(xticknames)
        xlabel("fish sample")
        ylabel("mg/kg wwt")
        
        hold on
        % ploting star over <dl bars.
        plot(x(lt_id), data_temp(lt_id), '*r', 'DisplayName', '<DL', 'MarkerSize', 12)
        
        % ref bar
        ref_temp = ref.(element_ref(i, 1))(ref.Tissue == tissues(2, k));
        ref_temp = ref_temp(~isnan(ref_temp));
        xx = 1:length(ref_temp);
        xx = xx+2+x(end);
        bb = bar(xx, ref_temp, 'DisplayName', 'Refrence');
        
        % ref bar settings
        bb.FaceColor = [1 0 0]; %ref bar colors
        
        line_data = mean(data_temp);
        line_ref = mean(ref_temp);

        fx = get(gca, "XLim");
        plot(fx, [line_data line_data], '--b', DisplayName="Data average", LineWidth=2)

        plot(fx, [line_ref line_ref], '--r', DisplayName="refrence average", LineWidth=2)

        if ~isnan(standard_ref(i)) && k == 1
            plot(fx, [standard_ref(i) standard_ref(i)], '--k', DisplayName="Standards", LineWidth=2)
        end

        legend()
    end
end

function number = number_extractor(words)
    number = zeros(size(words));
    for i = 1:numel(words)
        temp = char(words(i));
        number(i) = str2double(temp(regexp(temp, "[0-9]")));
    end
end

function [word, flag] = lt_drop(word)
    word = char(word);
    flag = 0;
    if word(1) == '<'
        flag = 1;
        word(1) = [];
    end
    word = string(word);
end