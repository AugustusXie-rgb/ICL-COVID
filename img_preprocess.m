% img_preprocess

load('img_list.mat');
% size_list=zeros(length(img_list),3);
% for i=1:length(img_list)
%     im=imread(strcat('img_folder/',img_list(i)));
%     size_list(i,:)=size(im);
% end
re_size=[400,200];
all_bar_length=[];
all_maximum=[];
all_top20=[];
all_top50=[];
% ally=[];
img_list=img_list(1:1696);
for i=1:length(img_list)
    im=imread(strcat('img_folder/',img_list(i)));
    im=imresize(im,re_size);
    hsv_map=rgb2hsv(im);
    ind=double(hsv_map(:,:,1)>0.5);
    hue_map=abs(hsv_map(:,:,1)-ind);
    cen=[200,100];
    hue_val_map=zeros(re_size(1),re_size(2));
%     max_length=sqrt((map_size(1)-cen(1))^2+(map_size(2)-cen(2))^2);
%     for j=1:re_size(1)
%         for k=1:re_size(2)
% %             hue_val_map(j,k)=(0.5-hue_map(j,k))*min([5,(max_length/sqrt((j-cen(1))^2+(k-cen(2))^2+0.0001))]);
%             hue_val_map(j,k)=(0.5-hue_map(j,k))*min([5,(re_size(1)/abs(j-cen(1)+0.0001))])*min([5,(re_size(2)/abs(k-cen(2)+0.0001))]);
%         end
%     end
    hue_val_map=1-2*hue_map;
    hue_line=hue_val_map(:);
    threshold_1=mean(hue_line);
    threshold_2=mean(hue_line)+std(hue_line);
    threshold_3=mean(hue_line)+2*std(hue_line);
    ind_1=double(hue_val_map>threshold_1);
    ind_2=double(hue_val_map>threshold_2);
    ind_3=double(hue_val_map>threshold_3);
    for j=1:re_size(1)
        for k=1:re_size(2)-1
            if ind_1(j,k+1)>0
                ind_1(j,k+1)=ind_1(j,k)+1;
                if ind_2(j,k+1)>0
                    ind_2(j,k+1)=ind_2(j,k)+1;
                    if ind_3(j,k+1)>0
                        ind_3(j,k+1)=ind_3(j,k)+1;
                    end
                end
            end
        end
    end
    bar_length_1=max(ind_1,[],2);
    bar_length_2=max(ind_2,[],2);
    bar_length_3=max(ind_3,[],2);
    bar_length=0.25*(bar_length_1+2*bar_length_2+4*bar_length_3)/re_size(2);
    bar_length_path=strcat('bar_length/'+img_list(i));
    plot(bar_length);
    f=getframe(gcf);
    imwrite(f.cdata,bar_length_path);

%     for j=1:re_size(1)
%         check=0;
%         for k=re_size(2):-1:1
%             if ind(j,k)==bar_length(j)
%                 check=1;
%             end
%             if check==1 && ind(j,k)>0
%                 weight_length(j)=weight_length(j)+bar_length(j)*(hue_val_map(j,k)-mean(hue_line))/std(hue_line);
%             end
%             if check==1 && ind(j,k)==0
%                 check=0;
%                 break;
%             end
%         end
%     end      
%     weight_length=weight_length/re_size(2);
%     weight_length_path=strcat('weight_length/',img_list(i));
%     plot(weight_length);
%     f=getframe(gcf);
%     imwrite(f.cdata,weight_length_path);
%     hue_val_map_path=strcat('hue_val_map/',img_list(i));
%     imwrite(hue_val_map/max(max(hue_val_map)),hue_val_map_path);
    
    top20_length=round(0.2*re_size(2));
    top50_length=round(0.5*re_size(2));
    hue_val_sort=sort(hue_val_map,2,'descend');
    hue_val_sort_20=hue_val_sort(:,1:top20_length);
    hue_val_sort_50=hue_val_sort(:,1:top50_length);
    top20_mean=mean(hue_val_sort_20,2);
    top50_mean=mean(hue_val_sort_50,2);
    maximum=hue_val_sort(:,1);
%     plot(hue_depth_mean);
%     f=getframe(gcf);
%     hue_depth_path=strcat('hue_depth/',img_list(i));
%     imwrite(f.cdata,hue_depth_path);
    all_bar_length=[all_bar_length; bar_length'];
    all_maximum=[all_maximum; normalize(maximum,'range')'];
    all_top20=[all_top20; normalize(top20_mean,'range')'];
    all_top50=[all_top50; normalize(top50_mean,'range')'];   
    i
end

train_length=round(0.8*length(img_list));
val_length=round(0.1*length(img_list));

train_bar_length=all_bar_length(1:train_length,:);
train_maximum=all_maximum(1:train_length,:);
train_top20=all_top20(1:train_length,:);
train_top50=all_top50(1:train_length,:);
trainy=ally(1:train_length);
val_bar_length=all_bar_length(train_length+1:train_length+val_length,:);
val_maximum=all_maximum(train_length+1:train_length+val_length,:);
val_top20=all_top20(train_length+1:train_length+val_length,:);
val_top50=all_top50(train_length+1:train_length+val_length,:);
valy=ally(train_length+1:train_length+val_length);
test_bar_length=all_bar_length(train_length+val_length+1:end,:);
test_maximum=all_maximum(train_length+val_length+1:end,:);
test_top20=all_top20(train_length+val_length+1:end,:);
test_top50=all_top50(train_length+val_length+1:end,:);
testy=ally(train_length+val_length+1:end);

writematrix(train_bar_length,'train_bar_length.txt','Delimiter','space');
writematrix(train_maximum,'train_maximum.txt','Delimiter','space');
writematrix(train_top20,'train_top20.txt','Delimiter','space');
writematrix(train_top50,'train_top50.txt','Delimiter','space');
writematrix(trainy,'trainy.txt','Delimiter','space');
writematrix(val_bar_length,'val_bar_length.txt','Delimiter','space');
writematrix(val_maximum,'val_maximum.txt','Delimiter','space');
writematrix(val_top20,'val_top20.txt','Delimiter','space');
writematrix(val_top50,'val_top50.txt','Delimiter','space');
writematrix(valy,'valy.txt','Delimiter','space');
writematrix(test_bar_length,'test_bar_length.txt','Delimiter','space');
writematrix(test_maximum,'test_maximum.txt','Delimiter','space');
writematrix(test_top20,'test_top20.txt','Delimiter','space');
writematrix(test_top50,'test_top50.txt','Delimiter','space');
writematrix(testy,'testy.txt','Delimiter','space');

% con_stack_norm=normalize(con_stack,2);