classdef improcess < handle
    %IMPROCESS abstract improcess class
    %   Abstract class. Applies a certain preprocessing image technique
    
    properties
        background
    end
    
    methods (Abstract)
        % Returns processed image
        imres = process(obj,img);
    end
end

