cfg_control = get_config("test.yaml")

ind = NEATIndiv(cfg)
ind_control = NEATIndiv(ind)
@test test_identical(ind, ind_control)

@testset "Mutation Weight" begin
    cfg = get_config("test.yaml")
    cfg["p_mut_weights"]=1
    ind_mut = mutate_weight(ind, cfg)
    @test test_identical(ind, ind_control)
    @test !test_identical(ind, ind_mut)
end

@testset "Mutation Add connection" begin
    cfg = get_config("test.yaml")
    ind_mut = mutate_connect(ind, cfg)
    @test test_identical(ind, ind_control)
    @test !test_identical(ind, ind_mut)
    @test length(ind.genes) < length(ind_mut.genes)
    @test cfg["innovation_max"] > cfg_control["innovation_max"]
end

@testset "Mutation Add neuron" begin
    cfg = get_config("test.yaml")
    ind_mut = mutate_neuron(ind, cfg)
    @test test_identical(ind, ind_control)
    @test !test_identical(ind, ind_mut)
    @test length(ind.neuron_pos) < length(ind_mut.neuron_pos)
end

@testset "Mutation Enable" begin
    cfg = get_config("test.yaml")
    ind_mut = mutate_enabled(ind, cfg)
    @test test_identical(ind, ind_control)
    @test !test_identical(ind, ind_mut)
    enabled = true
    for g in values(ind_mut.genes)
        enabled &= g.enabled
    end
    @test ! enabled
end

@testset "Mutation" begin
    cfg = get_config("test.yaml")
    cfg["p_mutate_enabled"] = 1 # Ensure there is a mutation
    cfg["p_mut_weights"]=1 # Ensure weights mutation really happens
    ind_mut = mutate(ind, cfg)
    @test test_identical(ind, ind_control)
    @test !test_identical(ind, ind_mut)
end
