function dist = dist_hsv(hsv_img, hsv_key)
    % DIST_HSV returns the distance from each pixel to the key colour
    %   hsv_img : [double matrix] original hsv image
    %   hsv_key : [double matrix] hsv key color
    
    h_img = hsv_img(:,:,1);
    s_img = hsv_img(:,:,2);
    h_key = hsv_key(1);
    s_key = hsv_key(2);

    diff_hue = abs(h_img - h_key);

    dist_hue = min(diff_hue, 1.0 - diff_hue);
    dist_sat = abs(s_img - s_key);

    dist = (dist_hue.^2 + dist_sat.^2)/(0.5^2 + 1.0^2);
end
