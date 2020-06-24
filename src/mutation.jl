export mutate_weight, mutate_connect, mutate_neuron, mutate_enabled, mutate

"Mutate the weight of genes"
function mutate_weight(ind::NEATIndiv, cfg::Dict)
    #TODO Add mutation power
    # https://github.com/FernandoTorres/NEAT/blob/master/src/genome.cpp
    ind_mut = NEATIndiv(ind)
    for g in values(ind_mut.genes)
        if rand() < cfg["p_mut_weights"]
            g.weight = g.weight + randn()*cfg["weight_factor"]
        end
    end
    ind_mut
end

function indexof(a::Array{Float64}, f::Float64)
    findall(x->x==f, a)[1]
end

"Add a connection between 2 random neurons"
function mutate_connect(ind::NEATIndiv, cfg::Dict)
    sort!(ind.neuron_pos)

    ind_mut = NEATIndiv(ind)
    nb_neur = length(ind_mut.neuron_pos)

    n_in = cfg["n_in"]
    n_out = cfg["n_out"]

    # Valid neuron pairs
    valid = trues(nb_neur, nb_neur)

    # Remove existing ones
    for g in values(ind.genes)
        i_origin = indexof(ind.neuron_pos, g.origin)
        i_dest = indexof(ind.neuron_pos, g.destination)
        valid[i_origin, i_dest]=false
    end


    for dest in 1:nb_neur
        valid[dest, dest]=false # Remove links to self
        for orig in 1:n_in
            valid[orig, dest]=false # Remove links towards input neurons
        end
    end

    # TODO solve issue with links between 2 output neurons:
    # recurrence depends on output order

    # Filter invalid ones
    conns = findall(valid)
    if length(conns) > 0
        shuffle!(conns) # Pick random
        cfg["innovation_max"] += 1

        i = ind.neuron_pos[conns[1][1]]
        j = ind.neuron_pos[conns[1][2]]

        g = Gene(i, j, cfg["innovation_max"])

        ind_mut.genes[cfg["innovation_max"]]=g
        ind_mut.network = Network(n_in, n_out, Dict()) # Reset network
    end
    ind_mut
end

"Split a connection into 2 connections with a new neuron"
function mutate_neuron(ind::NEATIndiv, cfg::Dict)
    ind_mut = NEATIndiv(ind)

    if length(ind.genes)==0
        return ind_mut
    end

    # Connection to split
    g = rand(collect(values(ind_mut.genes)))
    g.enabled = false

    # Create neuron between origin and destination, in [0; 1]
    n_min = maximum([0, g.destination, g.origin])
    n_max = minimum([1, g.destination, g.origin])
    n = n_min + rand() * (n_max - n_min)
    push!(ind_mut.neuron_pos, n)
    sort!(ind_mut.neuron_pos)

    # Create connections
    i = cfg["innovation_max"]
    ind_mut.genes[i+1] = Gene(g.origin, n, i+1)
    ind_mut.genes[i+2] = Gene(n, g.destination, i+2)
    cfg["innovation_max"] +=2

    ind_mut
end

"Switch enabled"
function mutate_enabled(ind::NEATIndiv, cfg::Dict)
    ind_mut = NEATIndiv(ind)
    g = rand(collect(values(ind_mut.genes)))
    g.enabled = !g.enabled
    ind_mut
end

function mutate(ind::NEATIndiv, cfg::Dict)
    if rand() < cfg["p_mutate_add_neuron"]
        return mutate_neuron(ind, cfg)
    elseif rand() < cfg["p_mutate_add_connection"]
        return mutate_connect(ind, cfg)
    elseif rand() < cfg["p_mutate_weights"]
        return mutate_weight(ind, cfg)
    elseif rand() < cfg["p_mutate_enabled"]
        return mutate_enabled(ind, cfg)
    end
    # return clone if no mutation occurs
    NEATIndiv(ind)
end
