function[] = ilm_gen_lammps_relaxation_sr_loop_h_hs_sr_in(par)
    % 2019 Ivan Lobato <Ivanlh20@gmail.com>
    par.path_atomic_model_i = strtrim(par.path_atomic_model_i);
    par.path_atomic_model_o = strtrim(par.path_atomic_model_o);
    
    par.path_atomic_model_i = strrep(par.path_atomic_model_i, '\', '/');
    par.path_atomic_model_o = strrep(par.path_atomic_model_o, '\', '/');
    par.fn_pot = strrep(par.fn_pot, '\', '/');
    
    par.fn_pot = strtrim(par.fn_pot);
    par.eam_style = strtrim(par.eam_style);
    
    if(~isfield(par, 'tdamp'))
        par.tdamp = 50;
    end
    
    % pre stabilization
    str = ['log ', par.fn_atomic_model_i, '_pre_stabilization.log', newline];
    
    str = [str, '', newline];
    str = [str, 'units metal', newline];
    str = [str, 'dimension 3', newline];
    str = [str, 'boundary ', par.boundary, newline];
    str = [str, '', newline];
    str = [str, 'atom_style atomic', newline];
    str = [str, 'read_data "', par.path_atomic_model_i, '"', newline];
    str = [str, '', newline];
    str = [str, 'pair_style ', par.eam_style,newline];
    str = [str, 'pair_coeff  * * "', par.fn_pot, '" ', par.str_El, newline];
    str = [str, '', newline];
    str = [str, 'neighbor 1.0 bin ', newline];
    str = [str, '', newline];
    str = [str, 'timestep ', num2str(par.timestep), newline];
    str = [str, 'thermo_style custom step temp pe ke etotal', newline];
    str = [str, '', newline];
    str = [str, '# Variables #', newline];
    str = [str, 'variable  l_tdamp equal ', num2str(par.tdamp), '*dt', newline];
    str = [str, 'variable  l_temp_0 equal ', num2str(par.temp_0), newline];
    str = [str, 'variable  l_temp_e equal ', num2str(par.temp_e), newline];
    str = [str, '', newline];
    str = [str, 'velocity all create ${l_temp_0} 1983 dist gaussian', newline];
    str = [str, 'velocity all zero angular', newline];
    str = [str, 'velocity all zero linear', newline];
    str = [str, '', newline];
    str = [str, '# walls #', newline];
    if par.bb_wall_reflect(1)
        str = [str, 'fix wx1 all wall/reflect xlo EDGE xhi EDGE x', newline];
    end
    if par.bb_wall_reflect(2)
        str = [str, 'fix wy1 all wall/reflect ylo EDGE yhi EDGE ', newline];
    end
    if par.bb_wall_reflect(3)
        str = [str, 'fix wz1 all wall/reflect zlo EDGE zhi EDGE ', newline];
    end
    str = [str, '', newline];
    
    if(par.ns_sr_0>0)
        str = [str, '# Structural relaxation #', newline];
        str = [str, 'neigh_modify every 1 delay 0', newline];
        str = [str, 'reset_timestep 0', newline];
        str = [str, 'thermo ', num2str(par.sr_th), newline];
        str = [str, 'min_style cg', newline];
        % minimize etol ftol maxiter maxeval
        str = [str, 'minimize ', num2str(par.sr_e_ee), ' ', num2str(par.sr_f_ee), ' ', num2str(par.ns_sr_0), ' ', num2str(2*par.ns_sr_0), newline];
        str = [str, '', newline];
    end

    str = [str, '# Pre-Stabilization #', newline];
    str = [str, 'neigh_modify every 1 delay 5', newline];
    str = [str, 'reset_timestep 0', newline];
    str = [str, 'thermo ', num2str(par.md_th), newline];
    str = [str, 'fix 10 all nvt temp ${l_temp_0} ${l_temp_0} ${l_tdamp}', newline];
    str = [str, 'run ', num2str(par.ns_md_s_0), newline];
    str = [str, 'unfix 10', newline];
    str = [str, '', newline];

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    str = [str, 'log ', par.fn_atomic_model_i, '.log', newline];
    
    str = [str, 'compute 1 all property/atom xu yu zu', newline];
    str = [str, 'variable iter_max loop ', num2str(par.n_temp), newline];
    str = [str, 'variable ik equal 0', newline];
    
    str = [str, 'label loop', newline];
    str = [str, '  variable l_temp equal ${l_temp_0}+${ik}*', num2str(par.dtemp), newline];

    str = [str, '  neigh_modify every 1 delay 5', newline];
    str = [str, '  reset_timestep 0', newline];
    str = [str, '  thermo ', num2str(par.md_th), newline];
    str = [str, '  fix 10 all nvt temp ${l_temp} ${l_temp} ${l_tdamp}', newline];
    str = [str, '  run ', num2str(par.ns_md_s), newline];
    str = [str, '  unfix 10', newline];
    str = [str, '  ', newline];

    str = [str, '  # data extraction', newline];
    str = [str, '  variable fn_stable string ', par.fn_atomic_model_o, '_temp_${l_temp}', newline];
    str = [str, '  dump d10 all custom ', num2str(par.ns_md_dump), ' ${fn_stable}.txt c_1[1] c_1[2] c_1[3]', newline];
    str = [str, '  dump_modify d10 sort id', newline];
    str = [str, '  #dump d20 all movie ', num2str(par.ns_md_dump), ' ${fn_stable}_xy.avi type type zoom 1.90 size 720 720 box no 1.0 view 0 0', newline];	
    str = [str, '  thermo ', num2str(par.md_th), newline];
    str = [str, '  fix 10 all nvt temp ${l_temp} ${l_temp} ${l_tdamp}', newline];
    str = [str, '  run ', num2str(par.ns_md_dump_iter*par.ns_md_dump), newline];
    str = [str, '  undump d10', newline];
    str = [str, '  #undump d20', newline];
    str = [str, '  unfix 10', newline];
    
    str = [str, '  variable ik equal ${ik}+1', newline];
    str = [str, '  next iter_max', newline];
    str = [str, 'jump SELF loop', newline];

%     change_box all boundary s s s

    fileID = fopen(par.fn_lmp, 'w');
    fprintf(fileID, '%s', str);
    fclose(fileID);
end