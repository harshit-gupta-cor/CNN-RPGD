function y=vl_nnupconv(x,pad,stride,dzdy)


if nargin <= 3 || isempty(dzdy)
  px=imresize(x,stride,'nearest');
  y=padarray(px,pad);
else
  
  y = vl_nnpool(dzdy, stride, ...
                'pad', pad, 'stride', stride, ...
                'method', 'avg') ;
            
end
