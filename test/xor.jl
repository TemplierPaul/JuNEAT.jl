function xor(a::Float64, b::Float64)
    if a + b == 1
        1.
    else
        0.
    end
end

"Array to array XOR"
function xor(a::Array{Float64})
    v = a[1]
    for i in 2:length(a)
        v = xor(v, a[i])
    end
    [v]
end

function rand_bin(len::Int64)
    1.0 * rand(0:1, len)
end

function xor_dataset(len::Int64, n_records::Int64)
    X::Array{Array{Float64}}=[]
    y::Array{Array{Float64}}=[]
    for i in 1:n_records
        l = rand_bin(len)
        push!(X, l)
        push!(y, xor(l))
    end
    X, y
end

@testset "XOR data generator" begin
    a = rand_bin(20)
    @test length(a) == 20
    @test all(a.<=1)
    @test all(a.>=0)
    @test all(typeof.(a) .== Float64)

    b = xor(a)
    @test all(typeof.(b) .== Float64)
    @test length(b) == 1

    X, y = xor_dataset(20, 100)
    @test length(X)==100
    @test length(y)==100
    @test length(X[1])==20
    @test all(typeof.(y[1]) .== Float64)

    @test all(xor.(X) .== y)
end

function log_loss(y_true::Float64, y_pred::Float64)
    y_pred = maximum([minimum([y_pred, 1-10^-15]), 10^-15])
    if y_true == 1.0
        -log(y_pred)
    else
        -log(1-y_pred)
    end
end

function log_loss(y_true::Int64, y_pred::Int64)
    log_loss(float(y_true), float(y_pred))
end

function log_loss(y_true::Array, y_pred::Array)
    log_loss(y_true[1], y_pred[1])
end

function log_fitness(y_true, y_pred)
    max_loss = log_loss(y_true, 1 .- y_true)
    max_loss - log_loss(y_true, y_pred)
end

@testset "Log Loss" begin
    @test log_loss(0, 0) < 0.01
    @test log_loss(0, 1) > 0
    @test log_loss(1, 1) < 0.01
    @test log_loss(1, 0) > 0

    X, y = xor_dataset(20, 100)
    @test sum(log_loss.(y, y)) < 0.1
end

function fitness_xor(indiv::NEATIndiv, len::Int64=2)
    X, y = xor_dataset(len, 100)
    y_pred = process(indiv, X)
    [sum(log_fitness.(y, y_pred)) / length(X)]
end
