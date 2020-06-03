% Function description
% :PROPERTIES:
% :UNNUMBERED: t
% :END:

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

% Arguments
% :PROPERTIES:
% :UNNUMBERED: t
% :END:

arguments
    zn
    i_inputs  {mustBeInteger} = 0
    i_outputs {mustBeInteger} = 0
end

% Size Reduction
% :PROPERTIES:
% :UNNUMBERED: t
% :END:

zr = zn([i_inputs, i_outputs], :);
