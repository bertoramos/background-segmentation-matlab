function [P, B1, B2, B3] = get_marks(I, bbox, r)
    % GET_MARKS returns 3 bounding boxes : extended bbox, top, right and left
    %   I : image
    %   bbox : human detected bounding box
    %   r : background percentage
    
    width = size(I,2);
    height = size(I,1);
    box_x = bbox(1);
    box_y = bbox(2);
    box_width = bbox(3);
    box_height = bbox(4);
    
    % extends human detected bounding box to bottom
    Px = box_x;
    Py = box_y;
    Pw = box_width;
    Ph = height - box_y;
    P = [Px, Py, Pw, Ph];
    
    % Left bounding box
    B1_x = 0;
    B1_y = box_y;
    B1_w = r*box_x;
    B1_h = box_height;
    B1 = [B1_x, B1_y, B1_w, B1_h];
    
    % Top bounding box
    B2_x = box_x;
    B2_y = 0;
    B2_w = box_width;
    B2_h = r*box_y;
    B2 = [B2_x, B2_y, B2_w, B2_h];
    
    % Right bounding box
    B3_w = r*(width - box_x - box_width);
    
    B3_x = width - B3_w;
    B3_y = box_y;
    B3_h = box_height;
    B3 = [B3_x, B3_y, B3_w, B3_h];
    
end

