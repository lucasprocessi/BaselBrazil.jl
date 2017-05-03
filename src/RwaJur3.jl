# RwaJur3

export VERTICES_RWAJUR3,
		RwaJur3Exposure,
		RwaJur3Parameters,
		getLongExposureArray,
		getShortExposureArray,
		getRwaJur3NetExposure,
		getRwaJur3VerticalGap,
		getRwaJur3Zones,
		getRwaJur3HorizontalGapWithinZones,
		getRwaJur3HorizontalGapBetweenZones,
		getPJur3,
		getRwaJur3

"""
Standardized vertices for mapping price index coupon rate exposures (RWAJUR3)
"""	
const VERTICES_RWAJUR3 = VERTICES_RWAJUR2

"""
    RwaJur3Exposure

Holds exposures in price index coupon rates.

# Fields
* `date::Date`: date of evaluation
* `VXX::Float64`: exposure to vertex XX, 
given by the sum of present value in BRL 
of all cashflows that matures in XX business days (BD).
 
# Constructors
    RwaJur3Exposure(date::Date)

Create an instance with all exposures equal to zero.
	
	RwaJur2Exposure(date::Date, currency::AbstractString, longExposures::Array{Float64, 1}, shortExposures::Array{Float64, 1})

Create an instance with exposures given by two vectors of length 10 containing long and short exposures.
Exposures are assigned in sequence from vertex 1 BD to vertex 2520 BD.	

"""
type RwaJur3Exposure
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
	RwaJur3Exposure(date::Date, currency::AbstractString) = new(date, currency, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
	
	function RwaJur3Exposure(date::Date, currency::AbstractString, longExposures::Array{Float64, 1}, shortExposures::Array{Float64, 1})                                                     
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
	RWAJUR3Parameters
	
Holds BCB parameters to calculate price index coupon stantardized capital (RWA JUR3)

"""
type RwaJur3Parameters
	date::Date
	M3::Float64
end #type

"""
    getLongExposureArray(rExp::RwaJur3Exposure)

Return a vector with all long exposures in sequence, 
from vertex 1 BD to vertex 2520 BD.
    
"""
getLongExposureArray(rExp::RwaJur3Exposure) = [rExp.V1Long, rExp.V21Long, rExp.V42Long, rExp.V63Long, rExp.V126Long, rExp.V252Long, rExp.V504Long, rExp.V756Long, rExp.V1008Long, rExp.V1260Long, rExp.V2520Long] 

"""
    getShortExposureArray(rExp::RwaJur3Exposure)

Return a vector with all short exposures in sequence, 
from vertex 1 BD to vertex 2520 BD.
    
"""
getShortExposureArray(rExp::RwaJur3Exposure) = [rExp.V1Short, rExp.V21Short, rExp.V42Short, rExp.V63Short, rExp.V126Short, rExp.V252Short, rExp.V504Short, rExp.V756Short, rExp.V1008Short, rExp.V1260Short, rExp.V2520Short] 

# Casts
"""
    convert(::Type{RwaJur2Exposure}, x::RwaJur3Exposure)

Casts an RwaJur3Exposure into an RwaJur2Exposure.
"""
convert(::Type{RwaJur2Exposure}, x::RwaJur3Exposure) = RwaJur2Exposure(x.date, x.currency, getLongExposureArray(x), getShortExposureArray(x))

"""
    convert(::Type{RwaJur2Parameters}, x::RwaJur3Parameters)

Casts an RwaJur3Parameters into an RwaJur2Parameters.
"""
convert(::Type{RwaJur2Parameters}, x::RwaJur3Parameters) = RwaJur2Parameters(x.date, x.M3)	

"""
    getRwaJur3NetExposure(rExp::RwaJur3Exposure)

Return a vector containing RWA JUR3 weighted net exposures.
    
"""
getRwaJur3NetExposure(rExp::RwaJur3Exposure) = getRwaJur2NetExposure(convert(RwaJur2Exposure, rExp))

"""
    getRwaJur3VerticalGap(rExp::RwaJur3Exposure)

Return a vector containing RWA JUR3 vertical gaps.
    
"""
getRwaJur3VerticalGap(rExp::RwaJur3Exposure) = getRwaJur2VerticalGap(convert(RwaJur2Exposure, rExp))

"""
    getRwaJur3Zones(rExp::RwaJur3Exposure)

Return a matrix containing RWA JUR3 zone exposures.
Column 1 contains long exposures, column2 contains short exposures.
Zones are represented in each of the 3 rows.
    
"""
getRwaJur3Zones(rExp::RwaJur3Exposure) = getRwaJur2Zones(convert(RwaJur2Exposure, rExp))

"""
    getRwaJur3HorizontalGapWithinZones(rExp::RwaJur3Exposure)

Return a vector containing RWA JUR3 horizontal gap within zones.
    
"""
getRwaJur3HorizontalGapWithinZones(rExp::RwaJur3Exposure) = getRwaJur2HorizontalGapWithinZones(convert(RwaJur2Exposure, rExp))

"""
    getRwaJur3HorizontalGapBetweenZones(rExp::RwaJur3Exposure)

Return a vector containing RWA JUR3 horizontal gap between zones.
    
"""
getRwaJur3HorizontalGapBetweenZones(rExp::RwaJur3Exposure) = getRwaJur2HorizontalGapBetweenZones(convert(RwaJur2Exposure, rExp))

"""
	getPJur3(rExp::RwaJur3Exposure, par::RwaJur3Parameters)
	
Calculate PJUR3 using maturity ladder methodology.

"""
getPJur3(rExp::RwaJur3Exposure, par::RwaJur3Parameters) = getPJur2(convert(RwaJur2Exposure, rExp), convert(RwaJur2Parameters, par))

"""
	getRwaJur3(rExp::RwaJur3Exposure, par::RwaJur3Parameters)
	
Calculate risk-weighted assets for price index coupon exposures (RWA JUR3),
using maturity ladder methodology.
	
"""
getRwaJur3(rExp::RwaJur3Exposure, par::RwaJur3Parameters) = getRwaJur2(convert(RwaJur2Exposure, rExp), convert(RwaJur2Parameters, par))
