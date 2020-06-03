function [int_xyz, int_i, n_xyz, n_i, nodes] = extractNodes(filename)
% extractNodes -
%
% Syntax: [n_xyz, nodes] = extractNodes(filename)
%
% Inputs:
%    - filename - relative or absolute path of the file that contains the Matrix
%
% Outputs:
%    - n_xyz -
%    - nodes - table containing the node numbers and corresponding dof of the interfaced DoFs

arguments
    filename
end

fid = fopen(filename,'rt');

if fid == -1
    error('Error opening the file');
end

n_xyz = []; % Contains nodes coordinates
n_i = []; % Contains nodes indices

while 1
    % Read a line
    nextline = fgetl(fid);

    % End of the file
    if ~isstr(nextline), break, end

    % Line just before the list of nodes coordinates
    if contains(nextline, 'NODE') && ...
            contains(nextline, 'X') && ...
            contains(nextline, 'Y') && ...
            contains(nextline, 'Z')

        while 1
            nextline = fgetl(fid);

            c = sscanf(nextline, ' %f');

            if isempty(c), break, end

            n_xyz = [n_xyz; c(2:end)'];
            n_i = [n_i; c(1)];
        end
    end

    % Line just before the list of node DOF
    if contains(nextline, 'NODE DOF')
        n_num = []; % Contains node numbers
        n_dof = {}; % Contains node directions

        while 1
            nextline = fgetl(fid);

            if nextline < 0, break, end

            c = sscanf(nextline, ' %d %s');

            if isempty(c), break, end

            n_num = [n_num; c(1)];

            n_dof{length(n_dof)+1} = char(c(2:end)');
        end

        nodes = table(n_num, string(n_dof'), 'VariableNames', {'node_i', 'node_dof'});
    end
end

fclose(fid);

int_i = unique(nodes.('node_i')); % indices of interface nodes

% Extract XYZ coordinates of only the interface nodes
int_xyz = n_xyz(logical(sum(n_i.*ones(1, length(int_i)) == int_i', 2)), :);
