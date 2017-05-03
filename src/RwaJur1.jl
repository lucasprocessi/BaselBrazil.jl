# RwaJur1

export 	RwaJur1Exposure,
		getExposureArray,
		RwaJur1Parameters,
		getCovarianceMatrix,
		getVaR,
		getPJur1,
		getRwaJur1,
		VERTICES_RWAJUR1

"""
Standardized vertices for mapping BRL fixed rate exposures (RWAJUR1)	
"""	
const VERTICES_RWAJUR1 = [21, 42, 63, 126, 252, 504, 756, 1008, 1260, 2520]


"""
    RwaJur1Exposure

Holds exposures in BRL fixed rate.

# Fields
* `date::Date`: date of evaluation
* `VXX::Float64`: exposure to vertex XX, 
given by the sum of present value in BRL 
of all cashflows that matures in XX business days (BD).
 
# Constructors
    RwaJur1Exposure(date::Date)

Create an instance with all exposures equal to zero.
	
	RwaJur1Exposure(date::Date, exposures::Array{Float64, 1})

Create an instance with exposures given by a vector of length 10.
Exposures are assigned in sequence from vertex 21 BD to vertex 2520 BD.	

"""
type RwaJur1Exposure
	# Date of evaluation
	date::Date
	# Exposures in standard vertices: VXX, where XX is a maturity calculated in business days
	#V1::Float64
	V21::Float64
	V42::Float64
	V63::Float64
	V126::Float64
	V252::Float64
	V504::Float64
	V756::Float64
	V1008::Float64
	V1260::Float64
	V2520::Float64
	
	# Constructors
	RwaJur1Exposure(date::Date) = new(date, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
	
	function RwaJur1Exposure(date::Date, exposures::Array{Float64, 1})                                                     
		if size(exposures, 1) != 10
			error("exposures must have 10 values")
		end #if
		
		new(date,                                                                 
		    exposures[1], exposures[2], exposures[3], exposures[4],                      
			exposures[5], exposures[6], exposures[7], exposures[8],                      
			exposures[9], exposures[10])
	end #function
	
end #type

"""
    getExposureArray(rExp::RwaJur1Exposure)

Return a vector with all exposures in sequence, 
from vertex 21 BD to vertex 2520 BD.
    
"""
getExposureArray(rExp::RwaJur1Exposure) = [rExp.V21, rExp.V42, rExp.V63, rExp.V126, rExp.V252, rExp.V504, rExp.V756, rExp.V1008, rExp.V1260, rExp.V2520] 

"""
	RWAJUR1Parameters
	
Holds BCB parameters to calculate fixed BRL stantardized capital (RWA JUR1)

"""
type RwaJur1Parameters
	date::Date
	M1::Float64
	rho::Float64
	rhoStress::Float64
	K::Float64
	KStress::Float64
	sigmaShortTerm::Float64
	sigmaMediumTerm::Float64
	sigmaLongTerm::Float64
	sigmaShortTermStress::Float64
	sigmaMediumTermStress::Float64
	sigmaLongTermStress::Float64	
end #type

"""
	getCovarianceMatrix(par::RwaJur1Parameters, stress=false)

Return a variance-covariance matrix from RWA JUR1 parameters
supplied by BCB.

"""
function getCovarianceMatrix(par::RwaJur1Parameters, stress=false)
	
	if stress
		vecSigma = [ repmat([par.sigmaShortTermStress], 3); 
					repmat([par.sigmaMediumTermStress], 3); 
					repmat([par.sigmaLongTermStress], 4)]
	else
		vecSigma = [repmat([par.sigmaShortTerm], 3); 
					repmat([par.sigmaMediumTerm], 3); 
					repmat([par.sigmaLongTerm], 4)]
	end #if
	
	Rho = repmat([0.0], 10, 10)
	
	rho = stress? par.rhoStress : par.rho
	K = stress? par.KStress : par.K
	for i = 1:10
		for j = 1:10
			Rho[i, j] = rho + (1 - rho)^((max(VERTICES_RWAJUR1[i], VERTICES_RWAJUR1[j])/min(VERTICES_RWAJUR1[i], VERTICES_RWAJUR1[j]))^K)
		end #for j
	end #for i
	
	diagm(vecSigma) * Rho * diagm(vecSigma)
	
end #function


"""
	getVaR(rExp::RwaJur1Exposure, par::RwaJur1Parameters, stress=false)

Return portfolio Value-at-Risk (VaR) from its exposures and
from BCB RWA JUR1 parameters.
If `stress==true`, return stressed VaR (sVaR). 

"""
function getVaR(rExp::RwaJur1Exposure, par::RwaJur1Parameters, stress=false)
	
	Sigma = getCovarianceMatrix(par, stress)	
	X = getExposureArray(rExp) .* (VERTICES_RWAJUR1/252)
	
	2.33 * sqrt(X' * Sigma * X)[1] * sqrt(10)
	
end # function

"""
	getPJur1(rExp::RwaJur1Exposure, par::RwaJur1Parameters, VaRSMA60=0, sVaRSMA60=0)
	
Calculate PJUR1.

# Parameters
* `VaRSMA60=0`: VaR simple moving average, using last 60 business days
* `sVaRSMA60=0`: stressed VaR (sVaR) simple moving average, using last 60 business days
	
"""
function getPJur1(rExp::RwaJur1Exposure, par::RwaJur1Parameters, VaRSMA60=0, sVaRSMA60=0)
	
	VaR = getVaR(rExp, par, false)
	sVaR = getVaR(rExp, par, true)
	
	(max(par.M1 * VaRSMA60, VaR) + max(sVaRSMA60, sVaR))
	
end #function


"""
	getRwaJur1(rExp::RwaJur1Exposure, par::RwaJur1Parameters, VaRSMA60=0, sVaRSMA60=0)
	
Calculate risk-weighted assets for fixed BRL exposures (RWA JUR1).

# Parameters
* `VaRSMA60=0`: 
VaR simple moving average, using last 60 business days. 
See `getVaR()` for more info. 
* `sVaRSMA60=0`: 
stressed VaR (sVaR) simple moving average, using last 60 business days. 
See `getVaR()` for more info.
	
"""
function getRwaJur1(rExp::RwaJur1Exposure, par::RwaJur1Parameters, VaRSMA60=0, sVaRSMA60=0)
	
	(1/getF(par.date)) * getPJur1(rExp, par, VaRSMA60, sVaRSMA60)
	
end #function





