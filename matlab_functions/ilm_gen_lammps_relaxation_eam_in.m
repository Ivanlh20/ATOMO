function[] = ilm_gen_lammps_relaxation_eam_in(par)
    % 2019 Ivan Lobato <Ivanlh20@gmail.com>
    par.path_atomic_model_i = strtrim(par.path_atomic_model_i);
    par.path_atomic_model_o = strtrim(par.path_atomic_model_o);
    
    par.path_atomic_model_i = strrep(par.path_atomic_model_i, '\', '/');
    par.path_atomic_model_o = strrep(par.path_atomic_model_o, '\', '/');
    par.fn_pot = strrep(par.fn_pot, '\', '/');
    
    par.fn_pot = strtrim(par.fn_pot);
    par.eam_style = strtrim(par.eam_style);
    
    if(~isfield(par, 'tdamp'))
        par.tdamp = 100;
    end
    
    str = ['log ', par.fn_atomic_model_i, '.log', newline];
    str = [str, '', newline];
    str = [str, 'units metal', newline];
    str = [str, 'dimension 3', newline];
    str = [str, 'boundary ', par.boundary, newline];
    str = [str, '', newline];
    str = [str, 'atom_style atomic', newline];
    str = [str, 'read_data ', par.path_atomic_model_i,newline];
    str = [str, '', newline];
    % style = eam or eam/alloy or eam/cd or eam/fs
    str = [str, 'pair_style ', par.eam_style,newline];
    str = [str, 'pair_coeff  * * ', par.fn_pot, ' ', par.str_El,newline];
    str = [str, '', newline];
    str = [str, 'neighbor 1.0 bin ', newline];
    str = [str, 'neigh_modify every 1 delay 1', newline];
    str = [str, '', newline];
    str = [str, 'timestep ${li_timestep}', newline];
    str = [str, 'thermo_style custom step temp pe ke etotal', newline];
    str = [str, 'variable  l_tdamp equal ', num2str(par.tdamp), '*dt', newline];
    str = [str, '', newline];
    str = [str, 'velocity all create ${li_temp_0} 1983 dist gaussian', newline];
    str = [str, 'velocity all zero angular', newline];
    str = [str, 'velocity all zero linear', newline];
    str = [str, '', newline];
    if(par.sr_ns_0>0)
        str = [str, '# Structural relaxation #', newline];
        str = [str, 'neigh_modify every 1 delay 0', newline];
        str = [str, 'reset_timestep 0', newline];
        str = [str, 'thermo ', num2str(par.sr_th), newline];
        str = [str, 'min_style cg', newline];
        % minimize etol ftol maxiter maxeval
        str = [str, 'minimize ', num2str(par.sr_e_ee), ' ', num2str(par.sr_f_ee), ' ', num2str(par.sr_ns_0), ' ', num2str(2*par.sr_ns_0), newline];
        str = [str, '', newline];
    end
    
    if(par.md_ns_h>0)
        str = [str, '# heating #', newline];
        str = [str, 'neigh_modify every 1 delay 1', newline];
        str = [str, 'reset_timestep 0', newline];
        str = [str, 'thermo ', num2str(par.md_th), newline];
        str = [str, 'fix 10 all nvt temp ${li_temp_0} ${li_temp_e} ${l_tdamp}', newline];
        str = [str, 'run ', num2str(par.md_ns_h), newline];
        str = [str, 'unfix 10', newline];
        str = [str, '', newline];
    end
    
    if(par.md_ns_s>0)
        str = [str, '# stable #', newline];
        str = [str, 'neigh_modify every 1 delay 1', newline];
        str = [str, 'reset_timestep 0', newline];
        str = [str, 'thermo ', num2str(par.md_th), newline];
        str = [str, 'fix 10 all nvt temp ${li_temp_e} ${li_temp_e} ${l_tdamp}', newline];
        str = [str, 'run ', num2str(par.md_ns_s), newline];
        str = [str, 'unfix 10', newline];
        str = [str, '', newline];
    end
    
    if(par.sr_ns_e>0)
        str = [str, '# Structural relaxation #', newline];
        str = [str, 'neigh_modify every 1 delay 0', newline];
        str = [str, 'reset_timestep 0', newline];
        str = [str, 'thermo ', num2str(par.sr_th), newline];
        str = [str, 'min_style cg', newline];
        str = [str, 'minimize ', num2str(par.sr_e_ee), ' ', num2str(par.sr_f_ee), ' ', num2str(par.sr_ns_e), ' ', num2str(2*par.sr_ns_e), newline];
        str = [str, '', newline];
    end
    
    str = [str, '#write_dump all custom ', par.path_atomic_model_o, ' id type x y z modify sort id', newline];
    str = [str, 'write_dump all custom ', par.path_atomic_model_o, ' x y z modify sort id'];

    fileID = fopen(par.fn_lmp, 'w');
    fprintf(fileID, '%s', str);
    fclose(fileID);
end