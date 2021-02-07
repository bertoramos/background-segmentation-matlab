function [imres] = chroma(img, bg, color, t1, t2, gauss_radius)
    % CHROMA applies chroma keying algorithm
    %   img : [uint8 matrix] original image
    %   bg : [uint8 matrix] background image
    %   color : [uint8 vector] key color
    %   t1 : [double] lower threshold
    %   t2 : [double] higher threshold
    %   gauss_radius : [double] gaussian filter radius (> 0)

    image_hsv = rgb2hsv(double(img)/255);
    key_hsv = rgb2hsv(double(color)/255);
    distance = dist_hsv(image_hsv, key_hsv);

    mask = (t1 < distance & distance < t2).*((distance.^2 - t1^2)./(t2^2 - t1^2))  +  (distance > t2);
    
    mask = uint8(mask);
    mask = imgaussfilt(mask, gauss_radius + eps);
    background = imresize(bg, size(img, 1:2));

    imres = img.*mask + (1-mask).*background;

end
