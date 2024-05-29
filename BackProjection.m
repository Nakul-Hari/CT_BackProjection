phantom_size = 128;
I = phantom(phantom_size,phantom_size);
I = double(I);
I1 = zeros(256,256);
I1(64+(1:128),64 +(1:128)) = I;
 
%%

imagesc(I);
axis image;
colormap('gray'); 
colorbar; 
title('Original Image');

%%
numAngles = 180;
N = size(I, 1);

Xc = phantom_size / 2;
Yc = phantom_size / 2;

R = zeros(2 * phantom_size, numAngles); % Radon transform using revolving ray

[Row_size, Column_Size] = size(R);

Downstream_Data = zeros(Row_size, Column_Size);
Downstream_Image = zeros(256, 256);

%%

for t = 1:numAngles
    angle = deg2rad(-t); % Negative due to MATLAB's coordinate system

    for rho = 1:2*phantom_size
        ray = 1:2*phantom_size;

        % Calculate rotated coordinates
        x_rotated = (rho - phantom_size) * cos(angle) - (ray - phantom_size) * sin(angle) + Xc;
        y_rotated = (rho - phantom_size) * sin(angle) + (ray - phantom_size) * cos(angle) + Yc;

        % Interpolate using interp2
        intensity = interp2(I, x_rotated, y_rotated, 'linear',0);
        
        Downstream_Data(:, rho) = sum(intensity); % Back projection Data
        
        R(rho, t) = sum(intensity); % Assign intensity to R
    end

    % Accumulate the projection data onto the image
    Downstream_Image = Downstream_Image + imrotate(Downstream_Data,t,'crop');
   
end

% Normalize the accumulated image
Downstream_Image = Downstream_Image / max(Downstream_Image(:));


% Display the reconstructed image
imagesc(Downstream_Image(128+(-63:64),(128+(-63:64))));
title('Back Projected Image');
axis image;
colormap('gray'); 
colorbar; 
%%

% Display the sinogram
imagesc(R);
title('Radon Transform');
xlabel('Angle (degrees)');
ylabel('Projection Position');
colormap(gca, 'gray');
colorbar;
axis image;