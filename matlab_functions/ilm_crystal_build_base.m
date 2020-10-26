function[base]=ilm_crystal_build_base(crystal_par, sg)
    if(nargin<2)
        sg = importdata('space_groups.mat');
    end

    sym = sg(crystal_par.sgn);

    uc = crystal_par.asym_uc;
    n_uc = size(uc, 1);
    M = permute(sym.M, [2, 1, 3]); % tranpose fro x*M
    n_M = size(M, 3);
    n_tr_g = size(sym.tr_g, 1);
    base = zeros(256, size(uc, 2));
    ic = 0;
    ee2 = (1e-4)^2;
    for i_g = 1:n_tr_g
        tr_g = sym.tr_g(i_g, :);
        for is = 1:n_M
            M_ik = M(:, :, is);
            tr = sym.tr(is, :) + tr_g;
            tr = tr - floor(tr);
            for it = 1:n_uc
                r = uc(it, 2:4)*M_ik + tr;
                r = r - floor(r);
                if((ic==0))
                    ic = ic + 1;
                    base(ic, :) = [uc(it, 1), r, uc(it, 5:end)];
                else
                    ii = find(sum((base(1:ic, 2:4)-r).^2, 2)<ee2);
                    if(size(ii, 1)==0)
                        ic = ic + 1;
                        base(ic, :) = [uc(it, 1), r, uc(it, 5:end)];
                    end
                end
            end
        end
    end
    base = base(1:ic, :);
end