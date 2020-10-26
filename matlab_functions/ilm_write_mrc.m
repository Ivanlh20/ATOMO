function ilm_write_mrc(stack, filename, type_mat, b_norm)
    if(nargin==2)
        type_mat = 'uint8';
        b_norm = false;     
    elseif(nargin==3)
        b_norm = false;    
    end

    type_mat = strtrim(type_mat);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [path, filename] = fileparts(filename);
    fn_path = [ilm_add_filesep(path), filename, '.mrc'];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    type_mrc = fn_matlab_2_mrc_type(type_mat);
    st = get_par(stack, type_mat, b_norm);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    header = fn_build_header(stack, type_mrc, st);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    nz = size(stack, 3);
    file_w = fopen(fn_path, 'w', 'ieee-le');
    fwrite(file_w, header, 'int32');
    for iz = 1:nz
        im_ik = fn_apply_transform(stack(:, :, iz), type_mrc, st.a, st.b);
        fwrite(file_w, im_ik, type_mat);
    end
    fclose(file_w);
end

function[header] = fn_build_header(stack, type_mrc, st)
    [ny, nx, nz] = size(stack);

    stack_123 = [st.min, st.max, st.mean];
    stack_std = st.std;
    
    angles = [90 90 90];
    
    header = int32(zeros(256,1, 'double'));
    header(1:3) = [nx, ny, nz];                                         % number of columns, rows, sections
    header(4) = type_mrc;                                               % mode: uint8, uint16, single
    header(8:10) = header(1:3);                                         % number of intervals along x,y,z
    header(11:13) = typecast(single(header(1:3)), 'int32');             % Cell dimensions
    header(14:16) = int32(single(angles));                              % Angles
    header(17:19) = (1:3)';                                             % Axis assignments
    header(20:22) = typecast(single(stack_123), 'int32');
    header(23) = 0;                                                     % Space group 0 (default)
    
    q = typecast(int32(1),'uint8');
    machineLE = (q(1)==1); % true for little-endian machine
    
    if machineLE
        header(53) = typecast(uint8('MAP '), 'int32');
        header(54) = typecast(uint8([68 65 0 0]), 'int32');             % LE machine stamp.
    else
        header(53) = typecast(uint8(' PAM'), 'int32');                  % LE machine stamp, for writing with BE machine.
        header(54) = typecast(uint8([0 0 65 68]), 'int32');
    end
    header(55) = typecast(single(stack_std), 'int32');
end

function[st] = get_par(stack, type_mat, b_norm)
    if(b_norm)
        I_min = double(min(stack(:)));
        I_max = double(max(stack(:)));
        a = 1.0/(I_max-I_min);            
        b = -a*I_min;
    else
        a = 1.0;
        b = 0;
    end

    if(isa(stack, 'double') || isa(stack, 'single'))
        if(strcmpi(type_mat, 'uint8'))
            f = 255;
        elseif(strcmpi(type_mat, 'uint16'))
            f = 65535; 
        else
            f = 1;
        end
    else
        if(isa(stack, 'uint8') && strcmpi(type_mat, 'uint16'))
            f = 65535/255;
        else
            f = 1.0;
        end
    end
    a = f*a;
    b = f*b;    
    
    st.a = a;
    st.b = b;
    if(b_norm)
        st.min = 0;
        if(strcmpi(type_mat, 'uint8'))
            st.max = 255;
        elseif(strcmpi(type_mat, 'uint16'))
            st.max = 65535; 
        else
            st.max = 1;
        end

    else
        st.min = double(min(stack(:)));
        st.max = double(max(stack(:)));
    end
    st.mean = a*double(mean(stack(:)))+b;
    st.std = (st.min + st.max + st.mean)/(2*5);
    
%     st.std = a*double(std(stack(:)));
end

function[im_o] = fn_apply_transform(im_i, type_mat, a, b)
    switch type_mat
        case 0
            im_o = uint8(a*double(im_i)+b); 
        case 1
            im_o = int16(a*double(im_i)+b); 
        case 2
            im_o = single(a*double(im_i)+b); 
        case 6
            im_o = uint16(a*double(im_i)+b); 
    end
end

function[type_mrc] = fn_matlab_2_mrc_type(type_mat)
    % 'double', 'single', 'logical','int8', 'uint8', 'int16', 
    % 'uint16', 'int32', 'uint32', 'int64', 'uint64'
    type_mat = strtrim(type_mat);
    switch type_mat
        case 'uint8'
            type_mrc = 0;
        case 'int16'
            type_mrc = 1;
        case 'single'
            type_mrc = 2;
        case 'double'
            type_mrc = 2;
        case 'uint16'
            type_mrc = 6;
    end
end


% https://bio3d.colorado.edu/imod/doc/mrc_format.txt
% The MRC file format used by IMOD.
% 
% The MRC header, length 1024 bytes.  Names are the names used in C code.
% 
% OFFSET  SIZE DATA    NAME	Description
% 
%   0 000  4   int     nx;	Number of Columns 
%   4 004  4   int     ny;        Number of Rows
%   8 010  4   int     nz;        Number of Sections.
% 
%  12 014  4   int     mode;      Types of pixel in image.  Values used by IMOD:
%          	       	 0 = unsigned or signed bytes depending on flag in imodStamp
%                              only unsigned bytes before IMOD 4.2.23
%          	       	 1 = signed short integers (16 bits)
%          	       	 2 = float
%          	       	 3 = short * 2, (used for complex data)
%          	       	 4 = float * 2, (used for complex data)
%                          6 = unsigned 16-bit integers
%          	       	16 = unsigned char * 3 (for rgb data, non-standard)
%                        101 = 4-bit values (non-standard)
% 
%  16 020  4   int     nxstart;     Starting point of sub image (not used in IMOD)  
%  20 024  4   int     nystart;
%  24 030  4   int     nzstart;
% 
%  28 034  4   int     mx;         Grid size in X, Y, and Z       
%  32 040  4   int     my;
%  36 044  4   int     mz;
% 
%  40 050  4   float   xlen;       Cell size; pixel spacing = xlen/mx, ylen/my, zlen/mz
%  44 054  4   float   ylen;
%  48 060  4   float   zlen;
% 
%  52 064  4   float   alpha;      cell angles - ignored by IMOD
%  56 070  4   float   beta;
%  60 074  4   float   gamma;
% 
%          	       	 These need to be set to 1, 2, and 3 for pixel spacing
%                                    to be interpreted correctly
%  64 100  4   int     mapc;       map column  1=x,2=y,3=z.       
%  68 104  4   int     mapr;       map row     1=x,2=y,3=z.       
%  72 110  4   int     maps;       map section 1=x,2=y,3=z.       
% 
%                                  These need to be set for proper scaling of data
%  76 114  4   float   amin;       Minimum pixel value.
%  80 120  4   float   amax;       Maximum pixel value.
%  84 124  4   float   amean;      Mean pixel value.
% 
%  88 130  4   int     ispg;       space group number, should be 0 for an image stack, 1
%                                  for a volume, but is mostly ignored by IMOD
%  92 134  4   int     next;       number of bytes in extended header (called nsymbt in
%                                    MRC standard)
%  96 140  2   short   creatid;    used to be an ID number, is 0 as of IMOD 4.2.23
%  98 142  6   ---     extra data  (not used, first two bytes should be 0)
% 104 150  4   char    extType     Type of extended header, includes 'SERI' for
%                                  SerialEM, 'FEI1' for FEI, 'AGAR' for Agard
% 108 154  4   int     nversion    MRC version that file conforms to, otherwise 0
% 112 160  16  ---     extra data  (not used)
% 
%                                  These two values specify the structure of data in the
%                                  extended header; their meaning depend on whether the
%                                  extended header has the FEI/Agard format, a series of
%                                  4-byte integers then real numbers, or has data 
%                                  produced by SerialEM, a series of short integers.  
%                                  The short integers are signed, except for
%                                  piece coordinates.
%                                  SerialEM stores a float as two shorts, s1 and s2, by:
%                                    value = (sign of s1)*(|s1|*256 + (|s2| modulo 256))
%                                       * 2**((sign of s2) * (|s2|/256))
% 128 200  2   short   nint;       Number of integers per section (FEI/Agard format) or
%                                  number of bytes per section (SerialEM format)
% 130 202  2   short   nreal;      Number of reals per section (FEI/Agard format) or bit
%                                  flags for which types of short data (SerialEM format):
%                                  1 = Tilt angle in degrees * 100  (2 bytes)
%                                  2 = X, Y, Z piece coordinates for montage (6 bytes)
%                                  4 = X, Y stage position in microns * 25   (4 bytes)
%                                  8 = Magnification / 100 (2 bytes)
%                                  16 = Intensity * 25000  (2 bytes)
%                                  32 = Exposure dose in e-/A2, a float in 4 bytes
%                                  128, 512: Reserved for 4-byte items
%                                  64, 256, 1024: Reserved for 2-byte items
%                                  If the number of bytes implied by these flags does
%                                  not add up to the value in nint, then nint and nreal
%                                  are interpreted as ints and reals per section
% 
% 132 204  20  ---     extra data (not used)
% 
% 152 230  4   int     imodStamp   1146047817 indicates that file was created by IMOD or 
%                                  other software that uses bit flags in the following field
% 156 234  4   int     imodFlags   Bit flags:
%                                  1 = bytes are stored as signed
%                                  2 = pixel spacing was set from size in extended header 
%                                  4 = origin is stored with sign inverted from definition
%                                      below
%                                  8 = RMS value is negative if it was not computed
%                                  16 = Bytes have two 4-bit values, the first one in the
%                                       low 4 bits and the second one in the high 4 bits
% 
%                               Explanation of type of data.
% 160 240  2   short   idtype;  ( 0 = mono, 1 = tilt, 2 = tilts, 3 = lina, 4 = lins)
% 162 242  2   short   lens;
% 164 244  2   short   nd1;	for idtype = 1, nd1 = axis (1, 2, or 3)     
% 166 246  2   short   nd2;
% 168 250  2   short   vd1;                       vd1 = 100. * tilt increment
% 170 252  2   short   vd2;                       vd2 = 100. * starting angle
% 
%                 		Current angles are used to rotate a model to match a
%                                 new rotated image.  The three values in each set are
%                                 rotations about X, Y, and Z axes, applied in the order
%                                 Z, Y, X.
% 172 254  24  float   tiltangles[6];  0,1,2 = original:  3,4,5 = current 
% 
%                                The image origin is the location of the origin of the
%                                coordinate system relative to the first pixel in the
%                                file.  It is in pixel spacing units rather than in
%                                pixels.  If an original volume has an origin of 0, a
%                                subvolume should have negative origin values.
%         NEW-STYLE MRC image2000 HEADER - IMOD 2.6.20 and above:
% 196 304  4   float   xorg;      Origin of image
% 200 310  4   float   yorg;
% 204 314  4   float   zorg;
% 208 320  4   char    cmap;      Contains "MAP "
% 212 324  4   char    stamp;     First two bytes have 17 and 17 for big-endian or 
%                                   68 and 65 for little-endian
% 216 330  4   float   rms;       RMS deviation of densities from mean, should
%                                   be negative if not computed
% 
%         OLD-STYLE MRC HEADER - IMOD 2.6.19 and below:
% 196 304  2   short   nwave;     # of wavelengths and values
% 198 306  2   short   wave1;
% 200 310  2   short   wave2;
% 202 312  2   short   wave3;
% 204 314  2   short   wave4;
% 206 316  2   short   wave5;
% 208 320  4   float   zorg;      Origin of image.
% 212 324  4   float   xorg;
% 216 330  4   float   yorg;
% 
%         ALL HEADERS:
% 220 334  4   int     nlabl;  	Number of labels with useful data.
% 224 340  800 char[10][80]    	10 labels of 80 charactors, blank-padded to end
% ------------------------------------------------------------------------
% 
% Offsets are given as bytes in decimal and octal.
% Total size of header is 1024 bytes plus the size of the extended header.
%  
% Image data follows with the origin in the lower left corner, looking down on
% the volume.  The first pixel in the file is the lower left corner of the
% first image; the first nx values are the lowest line of that image in Y.
% 
% The size of the image is nx * ny * nz * (mode data size).
% 
% Fourier transforms are stored as complex floats.  The 2D or 3D transform of a
% nx * ny * nz image file has dimensions (nx / 2 + 1) * ny * nz.  The origin (0
% spatial frequency) is at (0, ny / 2) on each plane of a 2D transform, and at
% (0, ny / 2, nz / 2) in a 3D transform, where coordinates are numbered from 0
% and each division rounds downward to an integer.  The frequencies at the first
% and last lines of the transform are -int(ny / 2) / ny and 
% int((ny - 1) / 2) / ny, respectively, and similarly in Z for a 3D transform.
% 
% For 4-bit data (mode 101), each byte contains a pair of pixels, and the first
% pixel (the one with lower coordinate) is in the lower 4 bits, while the second
% pixel is in the higher 4 bits.  This fill order is the same for little-endian
% and big-endian files.  Each line has int((nx + 1) / 2) bytes, with 4-bits of
% padding at the end of each line when nx is odd.
% 
% The latest standard for the MRC format was described in:
% Cheng et al. (2015) MRC2014: Extensions to the MRC format header for electron
% cryo-microscopy and tomography. J. Struct. Biol. 192, 146-150.
% 
% A link to this paper and the formal standard description are at:
% http://www.ccpem.ac.uk/mrc_format/mrc_format.php
% 
% Potential deviations from the 2014 MRC standard are the use of mode 16 for RGB
% data, the use of mode 101 for 4-bit data, writing bytes (mode 0) unsigned, and
% the use of negative origins for subvolumes. Files with any of these
% non-conformities should have a zero in the NVERSION field.  For a conforming
% file, NVERSION would be 10 times the year of the standard plus a version
% number within the year.  Since this field was not zeroed out by SerialEM
% before version 3.3, IMOD code tests for NVERSION >= 20140 and &lt; 10 *
% (current year + 2).  Other non-standard items, in bytes 152-195, are at the
% top of the extra data section and do not conflict with other known uses.
% 
% It is suggested that other developers willing to follow the conventions in the
% imodFlags field and wishing to indicate that files originated from their
% software use the same imodStamp value and designate another bit in imodFlags,
% to be listed here.  However, the best way to indicate that a byte file is
% signed is simply to conform with the standard and set the NVERSION field.