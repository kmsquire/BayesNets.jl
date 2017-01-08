"""
Exact inference using factors and variable eliminations
"""
type ExactInference <: InferenceMethod
end
function infer(::ExactInference, inf::AbstractInferenceState)
    bn = inf.bn
    nodes = names(inf)
    query = inf.query
    evidence = inf.evidence
    hidden = setdiff(nodes, vcat(query, names(evidence)))

    factors = map(n -> Factor(bn, n, evidence), nodes)

    # successively remove the hidden nodes
    # order impacts performance, but we currently have no ordering heuristics
    for h in hidden
        # find the facts that contain the hidden variable
        contain_h = filter(ϕ -> h in ϕ, factors)
        # add the product of those factors to the set
        if !isempty(contain_h)
            # remove those factors
            factors = setdiff(factors, contain_h)
            push!(factors, sum(reduce((*), contain_h), h))
        end
    end

    ϕ = normalize!(reduce((*), factors))
    return ϕ
end

