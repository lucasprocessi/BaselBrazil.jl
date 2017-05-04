# RwaCam

export RwaCamSingleExposure,
		RwaCamExposure,
		getPCam,
		getRwaCam,
		getLongTotalExposures, getShortTotalExposures,
		getLongDomesticExposures, getShortDomesticExposures,
		getLongForeignExposures, getShortForeignExposures,
		getPCamF

		
"""
	RwaCamSingleExposure

Holds exposures to a single foreign currency

# Fields
* `currency::AbstractString`: currency identifier
* `longTotal::Float64` and `longTotal::Float64`: long and short exposures to `currency`, measured in present value in BRL. 
* `longDomestic::Float64` and `shortDomestic::Float64`: long and short exposures to `currency` liquidated in domestic market. 
* `longForeign::Float64` and `shortForeign::Float64`: long and short exposures to `currency` liquidated in foreign market.

# Obs
Note that domestic and foreign exposure may not sum total exposure because of operations with foreign intragroup counterparties. 

"""
type RwaCamSingleExposure
	currency::AbstractString
	longTotal::Float64
	shortTotal::Float64
	longDomestic::Float64
	shortDomestic::Float64
	longForeign::Float64
	shortForeign::Float64
	
	RwaCamSingleExposure(currency::AbstractString, exposure::Float64) = new(currency, max(exposure, 0.0), max(-exposure, 0.0), 0.0, 0.0, 0.0, 0.0)
	function RwaCamSingleExposure(currency::AbstractString, longExposure::Float64, shortExposure::Float64)
		if longExposure < 0.0
			error("long exposure must be positive")
		end #if
		if shortExposure < 0.0
			error("short exposure must be positive")
		end #if
		new(currency, longExposure, shortExposure, 0.0, 0.0, 0.0, 0.0)
	end #function
	
end #type		
		
"""
    RwaCamExposure

Holds exposure to a group of foreign currencies in a `date::Date`. 
Each foreign currency exposure is represented in a `RwaCamSingleExposure` instance contained in `exposures::Array{RwaCamSingleExposure, 1}`.

"""		
type RwaCamExposure
	date::Date
	exposures::Array{RwaCamSingleExposure, 1}
	
	RwaCamExposure(date::Date, exposures::Array{RwaCamSingleExposure, 1}) = new(date, exposures)
	
	function RwaCamExposure(date::Date, expLong::Array{Float64, 1}, expShort::Array{Float64, 1})
		
		if any(expLong .< 0.0)
			error("all long exposures must be positive")
		end #if
		
		if any(expShort .< 0.0)
			error("all short exposures must be positive")
		end #if
		
		if size(expLong, 1) != size(expShort, 1)
			error("long and short exposures must have equal length")
		end #if
		
		N = size(expLong, 1)
		
		expArray = Array{RwaCamSingleExposure, 1}(N)
		
		for i in 1:N
			expArray[i] = RwaCamSingleExposure("CUR", expLong[i], expShort[i])
		end #for
			
		new(date, expArray)
		
	end #function
	
	function RwaCamExposure(date::Date, expNet::Array{Float64, 1})
		if any(expLong .< 0.0)
			error("all long exposures must be positive")
		end #if
		
		if any(expShort .< 0.0)
			error("all short exposures must be positive")
		end #if
		
		N = size(expNet, 1)
		
		expArray = Array{RwaCamSingleExposure, 1}(N)
		
		for i in 1:N
			expArray[i] = RwaCamSingleExposure("CUR", max(expNet[i], 0.0), max(-expNet[i], 0.0))
		end #for
			
		new(date, expArray)
		
	end #function
	
end #type

"""
    getLongTotalExposures(rExp::RwaCamExposure) 

Return an array with total long exposures for all `RwaCamSingleExposure` in `rExp::RwaCamExposure`.
"""
getLongTotalExposures(rExp::RwaCamExposure)     = map(x -> x.longTotal,    rExp.exposures)
"""
    getShortTotalExposures(rExp::RwaCamExposure) 

Return an array with total short exposures for all `RwaCamSingleExposure` in `rExp::RwaCamExposure`.
"""
getShortTotalExposures(rExp::RwaCamExposure)    = map(x -> x.shortTotal,   rExp.exposures)
"""
    getLongDomesticExposures(rExp::RwaCamExposure) 

Return an array with long domestic exposures for all `RwaCamSingleExposure` in `rExp::RwaCamExposure`.
"""
getLongDomesticExposures(rExp::RwaCamExposure)  = map(x -> x.longDomestic,  rExp.exposures)
"""
    getShortDomesticExposures(rExp::RwaCamExposure) 

Return an array with short domestic exposures for all `RwaCamSingleExposure` in `rExp::RwaCamExposure`.
"""
getShortDomesticExposures(rExp::RwaCamExposure) = map(x -> x.shortDomestic, rExp.exposures)
"""
    getLongForeignExposures(rExp::RwaCamExposure) 

Return an array with long foreign exposures for all `RwaCamSingleExposure` in `rExp::RwaCamExposure`.
"""
getLongForeignExposures(rExp::RwaCamExposure)   = map(x -> x.longForeign,   rExp.exposures)
"""
    getShortForeignExposures(rExp::RwaCamExposure) 

Return an array with short foreign exposures for all `RwaCamSingleExposure` in `rExp::RwaCamExposure`.
"""
getShortForeignExposures(rExp::RwaCamExposure)  = map(x -> x.shortForeign,  rExp.exposures)


"""
	getPCam(rExp::RwaCamExposure, RegulatoryCapital::Float64)
	
Calculate PCAM.

# Parameters
* `RegulatoryCapital::Float64`: regulatory capital (Patrimonio de Referencia - PR)
	
"""
function getPCam(rExp::RwaCamExposure, RegulatoryCapital::Float64)
	
	Long = getLongTotalExposures(rExp)
	Short = getShortTotalExposures(rExp)
	EL = Long - Short
	
	EXP1 = abs(sum(EL))
	
	ExC = EL[EL .>= 0]
	ExV = EL[EL .< 0]
	EXP2 = min(sum(ExC), abs(sum(ExV)))
	
	NetDomestic = getLongDomesticExposures(rExp) - getShortDomesticExposures(rExp)
	NetForeign = getLongForeignExposures(rExp) - getShortForeignExposures(rExp)
	
	EXP3 = min(sum(abs(NetDomestic)), sum(abs(NetForeign)))	
	
	H = 0.7
	
	if(sum(NetDomestic) * sum(NetForeign) < 0)
		G = 1
	else
		G = 0
	end #if
		
	EXP = EXP1 + H * EXP2 + G * EXP3
	
	ratio = EXP/RegulatoryCapital
	
	FDoublePrime = getPCamF(ratio, rExp.date)
	
	FDoublePrime * EXP
	
end #function


"""
	getPCamF(expRatio::Float64, date::Date)
	
Calculate PCAM.

# Parameters
* `expRatio::Float64`: ratio of EXP/regulatory capital(PR)
* `date:Date`: date of evaluation
	
"""
function getPCamF(expRatio::Float64, date::Date)
	if date <= Date(2011, 12, 31)
		return(1.0)
	end # if
	
	if expRatio <= 0.05
		F = 0.4
	elseif expRatio <= 0.10
		F = 0.6
	elseif expRatio <= 0.15
		F = 0.8
	else
		F = 1.0
	end #if
	
	return(F)
end #function


"""
	getRwaCam(rExp::RwaCamExposure, RegulatoryCapital::Float64)
	
Calculate risk-weighted assets for foreign currency exposures (RWA CAM).

# Parameters
* `RegulatoryCapital::Float64`: regulatory capital (Patrimonio de Referencia - PR)
	
"""
function getRwaCam(rExp::RwaCamExposure, RegulatoryCapital::Float64)
	(1/(getF(rExp.date)))* getPCam(rExp, RegulatoryCapital)
end #function

