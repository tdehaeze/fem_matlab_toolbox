function [M] = extractMatrix(filename)
% extractMatrix -
%
% Syntax: [M] = extractMatrix(filename)
%
% Inputs:
%    - filename - relative or absolute path of the file that contains the Matrix
%
% Outputs:
%    - M - Matrix that is contained in the file

arguments
    filename
end

str = fileread(filename);

str = regexprep(str,'\s+','');

parts = regexp(str, '\[(?<row>\d+),(?<col>\d+)\]:(?<val>[^\[]+)', 'names');

row = cellfun(@str2double, {parts.row}, 'UniformOutput', true);

col = cellfun(@str2double, {parts.col}, 'UniformOutput', true);

val = cellfun(@str2double, {parts.val}, 'UniformOutput', true);

sz = [max(row), max(col)];

M = zeros(sz);

ix = sub2ind(sz, row, col);

M(ix)= val;
