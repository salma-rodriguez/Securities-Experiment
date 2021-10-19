function h1(s, lb, train_percentage)
    nr = size(s)[1]
    nc = size(s)[2]
    s_train = s[1:floor(Int, train_percentage*nr), :]
    s_test = s[(floor(Int, train_percentage*nr)+1):nr, :]
    p = plot(s_train[:, 1],
                layout = (1, 1), legend = :topright, size = (900, 500), xlab = "days", ylab = "inf%", label = lb[1])
    for C in 2:nc
        plot!(s_train[:, C],
                layout = (1, 1), legend = :topright, size = (900, 500), xlab = "days", ylab = "inf%", label = lb[C])
    end
    return s_train, s_test, p
end

function h2(M, A, B, lb)
    q = qqnorm(M[:, A], layout = (1, 1), legend = :topright, size = (900, 500), label = lb[1])
    for C in A+1:B
        qqnorm!(M[:, C], layout = (1, 1), legend = :topright, size = (900, 500), label = lb[C])
    end
    return q
end

function h3(M, A, B)
    b = boxplot(M[:, A], layout = (1, 1), legend = :bottomright, size = (900, 500))
    for C in A+1:B
        boxplot!(M[:, C])
    end
    return b
end

function h4(M, T, A, B, lb)
    b = plot(M[:, A], layout = (1, 1), legend = :topleft, size = (900, 500), title = T, label = lb[A])
    for C in A+1:B
        plot!(M[:, C], label = lb[C])
    end
    return b
end

function h5(N, R)
    tup = Array{Tuple, 1}(undef, 5)
    tup[1] = (5, sum(N[:, :BC_5YEAR] .<= 0), sum(R[:, :BC_5YEAR] .<= 0))
    tup[2] = (7, sum(N[:, :BC_7YEAR] .<= 0), sum(R[:, :BC_7YEAR] .<= 0))
    tup[3] = (10, sum(N[:, :BC_10YEAR] .<= 0), sum(R[:, :BC_10YEAR] .<= 0))
    tup[4] = (20, sum(N[:, :BC_20YEAR] .<= 0), sum(R[:, :BC_20YEAR] .<= 0))
    tup[5] = (30, sum(N[:, :BC_30YEAR] .<= 0), sum(R[:, :BC_30YEAR] .<= 0))
    return tup
end