using DataFrames, Dates, EzXML, HTTP, Serialization

NBASE =
    "https://data.treasury.gov/feed.svc/DailyTreasuryYieldCurveRateData?"
RBASE =
    "https://data.treasury.gov/feed.svc/DailyTreasuryRealYieldCurveRateData?"

NNAME = Dict(
    "BC_1MONTH" => 3,
    "BC_2MONTH" => 4,
    "BC_3MONTH" => 5,
    "BC_6MONTH" => 6,
    "BC_1YEAR"  => 7,
    "BC_2YEAR"  => 8,
    "BC_3YEAR"  => 9,
    "BC_5YEAR"  => 10,
    "BC_7YEAR"  => 11,
    "BC_10YEAR" => 12,
    "BC_20YEAR" => 13,
    "BC_30YEAR" => 14,
    "BC_30YEARDISPLAY" => 15
)

RNAME = Dict(
    "TC_1MONTH" => 3,
    "TC_2MONTH" => 4,
    "TC_3MONTH" => 5,
    "TC_6MONTH" => 6,
    "TC_1YEAR"  => 7,
    "TC_2YEAR"  => 8,
    "TC_3YEAR"  => 9,
    "TC_5YEAR"  => 10,
    "TC_7YEAR"  => 11,
    "TC_10YEAR" => 12,
    "TC_20YEAR" => 13,
    "TC_30YEAR" => 14,
    "TC_30YEARDISPLAY" => 15
)


function __get_HTTPS_Resp_Data(yr, nom)
    if !(nom in [true, false])
        throw(UndefKeywordError(:nom))
    end
    sux = nom == true ?
        HTTP.get(NBASE * "\$" * "filter=year(NEW_DATE)%20eq%20" * yr) :
        HTTP.get(RBASE * "\$" * "filter=year(NEW_DATE)%20eq%20" * yr)
    return String(sux.body)
end

function __get_DataFrame(sux, nom)
    xdoc = parsexml(sux)
    s = [join(I, "") for I in 1:15]
    n = [nodename.(findall("/*/*/*/*/*[" * I * "]", xdoc)) for I in s]
    y = [nodecontent.(findall("/*/*/*/*/*[" * I * "]", xdoc)) for I in s]

    U = [y[1] y[2]]
    for M in 3:size(y[:])[1]
        U = hcat(U, ["NaN" for I in 1:size(y[1])[1]])
    end

    I = 3
    while I <= size(y)[1] && y[I] !=([])
        for J in 2:size(y[:])[1]
            @assert n[I][1] ==(n[I][J])
        end
        for J in 1:size(y[:])[1]
            @assert U[J, I] !=("")
        end
        if nom == true
            U[:, NNAME[n[I][1]]] = y[I]
        elseif nom == false
            U[:, RNAME[n[I][1]]] = y[I]
        else
            throw(UndefVarError(:nom))
        end
        [U[i, I] ==("") ? U[i, I] = join(NaN, "") :
                          U[i, I] for i in 1:size(U)[1]]
        I += 1
    end

    [U[i, I] ==("") ? U[i, I] = join(NaN, "") :
                          U[i, I] for i in 1:size(U)[1], I in 1:size(U)[2]]

    I = 4
    K = nom ? NNAME : RNAME
    B = U .== "NaN"
    while I < size(y)[1]-1 && y[I] !=([])
        if sum(B[:, I]) == size(U)[1]
            if sum(B[:, I-1]) == 0 && sum(B[:, I+1]) == 0
                L1 = parse.(Float64, U[:, I-1])
                L2 = parse.(Float64, U[:, I+1])
                U[:, I] = [join(interpolateValue(
                                        (I-1, L1[i]),
                                        (I+1, L2[i]), I), "") for i in 1:size(U)[1]]
            end
        end
        I += 1
    end

    tux = DataFrame(
        Id = parse.(Int64, U[:, 1]),
        dt = Dates.DateTime.(U[:, 2]),
        BC_1MONTH = parse.(Float64, U[:, 3]),
        BC_2MONTH = parse.(Float64, U[:, 4]),
        BC_3MONTH = parse.(Float64, U[:, 5]),
        BC_6MONTH = parse.(Float64, U[:, 6]),
        BC_1YEAR  = parse.(Float64, U[:, 7]),
        BC_2YEAR  = parse.(Float64, U[:, 8]),
        BC_3YEAR  = parse.(Float64, U[:, 9]),
        BC_5YEAR  = parse.(Float64, U[:, 10]),
        BC_7YEAR  = parse.(Float64, U[:, 11]),
        BC_10YEAR = parse.(Float64, U[:, 12]),
        BC_20YEAR = parse.(Float64, U[:, 13]),
        BC_30YEAR = parse.(Float64, U[:, 14]),
        BC_30YEARDISPLAY = parse.(Float64, U[:, 15])
    )
    return tux
end

function __get_HTTPS_Resp_Data(mo, yr, nom)
    sux = nom == true ?
        HTTP.get(NBASE * "\$" * "filter=month(NEW_DATE)%20eq%20" * mo *
                                "%20and%20year(NEW_DATE)%20eq%20" * yr) :
        HTTP.get(RBASE * "\$" * "filter=month(NEW_DATE)%20eq%20" * mo *
                                "%20and%20year(NEW_DATE)%20eq%20" * yr)
    return String(sux.body)
end

function interpolateValue((x_a, y_a), (x_b, y_b), x)
    y = y_a + (y_b - y_a) * ((x - x_a) / (x_b - x_a))
    return y
end

function DailyTreasuryYieldCurveRateData(yr, nom)
    sux = __get_HTTPS_Resp_Data("1", yr, nom)
    tvx = DailyTreasuryYieldCurveRateData("1", yr, nom)
    for mo in [join(I, "") for I in 2:12]
        sux = __get_HTTPS_Resp_Data(mo, yr, nom)
        tux = DailyTreasuryYieldCurveRateData(mo, yr, nom)
        tvx = append!(tvx, tux)
    end
    return tvx
end

function DailyTreasuryYieldCurveRateData(mo, yr, nom)
    sux = __get_HTTPS_Resp_Data(mo, yr, nom)
    tux = __get_DataFrame(sux, nom)
    return tux
end

function saveYieldCurveRateData(xtux)
    serialize("/home/chrx/Documents/saved1", tux)
end