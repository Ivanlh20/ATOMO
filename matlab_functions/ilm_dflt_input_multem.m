function [input_multem] = ilm_dflt_input_multem()

    %%%%%%%%%%%%%% Electron-Specimen interaction model %%%%%%%%%%%%%%%%%
    input_multem.interaction_model = 1;                         % eESIM_Multislice = 1, eESIM_Phase_Object = 2, eESIM_Weak_Phase_Object = 3
    input_multem.potential_type = 6;                            % ePT_Doyle_0_4 = 1, ePT_Peng_0_4 = 2, ePT_Peng_0_12 = 3, ePT_Kirkland_0_12 = 4, ePT_Weickenmeier_0_12 = 5, ePT_Lobato_0_12 = 6

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    input_multem.operation_mode = 1;                            % eOM_Normal = 1, eOM_Advanced = 2
    input_multem.memory_size = 0;                               % memory size to be used(Mb)
    input_multem.reverse_multislice = 0;                        % 1: true, 0:false

    %%%%%%%%%%%%%%% Electron-Phonon interaction model %%%%%%%%%%%%%%%%%%
    input_multem.pn_model = 1;                                  % ePM_Still_Atom = 1, ePM_Absorptive = 2, ePM_Frozen_Phonon = 3
    input_multem.pn_coh_contrib = 0;                            % 1: true, 0:false
    input_multem.pn_single_conf = 0;                            % 1: true, 0:false (extract single configuration)
    input_multem.pn_nconf = 1;                                  % true: specific phonon configuration, false: number of frozen phonon configurations
    input_multem.pn_dim = 110;                                  % phonon dimensions (xyz)
    input_multem.pn_seed = 300183;                              % Random seed(frozen phonon)

    %%%%%%%%%%%%%%%%%%%%%%% Specimen information %%%%%%%%%%%%%%%%%%%%%%%
    input_multem.spec_atoms = [];                               % simulation box length in x direction (�)
    input_multem.spec_dz = 0.25;                                % slice thick (�)

    input_multem.spec_bs_x = 10;                                % simulation box size in x direction (�)
    input_multem.spec_bs_y = 10;                                % simulation box size in y direction (�)
    input_multem.spec_bs_z = 10;                                % simulation box size in z direction (�)

    input_multem.spec_cryst_na = 1;                             % number of unit cell along a
    input_multem.spec_cryst_nb = 1;                             % number of unit cell along b
    input_multem.spec_cryst_nc = 1;                             % number of unit cell along c
    input_multem.spec_cryst_a = 0;                              % length along a (�)
    input_multem.spec_cryst_b = 0;                              % length along b (�)
    input_multem.spec_cryst_c = 0;                              % length along c (�)
    input_multem.spec_cryst_x0 = 0;                             % reference position along x direction (�)
    input_multem.spec_cryst_y0 = 0;                             % reference position along y direction (�)

    input_multem.spec_amorp(1).z_0 = 0;                         % Starting z position of the amorphous layer (�)
    input_multem.spec_amorp(1).z_e = 0;                         % Ending z position of the amorphous layer (�)
    input_multem.spec_amorp(1).dz = 2.0;                        % slice thick of the amorphous layer (�)

    %%%%%%%%%%%%%%%%%%%%%%%%% Specimen Rotation %%%%%%%%%%%%%%%%%%%%%%%%
    input_multem.spec_rot_theta = 0;                            % angle (�)
    input_multem.spec_rot_u0 = [0 0 1];                          % unitary vector			
    input_multem.spec_rot_center_type = 1;                       % 1: geometric center, 2: User define		
    input_multem.spec_rot_center_p = [0 0 0];                    % rotation point

    %%%%%%%%%%%%%%%%%%%%%% Specimen thickness %%%%%%%%%%%%%%%%%%%%%%%%%%
    input_multem.thick_type = 1;                                % eTT_Whole_Spec = 1, eTT_Through_Thick = 2, eTT_Through_Slices = 3
    input_multem.thick = 0;                                     % Array of thickness (�)

    %%%%%%%%%%%%%%%%%%%%%%% Potential slicing %%%%%%%%%%%%%%%%%%%%%%%%%%
    input_multem.potential_slicing = 1;                         % ePS_Planes = 1, ePS_dz_Proj = 2, ePS_dz_Sub = 3, ePS_Auto = 4

    %%%%%%%%%%%%%%%%%%%%%% x-y sampling %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    input_multem.nx = 256;                                      % number of pixels in x direction
    input_multem.ny = 256;                                      % number of pixels in y direction
    input_multem.bwl = 0;                                       % Band-width limit, 1: true, 0:false

    %%%%%%%%%%%%%%%%%%%%%%%% Simulation type %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % eTEMST_STEM=11, eTEMST_ISTEM=12, eTEMST_CBED=21, eTEMST_CBEI=22, 
    % eTEMST_ED=31, eTEMST_HRTEM=32, eTEMST_PED=41, eTEMST_HCTEM=42, 
    % eTEMST_EWFS=51, eTEMST_EWRS=52, eTEMST_STEM_EELS=61, eTEMST_ISTEM_EELS=62, eTEMST_EFTEMFS=71, eTEMST_EFTEMRS=72, 
    % eTEMST_ProbeFS=71, eTEMST_ProbeRS=72, eTEMST_PPFS=81, eTEMST_PPRS=82, 
    % eTEMST_TFFS=91, eTEMST_TFRS=92
    input_multem.simulation_type = 52;    

    %%%%%%%%%%%%%%%%%%%% Microscope parameters %%%%%%%%%%%%%%%%%%%%%%%%%%
    input_multem.E_0 = 300;                                     % Acceleration Voltage (keV)
    input_multem.theta = 0.0;                                   % Polar angle (�)
    input_multem.phi = 0.0;                                     % Azimuthal angle (�)

    %%%%%%%%%%%%%%%%%%%%%% Illumination model %%%%%%%%%%%%%%%%%%%%%%%%%%
    input_multem.illumination_model = 2;                        % 1: coherente mode, 2: Partial coherente mode, 3: transmission cross coefficient, 4: Numerical integration
    input_multem.temporal_spatial_incoh = 1;                    % 1: Temporal and Spatial, 2: Temporal, 3: Spatial

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % On the optimun probe in aberration corrected ADF-STEM
    % Ultramicroscopy 111(2014) 1523-1530
    % C_{nm} Krivanek --- {A, B, C, D, R}_{n} Haider notation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%% condenser lens %%%%%%%%%%%%%%%%%%%%%%%%
    input_multem.cond_lens_m = 0;                               % Vortex momentum

    input_multem.cond_lens_c_10 = 14.0312;                      % [C1]      Defocus (�)
    input_multem.cond_lens_c_12 = 0.00;                         % [A1]      2-fold astigmatism (�)
    input_multem.cond_lens_phi_12 = 0.00;                       % [phi_A1]	Azimuthal angle of 2-fold astigmatism (�)

    input_multem.cond_lens_c_21 = 0.00;                         % [B2]      Axial coma (�)
    input_multem.cond_lens_phi_21 = 0.00;                       % [phi_B2]	Azimuthal angle of axial coma (�)
    input_multem.cond_lens_c_23 = 0.00;                         % [A2]      3-fold astigmatism (�)
    input_multem.cond_lens_phi_23 = 0.00;                       % [phi_A2]	Azimuthal angle of 3-fold astigmatism (�)

    input_multem.cond_lens_c_30 = 1e-03;                        % [C3] 		3rd order spherical aberration (mm)
    input_multem.cond_lens_c_32 = 0.00;                         % [S3]      Axial star aberration (�)
    input_multem.cond_lens_phi_32 = 0.00;                       % [phi_S3]	Azimuthal angle of axial star aberration (�)
    input_multem.cond_lens_c_34 = 0.00;                         % [A3]      4-fold astigmatism (�)
    input_multem.cond_lens_phi_34 = 0.0;                        % [phi_A3]	Azimuthal angle of 4-fold astigmatism (�)

    input_multem.cond_lens_c_41 = 0.00;                         % [B4]      4th order axial coma (�)
    input_multem.cond_lens_phi_41 = 0.00;                       % [phi_B4]	Azimuthal angle of 4th order axial coma (�)
    input_multem.cond_lens_c_43 = 0.00;                         % [D4]      3-lobe aberration (�)
    input_multem.cond_lens_phi_43 = 0.00;                       % [phi_D4]	Azimuthal angle of 3-lobe aberration (�)
    input_multem.cond_lens_c_45 = 0.00;                         % [A4]      5-fold astigmatism (�)
    input_multem.cond_lens_phi_45 = 0.00;                       % [phi_A4]	Azimuthal angle of 5-fold astigmatism (�)

    input_multem.cond_lens_c_50 = 0.00;                         % [C5]      5th order spherical aberration (mm)
    input_multem.cond_lens_c_52 = 0.00;                         % [S5]      5th order axial star aberration (�)
    input_multem.cond_lens_phi_52 = 0.00;                       % [phi_S5]	Azimuthal angle of 5th order axial star aberration (�)
    input_multem.cond_lens_c_54 = 0.00;                         % [R5]      5th order rosette aberration (�)
    input_multem.cond_lens_phi_54 = 0.00;                       % [phi_R5]	Azimuthal angle of 5th order rosette aberration (�)
    input_multem.cond_lens_c_56 = 0.00;                         % [A5]      6-fold astigmatism (�)
    input_multem.cond_lens_phi_56 = 0.00;                       % [phi_A5]	Azimuthal angle of 6-fold astigmatism (�)

    input_multem.cond_lens_inner_aper_ang = 0.0;                % Inner aperture (mrad) 
    input_multem.cond_lens_outer_aper_ang = 21.0;   			% Outer aperture (mrad)

    %%%%%%%%% defocus spread function %%%%%%%%%%%%
    input_multem.cond_lens_tp_inc_a = 1.0;                      % Height proportion of a normalized Gaussian [0, 1]
    input_multem.cond_lens_tp_inc_sigma = 0.5;                 	% Standard deviation of the source defocus spread for the Gaussian component (�)
    input_multem.cond_lens_tp_inc_beta = 0.1;                 	% Standard deviation of the source defocus spread for the Exponential component (�)
    input_multem.cond_lens_tp_inc_npts = 10;                    % Number of integration points. It will be only used if illumination_model=4
    
    %%%%%%%%%% source spread function %%%%%%%%%%%%
    input_multem.cond_lens_spt_inc_a = 1.0;                     % Height proportion of a normalized Gaussian [0, 1]
    input_multem.cond_lens_spt_inc_sigma = 0.5;                 % Standard deviation of the source spread function for the Gaussian component: For parallel ilumination(�^-1); otherwise (�)
    input_multem.cond_lens_spt_inc_beta = 0.1;                 	% Standard deviation of the source spread function for the Exponential component: For parallel ilumination(�^-1); otherwise (�)
    input_multem.cond_lens_spt_inc_rad_npts = 8;                % Number of radial integration points. It will be only used if illumination_model=4
    input_multem.cond_lens_spt_inc_azm_npts = 8;                % Number of radial integration points. It will be only used if illumination_model=4
    
    %%%%%%%%% zero defocus reference %%%%%%%%%%%%
    input_multem.cond_lens_zero_defocus_type = 1;   			% eZDT_First = 1, eZDT_User_Define = 2
    input_multem.cond_lens_zero_defocus_plane = 0;  			% It will be only used if cond_lens_zero_defocus_type = eZDT_User_Define

    %%%%%%%%%%%%%%%%%%% condenser lens variable %%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%% it will be active in the future %%%%%%%%%%%%%%%%%
    % 1: Vortex momentum, 2: Defocus (�), 2: Third order spherical aberration (mm)
    % 3: Third order spherical aberration (mm),  4: Fifth order spherical aberration (mm)
    % 5: Twofold astigmatism (�), 2: Defocus (�), 6: Azimuthal angle of the twofold astigmatism (�)
    % 7: Threefold astigmatism (�),  8: Azimuthal angle of the threefold astigmatism (�)
    % 9: Inner aperture (mrad), 2: Defocus (�), 10: Outer aperture (mrad)
    % input_multem.cdl_var_type = 0;                  			% 0:off 1: m, 2: f, 3 Cs3, 4:Cs5, 5:mfa2, 6:afa2, 7:mfa3, 8:afa3, 9:inner_aper_ang , 10:outer_aper_ang
    % input_multem.cdl_var = [-2 -1 0 1 2];           			% variable array

    %%%%%%%%%%%%%%%%%%%%%%%% Objective lens %%%%%%%%%%%%%%%%%%%%%%%%
    input_multem.obj_lens_m = 0;                                % Vortex momentum

    input_multem.obj_lens_c_10 = 14.0312;                       % [C1]      Defocus (�)
    input_multem.obj_lens_c_12 = 0.00;                          % [A1]      2-fold astigmatism (�)
    input_multem.obj_lens_phi_12 = 0.00;                        % [phi_A1]	Azimuthal angle of 2-fold astigmatism (�)

    input_multem.obj_lens_c_21 = 0.00;                          % [B2]      Axial coma (�)
    input_multem.obj_lens_phi_21 = 0.00;                        % [phi_B2]	Azimuthal angle of axial coma (�)
    input_multem.obj_lens_c_23 = 0.00;                          % [A2]      3-fold astigmatism (�)
    input_multem.obj_lens_phi_23 = 0.00;                        % [phi_A2]	Azimuthal angle of 3-fold astigmatism (�)

    input_multem.obj_lens_c_30 = 1e-03;                         % [C3] 		3rd order spherical aberration (mm)
    input_multem.obj_lens_c_32 = 0.00;                          % [S3]      Axial star aberration (�)
    input_multem.obj_lens_phi_32 = 0.00;                        % [phi_S3]	Azimuthal angle of axial star aberration (�)
    input_multem.obj_lens_c_34 = 0.00;                          % [A3]      4-fold astigmatism (�)
    input_multem.obj_lens_phi_34 = 0.0;                         % [phi_A3]	Azimuthal angle of 4-fold astigmatism (�)

    input_multem.obj_lens_c_41 = 0.00;                          % [B4]      4th order axial coma (�)
    input_multem.obj_lens_phi_41 = 0.00;                        % [phi_B4]	Azimuthal angle of 4th order axial coma (�)
    input_multem.obj_lens_c_43 = 0.00;                          % [D4]      3-lobe aberration (�)
    input_multem.obj_lens_phi_43 = 0.00;                        % [phi_D4]	Azimuthal angle of 3-lobe aberration (�)
    input_multem.obj_lens_c_45 = 0.00;                          % [A4]      5-fold astigmatism (�)
    input_multem.obj_lens_phi_45 = 0.00;                        % [phi_A4]	Azimuthal angle of 5-fold astigmatism (�)

    input_multem.obj_lens_c_50 = 0.00;                          % [C5]      5th order spherical aberration (mm)
    input_multem.obj_lens_c_52 = 0.00;                          % [S5]      5th order axial star aberration (�)
    input_multem.obj_lens_phi_52 = 0.00;                        % [phi_S5]	Azimuthal angle of 5th order axial star aberration (�)
    input_multem.obj_lens_c_54 = 0.00;                          % [R5]      5th order rosette aberration (�)
    input_multem.obj_lens_phi_54 = 0.00;                        % [phi_R5]	Azimuthal angle of 5th order rosette aberration (�)
    input_multem.obj_lens_c_56 = 0.00;                          % [A5]      6-fold astigmatism (�)
    input_multem.obj_lens_phi_56 = 0.00;                        % [phi_A5]	Azimuthal angle of 6-fold astigmatism (�)

    input_multem.obj_lens_inner_aper_ang = 0.0;     			% Inner aperture (mrad) 
    input_multem.obj_lens_outer_aper_ang = 24.0;    			% Outer aperture (mrad)

    %%%%%%%%% defocus spread function %%%%%%%%%%%%
    input_multem.obj_lens_tp_inc_a = 1.0;                           % Height proportion of a normalized Gaussian [0, 1]
    input_multem.obj_lens_tp_inc_sigma = 0.5;                 		% Standard deviation of the source defocus spread for the Gaussian component (�)
    input_multem.obj_lens_tp_inc_beta = 0.1;                 		% Standard deviation of the source defocus spread for the Exponential component (�)
    input_multem.obj_lens_tp_inc_npts = 10;                         % Number of integration points. It will be only used if illumination_model=4
    
    %%%%%%%%% zero defocus reference %%%%%%%%%%%%
    input_multem.obj_lens_zero_defocus_type = 3;    			% eZDT_First = 1, eZDT_Middle = 2, eZDT_Last = 3, eZDT_User_Define = 4
    input_multem.obj_lens_zero_defocus_plane = 0;   			% It will be only used if obj_lens_zero_defocus_type = eZDT_User_Define
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%% Scan region for ISTEM/STEM/EELS %%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    input_multem.scanning_type = 1;                 			% eST_Line = 1, eST_Area = 2, eST_User_Define = 3
    input_multem.scanning_periodic = 1;             			% 1: true, 0:false (periodic boundary conditions)
    input_multem.scanning_ns = 10;                  			% number of sampling points
    input_multem.scanning_R_0 = [0.0; 0.0];                 	% starting point (�)
    input_multem.scanning_R_e = [4.078; 4.078];                 % final point (�)
    
    % if input_multem.scanning_type = eST_User_Define, then the beam positions
    % must be define in input_multem.beam_pos
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%% Incident wave %%%%%%%%%%%%%%%%%%%%%%%%%%
    input_multem.iw_type = 4;                                   % 1: Plane_Wave, 2: Convergent_wave, 3:User_Define, 4: auto
    input_multem.iw_psi = 0;                                    % User define incident wave. It will be only used if User_Define=3

    %%%%%%%%%%%%%%%%%%%%%%%%%%% beam positions %%%%%%%%%%%%%%%%%%%%%%%%
    input_multem.beam_pos = [0.0; 0.0];                         % x-y positions
    
    %%%%%%%%%%%%%%%%%%%%%%%%%% STEM Detector %%%%%%%%%%%%%%%%%%%%%%%%%%
    input_multem.detector.type = 1;  % eDT_Circular = 1, eDT_Radial = 2, eDT_Matrix = 3

    input_multem.detector.cir(1).inner_ang = 60;    			% Inner angle(mrad) 
    input_multem.detector.cir(1).outer_ang = 180;   			% Outer angle(mrad)

    input_multem.detector.radial(1).x = 0;          			% radial detector angle(mrad)
    input_multem.detector.radial(1).fx = 0;         			% radial sensitivity value

    input_multem.detector.matrix(1).R = 0;          			% 2D detector angle(mrad)
    input_multem.detector.matrix(1).fR = 0;         			% 2D sensitivity value
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PED %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    input_multem.ped_nrot = 360;                    			% Number of orientations
    input_multem.ped_theta = 3.0;                   			% Precession angle (degrees)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HCI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    input_multem.hci_nrot = 360;                    			% number of orientations
    input_multem.hci_theta = 3.0;                   			% Precession angle (degrees)

    %%%%%%%%%%%%%%%%%%%%%%%%%% STEM-EELS %%%%%%%%%%%%%%%%%%%%%%%%%%%
    input_multem.eels_Z = 79;                       			% atomic type
    input_multem.eels_E_loss = 80;                  			% Energy loss (eV)
    input_multem.eels_collection_angle = 100;       			% Collection half angle (mrad)
    input_multem.eels_m_selection = 3;              			% selection rule
    input_multem.eels_channelling_type = 1;         			% eCT_Single_Channelling = 1, eCT_Mixed_Channelling = 2, eCT_Double_Channelling = 3 

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% EFTEM %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    input_multem.eftem_Z = 79;                      			% atomic type
    input_multem.eftem_E_loss = 80;                 			% Energy loss (eV)
    input_multem.eftem_collection_angle = 100;      			% Collection half angle (mrad)
    input_multem.eftem_m_selection = 3;             			% selection rule
    input_multem.eftem_channelling_type = 1;        			% eCT_Single_Channelling = 1, eCT_Mixed_Channelling = 2, eCT_Double_Channelling = 3 

    %%%%%%%%%%%%%%%%%%%%%%% OUTPUT REGION %%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% This option is not used for eTEMST_STEM and eTEMST_STEM_EELS %%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    input_multem.output_area_ip_0 = [1; 1];                     % Starting position in pixels
    input_multem.output_area_ip_e = [1; 1];                     % End position in pixels
end