function [zr] = reductionInOut(zn, i_inputs, i_outputs)
% reductionInOut - Reduce the Modal Matrix to only specified nodes corresponding to Inputs and Ouputs
%
% Syntax: [zr] = reductionInOut(zn, i_inputs, i_outputs)
%
% Inputs:
%    - zn        - Normalized Modal Matrix
%    - i_inputs  - Node indices corresponding to inputs
%    - i_outputs - Node indices corresponding to inputs
%
% Outputs:
%    - zr - Reduced Normalized Modal Matrix

arguments
    zn
    i_inputs  {mustBeInteger} = 0
    i_outputs {mustBeInteger} = 0
end

zr = zn([i_inputs, i_outputs], :);
