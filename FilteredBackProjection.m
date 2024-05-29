phantom_size = 128;
I = phantom(phantom_size,phantom_size);
I = double(I);
I1 = zeros(256,256);
I1(64+(1:128),64 +(1:128)) = I;
 
%%
numAngles = 180;
N = size(I, 1);

Xc = phantom_size / 2;
Yc = phantom_size / 2;

R = zeros(2 * phantom_size, numAngles); % Radon transform using revolving ray

[Row_size, Column_Size] = size(R);

Downstream_Data = zeros(Row_size, Column_Size);
Downstream_Image = zeros(256, 256);
Buffer_Data = zeros(256, 256);

%%

t = linspace(-128, +128, 257);
disp(t)

Filter = [t(129:256), abs(t(2:129))];
plot(Filter/max(Filter));
title('Filter');

%%
%wvtool(hamming(128));

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

        R(rho, t) = sum(intensity); % Assign intensity to R
    end
    
    filtered_intensity = ifft(fft(R(:,t)).*(Filter(:)));

    % Accumulate the projection data onto the image
    Downstream_Image = Downstream_Image + imrotate(repmat(filtered_intensity,1,256), t + 90,'crop');
end

%%
temp = real(fft(R(:,1)).*Filter(:));

plot(temp);
% Normalize the accumulated image
Downstream_Image = Downstream_Image / max(Downstream_Image(:));

%%

% Display the reconstructed image
imagesc(real(Downstream_Image(128+(-63:64),(128+(-63:64)))));
axis image;
colormap('gray'); % Set the colormap to grayscale
title('Filtered Backprojected Image');
colorbar; % Add a colorbar for intensity scale

%%

imagesc(I);
axis image;
colormap(gca, 'gray');
colorbar; % Add a colorbar for intensity scale

%%
imagesc(real(Downstream_Image(128+(-63:64),(128+(-63:64)))) - I );
colormap('gray');
title('Difference');
axis image;
colorbar;
%%

% Display the sinogram
imagesc(R);
title('Radon Transform');
xlabel('Angle (degrees)');
ylabel('Projection Position');
colormap(gca, 'gray');
axis image;
colorbar;