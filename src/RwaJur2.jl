# RwaJur2

export VERTICES_RWAJUR2,
		RwaJur2Exposure,
		RwaJur2Parameters,
		getLongExposureArray,
		getShortExposureArray,
		getRwaJur2NetExposure,
		getRwaJur2VerticalGap,
		getRwaJur2Zones,
		getRwaJur2HorizontalGapWithinZones,
		getRwaJur2HorizontalGapBetweenZones,
		getPJur2,
		getRwaJur2

"""
Standardized vertices for mapping foreign currency coupon rate exposures (RWAJUR2)
"""	
const VERTICES_RWAJUR2 = [1, 21, 42, 63, 126, 252, 504, 756, 1008, 1260, 2520]

"""
    RwaJur2Exposure

Holds exposures in foreign currency coupon rates.

# Fields
* `date::Date`: date of evaluation
* `VXX::Float64`: exposure to vertex XX, 
given by the sum of present value in BRL 
of all cashflows that matures in XX business days (BD).
 
# Constructors
    RwaJur2Exposure(date::Date)

Create an instance with all exposures equal to zero.
	
	RwaJur2Exposure(date::Date, currency::AbstractString, longExposures::Array{Float64, 1}, shortExposures::Array{Float64, 1})

Create an instance with exposures given by two vectors of length 10 containing long and short exposures.
Exposures are assigned in sequence from vertex 1 BD to vertex 2520 BD.	

"""
type RwaJur2Exposure
	# Date of evaluation
	date::Date
	# Currency
	currency::AbstractString
	# Exposures in standard vertices: VXX, where XX is a maturity calculated in business days
	# LONG EXPOSURES
	V1Long::Float64
	V21Long::Float64
	V42Long::Float64
	V63Long::Float64
	V126Long::Float64
	V252Long::Float64
	V504Long::Float64
	V756Long::Float64
	V1008Long::Float64
	V1260Long::Float64
	V2520Long::Float64
	# SHORT EXPOSURES
	V1Short::Float64
	V21Short::Float64
	V42Short::Float64
	V63Short::Float64
	V126Short::Float64
	V252Short::Float64
	V504Short::Float64
	V756Short::Float64
	V1008Short::Float64
	V1260Short::Float64
	V2520Short::Float64
	
	# Constructors
	RwaJur2Exposure(date::Date, currency::AbstractString) = new(date, currency, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
	
	function RwaJur2Exposure(date::Date, currency::AbstractString, longExposures::Array{Float64, 1}, shortExposures::Array{Float64, 1})                                                     
		if size(longExposures, 1) != 11
			error("long exposures must have 11 values")
		end #if
		if any(longExposures .< 0)
			error("all long exposures must be positive")
		end #if
		
		if size(shortExposures, 1) != 11
			error("short exposures must have 11 values")
		end #if
		if any(shortExposures .< 0)
			error("all short exposures must be positive")
		end #if
		
		new(date,
			currency,		
		    longExposures[1], longExposures[2], longExposures[3], longExposures[4],                      
			longExposures[5], longExposures[6], longExposures[7], longExposures[8],                      
			longExposures[9], longExposures[10], longExposures[11],
			shortExposures[1], shortExposures[2], shortExposures[3], shortExposures[4],                      
			shortExposures[5], shortExposures[6], shortExposures[7], shortExposures[8],                      
			shortExposures[9], shortExposures[10], shortExposures[11]		
			)
	end #function
	
end #type

"""
	RWAJUR1Parameters
	
Holds BCB parameters to calculate foreign currency coupon stantardized capital (RWA JUR2)

"""
type RwaJur2Parameters
	date::Date
	M2::Float64
end #type

"""
    getLongExposureArray(rExp::RwaJur2Exposure)

Return a vector with all long exposures in sequence, 
from vertex 1 BD to vertex 2520 BD.
    
"""
getLongExposureArray(rExp::RwaJur2Exposure) = [rExp.V1Long, rExp.V21Long, rExp.V42Long, rExp.V63Long, rExp.V126Long, rExp.V252Long, rExp.V504Long, rExp.V756Long, rExp.V1008Long, rExp.V1260Long, rExp.V2520Long] 

"""
    getShortExposureArray(rExp::RwaJur2Exposure)

Return a vector with all short exposures in sequence, 
from vertex 1 BD to vertex 2520 BD.
    
"""
getShortExposureArray(rExp::RwaJur2Exposure) = [rExp.V1Short, rExp.V21Short, rExp.V42Short, rExp.V63Short, rExp.V126Short, rExp.V252Short, rExp.V504Short, rExp.V756Short, rExp.V1008Short, rExp.V1260Short, rExp.V2520Short] 

"""
    getRwaJur2NetExposure(rExp::RwaJur2Exposure)

Return a vector containing RWA JUR2 weighted net exposures.
    
"""
function getRwaJur2NetExposure(rExp::RwaJur2Exposure)
	Y = ([0.0, 0.5, 0.7, 0.8, 1.2, 2.0, 4.0, 6.0, 8.0, 10.0, 18.0]/100)
	(getLongExposureArray(rExp) - getShortExposureArray(rExp)) .* Y
end #function

"""
    getRwaJur2VerticalGap(rExp::RwaJur2Exposure)

Return a vector containing RWA JUR2 vertical gaps.
    
"""
function getRwaJur2VerticalGap(rExp::RwaJur2Exposure)
	Y = ([0.0, 0.5, 0.7, 0.8, 1.2, 2.0, 4.0, 6.0, 8.0, 10.0, 18.0]/100)
	0.1 * ( min(abs(getLongExposureArray(rExp)), abs(getShortExposureArray(rExp))) .* Y) 
end #function

"""
    getRwaJur2Zones(rExp::RwaJur2Exposure)

Return a matrix containing RWA JUR2 zone exposures.
Column 1 contains long exposures, column2 contains short exposures.
Zones are represented in each of the 3 rows.
    
"""
function getRwaJur2Zones(rExp::RwaJur2Exposure)
	EL = getRwaJur2NetExposure(rExp)
	
	Z = zeros(3, 2)
	
	# Zone #1
	for i = 1:5
		if EL[i] >= 0
			Z[1, 1] += EL[i]
		else
			Z[1, 2] += EL[i]
		end #if
	end #for
	
	# Zone #2
	for i = 6:8
		if EL[i] >= 0
			Z[2, 1] += EL[i]
		else
			Z[2, 2] += EL[i]
		end #if
	end #for
	
	# Zone #3
	for i = 9:11
		if EL[i] >= 0
			Z[3, 1] += EL[i]
		else
			Z[3, 2] += EL[i]
		end #if
	end #for
	
	return(Z)
end #function

"""
    getRwaJur2HorizontalGapWithinZones(rExp::RwaJur2Exposure)

Return a vector containing RWA JUR2 horizontal gap within zones.
    
"""
function getRwaJur2HorizontalGapWithinZones(rExp::RwaJur2Exposure)

	Z = getRwaJur2Zones(rExp)
	
	DHZ = zeros(3)
	W = [0.4, 0.3, 0.3]
	for i = 1:3
		DHZ[i] = min(Z[i, 1], abs(Z[i, 2])) * W[i]
	end #for
	
	return(DHZ)
	
end #function

"""
    getRwaJur2HorizontalGapBetweenZones(rExp::RwaJur2Exposure)

Return a vector containing RWA JUR2 horizontal gap between zones.
    
"""
function getRwaJur2HorizontalGapBetweenZones(rExp::RwaJur2Exposure)
	Z = getRwaJur2Zones(rExp)
	DHE = sum(Z, 2)[:,1]
	DHEZ = 0

	if DHE[1] * DHE[2] < 0
		DHEZ += min(abs(DHE[1]), abs(DHE[2])) * 0.4
	end #if
	if DHE[2] * DHE[3] < 0
		DHEZ += min(abs(DHE[2]), abs(DHE[3])) * 0.4
	end #if
	if DHE[1] * DHE[3] < 0
		DHEZ += min(abs(DHE[1]), abs(DHE[3])) * 1.0
	end #if
	
	return(DHEZ)
	
end #function

"""
	getPJur2(rExp::RwaJur2Exposure, par::RwaJur2Parameters)
	
Calculate PJUR2 using maturity ladder methodology.

"""
function getPJur2(rExp::RwaJur2Exposure, par::RwaJur2Parameters)
	EL = getRwaJur2NetExposure(rExp)
	DV = getRwaJur2VerticalGap(rExp)
	DHZ = getRwaJur2HorizontalGapWithinZones(rExp)
	DHE = getRwaJur2HorizontalGapBetweenZones(rExp)
	
	par.M2 * (abs(sum(EL)) + sum(abs(DV)) + sum(abs(DHZ)) + DHE)	
end #function

"""
	getRwaJur2(rExp::RwaJur2Exposure, par::RwaJur2Parameters)
	
Calculate risk-weighted assets for foreign currency coupon exposures (RWA JUR2),
using maturity ladder methodology.
	
"""
function getRwaJur2(rExp::RwaJur2Exposure, par::RwaJur2Parameters)
	(1/(getF(par.date))) * getPJur2(rExp, par)
end #function

