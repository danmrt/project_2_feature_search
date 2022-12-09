
function nnnn


    disp("Welcome to Daniel's feature seleciton algorithm");
    prompt = "Type in the name of the file to test: ";
    txt = input(prompt,"s");
    data = load(txt);

    disp("Type the number of the algorithm you want to run.");
    disp("     1) Forward Selection");
    disp("     2) Backward Elimination");
    prompt = '\n';
    x = input(prompt);
    %include a thing here to get user num input

    dataFeatureSize = size(data,2) - 1; % we subtract one to get correct amount of columns
    dataRowSize = size(data,1);
    disp(['This dataset has ', num2str(dataFeatureSize), ' features (not including the class attribute), with ', num2str(dataRowSize), ' instances.']);

    set_of_all_features = [];

    for temp = 1: dataFeatureSize
        set_of_all_features(temp) = temp;
    end

    %all_features_txt = sprintf('%.0f,', set_of_all_features);
    %fprintf(all_features_txt);
    %fprintf('\n');
    
    if x == 1
        tic
       forward_search(data);
        toc
    end

    if x == 2
        tic
        backward_search(data);
        toc
    end

    function backward_search(data)
        
        disp('Beginning search');
        
        max_accuracy = 0; %saves alltime best accuracy
        best_features = [];
        current_set_of_features = []; % populate both of these with all features set 

        for pp = 1 : length(set_of_all_features)
            current_set_of_features(pp) = set_of_all_features(pp);
        end

        %populated with all features in both arrays

        %edits
        max_accuracy = leave_one_out_cross_validation(data,current_set_of_features,0);
   

        for i = 1 : size(data,2) - 1
            %disp(['On the ', num2str(i), 'th level of the search tree'])
            feature_to_remove_at_this_level = []; 
            best_features = [];
            %best_so_far_accuracy = leave_one_out_cross_validation(data, current_set_of_features, 0);

            best_so_far_accuracy = max_accuracy;
            % i have a best so far for the set that contains all features
            % here

            for k = 1 : size(data,2) -1
               if ~isempty((intersect(current_set_of_features,k)) ) %may have to edit where the '~' is placed
                %disp (['--Considering adding the ', num2str(k),' feature'])
                fprintf("     Using feature(s) {");
                based = current_set_of_features(current_set_of_features~=k);
                if ( (length(based)) > 0 )
                    curr_set_txt = sprintf('%.0f,', based);
                    curr_set_txt = curr_set_txt(1:end-1); %removes comma at end
                    fprintf(curr_set_txt);
                end
                %fprintf([num2str(k)]); edited for backward
                fprintf("} accuracy is ");

                accuracy = leave_one_out_cross_validation2(data,current_set_of_features, k);%change to k+1
                disp(num2str(accuracy));
                if accuracy > best_so_far_accuracy
                    best_so_far_accuracy = accuracy;
                    feature_to_remove_at_this_level = k;
                end
               end  
            end

            

            current_set_of_features = setdiff(current_set_of_features, feature_to_remove_at_this_level);
            %disp(['On level ', num2str(i), ' i added feature ', num2str(feature_to_add_at_this_level), ' to current set'])
            fprintf("Feature set {");
            currSet2_txt = sprintf('%.0f,', current_set_of_features);
            currSet2_txt = currSet2_txt(1:end-1); %removes final comma
            fprintf(currSet2_txt);
            fprintf("} was best, accuracy is ");
            disp([num2str(best_so_far_accuracy)]);

            if best_so_far_accuracy > max_accuracy
                max_accuracy = best_so_far_accuracy;
                best_features = setdiff(current_set_of_features,best_features);
            else
                fprintf("Previous accuracies are less than our best, so we stop here\n");
                break;
            end
            

            

        end
        fprintf("\nFinished search!! The best feature subset is {"); %%add missing values
        bestSet_txt = sprintf('%.0f,', current_set_of_features);
        bestSet_txt = bestSet_txt(1:end-1); 
        fprintf(bestSet_txt);
        fprintf("}, which has an accuracy of ");
        disp(num2str(max_accuracy));
    end
 


    function forward_search(data)
        
        disp('Beginning search');
        
        max_accuracy = 0; %saves alltime best accuracy
        best_features = [];
        current_set_of_features = []; 
   

        for i = 1 : size(data,2) - 1
            %disp(['On the ', num2str(i), 'th level of the search tree'])
            feature_to_add_at_this_level = []; 
            best_so_far_accuracy = 0;

            for k = 1 : size(data,2) -1
               if isempty(intersect(current_set_of_features,k))
                %disp (['--Considering adding the ', num2str(k),' feature'])
                fprintf("     Using feature(s) {");
                if ( (length(current_set_of_features)) > 0 )
                    curr_set_txt = sprintf('%.0f,', current_set_of_features);
                    fprintf(curr_set_txt);
                end
                fprintf([num2str(k)]);
                fprintf("} accuracy is ");

                accuracy = leave_one_out_cross_validation(data,current_set_of_features, k);%change to k+1
                disp(num2str(accuracy));
                if accuracy > best_so_far_accuracy
                    best_so_far_accuracy = accuracy;
                    feature_to_add_at_this_level = k;
                end

               end  
            end

            current_set_of_features(i) = feature_to_add_at_this_level;
            %disp(['On level ', num2str(i), ' i added feature ', num2str(feature_to_add_at_this_level), ' to current set'])
            fprintf("Feature set {");
            currSet2_txt = sprintf('%.0f,', current_set_of_features);
            currSet2_txt = currSet2_txt(1:end-1); %removes final comma
            fprintf(currSet2_txt);
            fprintf("} was best, accuracy is ");
            disp([num2str(best_so_far_accuracy)]);

            if best_so_far_accuracy > max_accuracy
                max_accuracy = best_so_far_accuracy;
                for i = 1 : length(current_set_of_features) 
                    best_features(i) = current_set_of_features(i);
                end
            end
        end
        fprintf("\nFinished search!! The best feature subset is {"); %%add missing values
        bestSet_txt = sprintf('%.0f,', best_features);
        bestSet_txt = bestSet_txt(1:end-1); 
        fprintf(bestSet_txt);
        fprintf("}, which has an accuracy of ");
        disp(num2str(max_accuracy));
    end

    function accuracy = leave_one_out_cross_validation(data, current_set, feature_to_add)
        %making columns we dont care about equal to 0

        %
        %if ( feature_to_add == length(set_of_all_features))
        %    feature_to_add = 1; %if feature to add - 1 is equal to total features amount, use feature 1 as feature_to_add
        %end

        %do not add repeating features in our current set union
        if ( (~ismember(feature_to_add, current_set) ) && feature_to_add ~= 0) % if feature_to_add == 0. then special backward condition
            current_set(end+1) = feature_to_add; %if  the current feature we are adding is not already in our overall current set, add it
        end
        %


        notLookingAt = setdiff(set_of_all_features, current_set); %the set of all features - current set

        for bb = 1 : length(notLookingAt) %from 1 to the length of features we are ignoring
            data(:,(notLookingAt(bb)) + 1 ) = 0; % the value at the feature we are ignoring + 1 to get correct column, set it all to 0
        end        
        %columns for features we dont care about are 0 now



        number_correctly_classified = 0;

        for i = 1 : size(data,1)
            object_to_classify = data(i,2:end);
            label_object_to_classify = data(i,1);
    
            nearest_neighbor_distance = inf;
            nearest_neighbor_location = inf;
            for k = 1 : size(data,1)
                
                if k ~= i
                    distance = sqrt(sum((object_to_classify - data(k,2:end)).^2));
                    if distance < nearest_neighbor_distance
                        nearest_neighbor_distance = distance;
                        nearest_neighbor_location = k;
                        nearest_neighbor_label    = data(nearest_neighbor_location, 1);
                    end 
                end
            end

            if label_object_to_classify == nearest_neighbor_label
                number_correctly_classified = number_correctly_classified + 1;
            end

        end

        accuracy = number_correctly_classified / size(data,1);
        %disp(['Accuracy: ', num2str(accuracy)]);

    end
function accuracy = leave_one_out_cross_validation2(data, current_set, feature_to_remove)
        %making columns we dont care about equal to 0

        %
        %if ( feature_to_add == length(set_of_all_features))
        %    feature_to_add = 1; %if feature to add - 1 is equal to total features amount, use feature 1 as feature_to_add
        %end

        %do not add repeating features in our current set union
        current_set = setdiff(current_set, feature_to_remove); %edit this to internet solution aka what smashgod sent if no work
        %


        notLookingAt = setdiff(set_of_all_features, current_set); %the set of all features - current set

        for bb = 1 : length(notLookingAt) %from 1 to the length of features we are ignoring
            data(:,(notLookingAt(bb)) + 1 ) = 0; % the value at the feature we are ignoring + 1 to get correct column, set it all to 0
        end        
        %columns for features we dont care about are 0 now



        number_correctly_classified = 0;

        for i = 1 : size(data,1)
            object_to_classify = data(i,2:end);
            label_object_to_classify = data(i,1);
    
            nearest_neighbor_distance = inf;
            nearest_neighbor_location = inf;
            for k = 1 : size(data,1)
                
                if k ~= i
                    distance = sqrt(sum((object_to_classify - data(k,2:end)).^2));
                    if distance < nearest_neighbor_distance
                        nearest_neighbor_distance = distance;
                        nearest_neighbor_location = k;
                        nearest_neighbor_label    = data(nearest_neighbor_location, 1);
                    end 
                end
            end

            if label_object_to_classify == nearest_neighbor_label
                number_correctly_classified = number_correctly_classified + 1;
            end

        end

        accuracy = number_correctly_classified / size(data,1);
        %disp(['Accuracy: ', num2str(accuracy)]);

    end
end 