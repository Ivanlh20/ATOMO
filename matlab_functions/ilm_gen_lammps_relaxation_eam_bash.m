function[] =ilm_gen_lammps_relaxation_eam_bash(par)
    n_gpu = id_gpu_e-id_gpu_0+1;

    if(ispc)
        str_ap = '';
        fn_bash = [par.fn_bash, '.bat'];
        lmp_name = 'lmp_mpi';
        pf = 'set ';
        b_l = '%';
        b_r = '%';
        str_gpu = '';
        str = '';
        
        str_exec = '';
        if(nproc>1)
            str_exec = ['mpiexec -np ', num2str(par.np_gpu), ' '];
        end
    else
        str_ap = '"';
        fn_bash = [par.fn_bash, '.sh'];
        lmp_name = 'lmps';
        b_l = '${';
        b_r = '}';
        pf = '';
        str_gpu = [' -sf gpu -pk gpu ', num2str(n_gpu), ' gpuID ', num2str(par.id_gpu_0), ' ', num2str(par.id_gpu_e)];
        str = [pf, '#!/bin/bash', newline];
        str = [str, pf, 'clear', newline];
        
        str_exec = '';
        if(nproc>1)
            str_exec = ['mpiexec -np ', num2str(n_gpu*par.np_gpu), ' '];
        end
    end
    str_exec = [str_exec, lmp_name, str_gpu];
    
    str = [str, pf, 'OMP_NUM_THREADS=1', newline]; 
    str = [str, pf, 'bi_fn_lmp=', par.fn_lmp, newline];  
    str = [str, pf, 'bi_timestep=', num2str(par.timestep), newline];    
    str = [str, pf, 'bi_temp_0=', num2str(par.temp_0), newline];
    str = [str, pf, 'bi_temp_e=', num2str(par.temp_e), newline];
    
    str = [str, pf, 'bi_input=', str_ap, '-var li_temp_0 ', b_l, 'bi_temp_0', b_r,...
    ' -var li_temp_e ', b_l, 'bi_temp_e', b_r, ' -var li_timestep ',...
    b_l, 'bi_timestep', b_r, ' -in ', b_l, 'bi_fn_lmp', b_r', str_ap, newline];
    str = [str, str_exec, ' ', b_l, 'bi_input', b_r];

    fileID = fopen(fn_bash, 'w');
    fprintf(fileID, '%s', str);
    fclose(fileID);
    if isunix
        fileattrib(fn_bash, '+x');
    end
end
