% Function description
% :PROPERTIES:
% :UNNUMBERED: t
% :END:

function [zn] = normalizeEigs(zm, args)
% normalizeEigs - Normalize the eigenvectors
%
% Syntax: [zn] = normalizeEigs(zm, args)
%
% Inputs:
%    - zm - Modal Matrix
%    - args - Optional parameters:
%        - method - 'mass' (default), 'unity' - Method used to normalize the eigenvectors
%
% Outputs:
%    - zn - Normalized Modal Matrix

% Optional Parameters
% :PROPERTIES:
% :UNNUMBERED: t
% :END:

arguments
    zm
    args.m      double {mustBeNumeric} = 0
    args.method char   {mustBeMember(args.method,{'mass', 'unity'})} = 'mass'
end

% Normalize the Eigen Vectors - Mass Method
% :PROPERTIES:
% :UNNUMBERED: t
% :END:


if strcmp(args.method, 'mass')
    if size(args.m) ~= [size(zm,1), size(zm,1)]
        error('The provided Mass matrix has not a compatible size with the Modal Matrix')
    end

    zn = zeros(size(zm));
    for i = 1:size(zm,2)
        zn(:,i) = zm(:,i)/sqrt(zm(:,i)'*args.m*zm(:,i));
    end
end

% Normalize the Eigen Vectors - Unity Method
% :PROPERTIES:
% :UNNUMBERED: t
% :END:


if strcmp(args.method, 'unity')
  zn = zm./max(zm);
end
