"""
A Julia package to calculate standardized capital requirements 
regulated by Brazilian financial system's supervisor (Brazilian Central Bank - BCB or BACEN).
"""
module BaselBrazil

	using Dates
	
	# Utils
	include("Utils.jl")
	
	# Market Risk
	## Rates
	include("RwaJur1.jl")
	include("RwaJur2.jl")
	include("RwaJur3.jl")
	include("RwaJur4.jl")
	## Currencies
	include("RwaCam.jl")

end # module
