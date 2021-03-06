clc,clear,close all

%% Load the stereo images
left_img = imread('flowers-left.png');
right_img = imread('flowers-right.png');

%% Conver the RGB to grayscale images with double type, and normalize to [0, 1] range
left_gray = double(rgb2gray(left_img)) / 255.0;
right_gray = double(rgb2gray(right_img)) / 255.0;
figure
imshowpair(left_gray, right_gray, 'montage');


%% Define the strip(band) row(y) and square block size(b)
y = 100;
b = 100;

%% Extract strip from the left and right images
strip_left  = left_gray(y: y + b -1, :);
strip_right = right_gray(y: y + b -1, :);
imshowpair(strip_left, strip_right, 'montage');

disparity = match_strips(strip_left, strip_right, b)
figure
plot(disparity);

function best_x = find_best_match(patch_left, strip_right)
    num_column = size(strip_right, 2);
    % Normalize the
    [patch_size_row, patch_size_col] = size(patch_left);
    best_x = 1;
   % min_diss = inf;
    max_corr = 0;
    %patch_left = (patch_left - mean(patch_left(:))) / std(patch_left(:));
    corr_cache = zeros(num_column-(patch_size_col-1),1);
    for k = 1:num_column-(patch_size_col-1)
       patch_right = strip_right(:, k:k+patch_size_col-1);
      % patch_right = (patch_right - mean(patch_right(:))) / std(patch_right(:));
%        dissimilarity = norm((patch_right(:)- patch_left(:)));
%        if dissimilarity < min_diss
%            min_diss = dissimilarity;
%            best_x = k;
%        end
       % cross_correlation = patch_left(:)' * patch_right(:);
       % cosine similarity!
        cross_correlation = patch_left(:)' * patch_right(:) / (norm(patch_left(:)) * norm(patch_right(:)));
        corr_cache(k) = cross_correlation;
        if cross_correlation > max_corr
            max_corr = cross_correlation;
            best_x = k;
        end
    end
%     figure
%     plot(corr_cache)
end

function disparity = match_strips(strip_left, strip_right, b)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For each non-overlapping patch/block of width b in the left strip, 
% Find the best matching position (along x-axis, column index) in the
% right strip.
% Input: 
%       strip_left, strip_right as their names indicate
%       b is the block/patch size
% Output:
%       a vector of disparities(left X-pos(>=0) - right X_pos(<=0))
% Note: Only consider whole blocks that fit within image bounds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Compute the numer of blocks
num_col_left_strip = size(strip_left, 2);
num_block_left_strip = floor(num_col_left_strip / b);  % or (num_col_left_strip - mod(num_col_left_strip, b))/b

disparity = zeros(num_block_left_strip, 1);
for k = 1: num_block_left_strip
    patch_left = strip_left(1:b, 1 + (k-1) * num_block_left_strip: k * num_block_left_strip);
    % Normalization is performed by the function below
    best_x = find_best_match(patch_left, strip_right);
    disparity(k,1) = 1 + (k-1) * num_block_left_strip - best_x;
end
    

end