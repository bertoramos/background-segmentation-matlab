function imres = human_segment(im, bg, detection_type, background_percentage, gaussian_radius, subdivision_rate, show_detected)
    %HUMAN_SEGMENT detects human and segments background 
    %   im : [uint8 matrix] original image
    %   bg : [uint8 matrix] background image
    %   detection_type: [string] "FrontalFaceLBP", "UpperBody"
    %   background_percentage: [double]  Background rate
    %   gaussian_radius: [double]   gaussian filter radius (>0)
    %   subdivision_rate: [double]  subdivision rate for lazysnapping
    %   show_detected: [bool]
    
    % detection
    detector = vision.CascadeObjectDetector(detection_type);
    detector.MinSize = [round(size(im, 1)/2) round(size(im, 1)/2)]; 
    detector.ScaleFactor = size(im) / (size(im) -0.5);
    bboxes = detector(im);
    
    % human no detected
    if isempty(bboxes)
        imres = im;
        return
    end
    
    % search biggest bounding box
    max_box = [0, 0, 0, 0];
    for i=1:size(bboxes,1)
        if prod(bboxes(i,3:4)) > prod(max_box(3:4))
            max_box = bboxes(i, :);
        end
    end
    
    % create masks
    [P,B1,B2,B3] = get_marks(im, max_box, background_percentage);
    
    foreground_mask = createMask(images.roi.Rectangle('Position',P), im);
    b1_mask = createMask(images.roi.Rectangle('Position',B1), im);
    b2_mask = createMask(images.roi.Rectangle('Position',B2), im);
    b3_mask = createMask(images.roi.Rectangle('Position',B3), im);
    background_mask = b1_mask + b2_mask + b3_mask;
    
    % lazy segmentation
    L = superpixels(im, uint8(subdivision_rate));
    final_mask = lazysnapping(im, L, foreground_mask, background_mask);
    
    final_mask = uint8(final_mask);
    final_mask = imgaussfilt(final_mask, gaussian_radius + eps);
    background = imresize(bg, size(im, 1:2));
    
    imres = im.*final_mask + (1-final_mask).*background;
    if show_detected
        imres = insertObjectAnnotation(imres,'rectangle',max_box,'Face', 'LineWidth', 3);
    end
end

