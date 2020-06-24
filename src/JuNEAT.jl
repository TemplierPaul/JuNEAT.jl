module JuNEAT

using Cambrian
using YAML
using JSON
using Random

include("config.jl")
include("utils.jl")

include("gene.jl")
include("network.jl")
include("individual.jl")
include("process.jl")

include("mutation.jl")
include("crossover.jl")

include("evaluation.jl")

end # module
