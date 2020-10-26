% bs = size, bd = border
function[bd] = ilm_pn_border(bs, bd, opt)
    if(nargin<3)
        opt = 5;
    end
    
    n = length(bd);
    for ik=1:n
        bd(ik) = round((il_pn_fact(bs(ik)+2*bd(ik), opt)-bs(ik))/2);
    end
    bd = bd(1:n);
end