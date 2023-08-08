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
    q = qqnorm(M[:, A], layout = (1, 1), legend = :topleft, size = (900, 500), label = lb[1])
    for C in A+1:B
        qqnorm!(M[:, C], layout = (1, 1), legend = :topleft, size = (900, 500), label = lb[C])
    end
    return q
end

function h2_1(M, A, B, lb)
    q = qqplot(M[:, A], layout = (1, 1), legend = :topleft, size = (900, 500), label = lb[1])
    for C in A+1:B
        qqplot!(M[:, C], layout = (1, 1), legend = :topleft, size = (900, 500), label = lb[C])
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

function h5(A)
    return [sum(A[:, C] .< 0) for C in 1:5]
end