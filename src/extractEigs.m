function [w, zm] = extractEigs(filename, args)
% extractEigs -
%
% Syntax: [w, zm] = extractEigs(filename, args)
%
% Inputs:
%    - filename - relative or absolute path of the file that contains the eigenvectors and eigenvalues
%    - args - Optional parameters:
%        - 'dirs' - [6 x 1] - ones(6,1) (default)
%                           - Vectors with 0 and 1 identifying directions to include in the modal matrix
%                           - This corresponds to [Ux, Uy, Uz, Rx, Ry, Rz]
%        - 'soft' - 'ansys' (default) - Software used for the FEM
%
% Outputs:
%    - w  - [m x 1] - Eigenvalues [Hz]
%    - zm - [n x m] - Modal Matrix containing the eigenvectors

arguments
    filename
    args.dirs (6,1) double {mustBeNumericOrLogical}            = ones(6,1)
    args.soft       char   {mustBeMember(args.soft,{'ansys'})} = 'ansys'
end

fid = fopen(filename,'rt');

if fid == -1
    error('Error opening the file');
end

if strcmp(args.soft, 'ansys')
    w = [];
    zm = [];

    while 1
        % Read a line
        nextline = fgetl(fid);

        % End of the file
        if ~isstr(nextline), break, end

        % Lines containing the mode numbers
        if contains(nextline, ' LOAD STEP=') && ...
                contains(nextline, 'SUBSTEP=') && ...
                ~contains(nextline, 'CUM')
            mode_num = sscanf(nextline, ' LOAD STEP= %*f  SUBSTEP= %f ');
        end

        % Lines containing the frequency of the modes
        if contains(nextline, 'FREQ=')
            w = [w; sscanf(nextline, ' FREQ= %f LOAD CASE= %*f')];
        end

        % Start of the eigenvectors
        if contains(nextline, 'ROTZ')
            zmi = [];

            % Read the eigenvectors for each of the nodes
            while 1
                nextline = fgetl(fid);
                c = sscanf(nextline, ' %f');
                if isempty(c), break, end
                zmi = [zmi; c(2:end)'];
            end

            zm (:, :, mode_num) = zmi;
        end
    end

    zm = reshape(zm(:, logical([0; args.dirs]), :), [], mode_num);
end

fclose(fid);
