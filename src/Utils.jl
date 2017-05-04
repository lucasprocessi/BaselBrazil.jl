# Utils

export 	getF,
		linearXMapping

		
"""
    getF(date::Date)
	
Return F factor to convert PJUR into Risk-weigthed asset (RWA), using
the relationship ``RWA = (1/F) * PJUR``.
F is the minimum Basel Index required at date `date::Date`.

"""		
function getF(date::Date)

	if date <= Date(2015, 12, 31)
		F = 0.11
	elseif date <= Date(2016, 12, 31)
		F = 0.09875
	elseif date <= Date(2017, 12, 31)
		F = 0.0925
	elseif date <= Date(2018, 12, 31)
		F = 0.08625
	else 
		F = 0.08
	end #if
	
	return(F)
	
end #function


"""
	linearXMapping(maturities::Array{Int64,1}, exposures::Array{Float64,1}, standardizedVertices::Array{Int64,1})

Map exposures into standardized vertices (SVs), using linear method.
Suppose we have an exposure of ``X`` BRL that matures in ``T`` business days, 
and ``n`` SVs ``t_1, \ldots, \t_n`` in each we must allocate our exposure.
If ``T`` is shorter than any SV, we allocate a fraction of the exposure in the first SV:

`` SV(1) = \frac{T}{t_0} X ``

If ``T`` is longer than any SV, we allocate a multiple of the exposure in the last SV:

`` SV(n) = \frac{T}{t_n} X ``

If ``T`` lies between two vertices (``i`` and ``i+1``), we allocate a fraction of the exposure in the two adjacent vertices, 
inversely proportional to the distance between ``T`` and the vertex:

`` SV(i) = \frac{ T - t_{i+1} }{ t_{i+1} - t_i } X ``

`` SV(i+1) = \frac{ t_i - T }{ t_{i+1} - t_i } X ``.


# Parameters
* `maturities::Array{Int64,1}`: an array of maturities in business days. It is not required to pass unique or ordered maturities.
* `exposures::Array{Float64,1}`: an array of exposures (present value) to each maturity.
* `standardizedVertices::Array{Int64,1}`: an array of ordered standardized vertices in business days, 
such as package constants `VERTICES_RWAJUR1`, `VERTICES_RWAJUR2`, `VERTICES_RWAJUR3` and `VERTICES_RWAJUR4`.
 
"""
function linearXMapping(maturities::Array{Int64,1}, exposures::Array{Float64,1}, standardizedVertices::Array{Int64,1})
	if size(maturities, 1) != size(exposures, 1)
		error("maturities and exposures must have the same length")
	end #if
	if !issorted(standardizedVertices)
		error("stantardized vertices must be sorted")
	end

	N = size(maturities, 1)
	NS = size(standardizedVertices, 1)
	out = zeros(NS)
	for i = 1:N
	
		pos = sum(standardizedVertices .<= maturities[i])	
		if pos == 0 # before the first vertex
			out[1] += (maturities[i]/standardizedVertices[1]) * exposures[i] 
		elseif pos == size(standardizedVertices, 1) # after the last vertex
			out[NS] += (maturities[i]/standardizedVertices[NS]) * exposures[i]
		else # between two vertices
			alpha = (standardizedVertices[pos+1] - maturities[i])/(standardizedVertices[pos+1] - standardizedVertices[pos])
			out[pos] += alpha * exposures[i]
			out[pos+1] += (1-alpha) * exposures[i]
		end
		
	end #for
	return(out)
end #function

"""
	linearXMapping(date::Date, maturities::Array{Date, 1}, exposures::Array{Float64, 1}, standardizedVertices::Array{Int64, 1})

Map exposures into standardized vertices (SVs), using linear method and calculating maturities in business days using 
Brazilian holiday calendar.
See `linearXMapping(maturities::Array{Int64,1}, exposures::Array{Float64,1}, standardizedVertices::Array{Int64,1})` for more info.

# Parameters
* `date::Date`: date of evaluation
* `maturities::Array{Int64,1}`: an array of maturities (dates). It is not required to pass unique or ordered maturities.
* `exposures::Array{Float64,1}`: an array of exposures (present value) to each maturity.
* `standardizedVertices::Array{Int64,1}`: an array of ordered standardized vertices in business days, 
such as package constants `VERTICES_RWAJUR1`, `VERTICES_RWAJUR2`, `VERTICES_RWAJUR3` and `VERTICES_RWAJUR4`.
 
"""
function linearXMapping(date::Date, maturities::Array{Date, 1}, exposures::Array{Float64, 1}, standardizedVertices::Array{Int64, 1})
	linearXMapping(map(x -> x.value, 
				     bdays(:Brazil, date, maturities)), 
				 exposures, 
				 standardizedVertices)	
end #function
