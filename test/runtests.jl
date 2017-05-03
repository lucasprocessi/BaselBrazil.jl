using BaselBrazil
using Base.Test

# TEST: RwaJur1
print("Testing RwaJur1...")

d = Date(2016, 01, 29)
ex = [ 23786530069.3118, 3722986267.80087, 85202367.863163, 
	  140167397.735608, -721668845.023739, 250782323.606156, 
	  -84552776.574041, 40298674.366432, -844588495.657341, -9682723.117057 ]

rExp = RwaJur1Exposure(d, ex)
par = RwaJur1Parameters(d, 1.9, 0.24, 0.16, 0.46, 0.76, 0.00076, 0.001669, 0.001479,  0.001132, 0.003497, 0.003714)
a = getExposureArray(rExp)
Sigma = getCovarianceMatrix(par)
SigmaStress = getCovarianceMatrix(par, true)
VaR = getVaR(rExp, par)
VaRStress = getVaR(rExp, par, true)
pj = getPJur1(rExp, par, 58774440.4205073, 161922460.712515)
rwa = getRwaJur1(rExp, par, 58774440.4205073, 161922460.712515)

@test abs(pj - 273593897.5) < 0.1
println("OK!")

# TEST RwaJur2
print("Testing RwaJur2...")

d = Date(2016, 01, 29)

par = RwaJur2Parameters(d, 3.7)
ex1 =  [50.402038000, 41841.676513000, 1383783.659905000, 7980979.159054000, 20524111.560721000, 26639000.579521000, 23023657.471863000, 95902873.803869000, 155773493.155968000, 143984256.342896000, 2735996.219730000] 
ex2 = zeros(11)

rExp = RwaJur2Exposure(d, "USD", ex1, ex2)

EL = getRwaJur2NetExposure(rExp)
DV = getRwaJur2VerticalGap(rExp)

@test abs(getPJur2(rExp, par) -  129058649.24) < 0.1 
println("OK!")

# TEST RwaJur3
print("Testing RwaJur3...")

d = Date(2016, 01, 20)

par = RwaJur3Parameters(d, 2.7)
ex1 =  [  7428402.60283,  	 29643805.83779,  	 294765.30570,  	 24334011.11047,  	 702959638.81889,  	 312021889.17586,  	 218625880.11077,  	 278731778.57934,  	 116153565.32365,  	 376704666.24341,  	 589764051.41524] 
ex2 = [ 2021520.97299,  	 106395.84068,  	 0.00000,  	 0.00000,  	 0.00000,  	 0.00000,  	 0.00000,  	 0.00000,  	 0.00000,  	 0.00000,  	 0.00000]

rExp = RwaJur3Exposure(d, "IPCA", ex1, ex2)

EL = getRwaJur3NetExposure(rExp)
DV = getRwaJur3VerticalGap(rExp)

@test abs(getPJur3(rExp, par) -    522746060.85) < 0.1 
println("OK!")

# TEST RwaJur4
print("Testing RwaJur4...")

d = Date(2016, 01, 20)

par = RwaJur4Parameters(d, 2.7)
ex1 =  [  7428402.60283,  	 29643805.83779,  	 294765.30570,  	 24334011.11047,  	 702959638.81889,  	 312021889.17586,  	 218625880.11077,  	 278731778.57934,  	 116153565.32365,  	 376704666.24341,  	 589764051.41524] 
ex2 = [ 2021520.97299,  	 106395.84068,  	 0.00000,  	 0.00000,  	 0.00000,  	 0.00000,  	 0.00000,  	 0.00000,  	 0.00000,  	 0.00000,  	 0.00000]

rExp = RwaJur4Exposure(d, "TR", ex1, ex2)

EL = getRwaJur4NetExposure(rExp)
DV = getRwaJur4VerticalGap(rExp)

@test abs(getPJur4(rExp, par) -    522746060.85) < 0.1
println("OK!")


# TEST RwaCam
print("Testing RwaCam...")

d = Date(2016, 01, 29)
rExp = RwaCamExposure(
	d,
	[
		RwaCamSingleExposure("USD",  10816105473.48), 
		RwaCamSingleExposure("EUR",   -328435536.56), 
		RwaCamSingleExposure("JPY",   -356301571.46), 
		RwaCamSingleExposure("CHF",    -22924826.85), 
		RwaCamSingleExposure("GBP",     76363607.62)
	]
)

RC =  104669479340.35 
p = getPCam(rExp, RC)

@test abs(p - 8544136400.49) < 0.1
println("OK!")

# Test linearXMapping
print("Testing LinearXMapping...")
exposures = [100.0]
standardizedVertices = [21, 42, 63]

maturities = [30]
m = linearXMapping(maturities, exposures, standardizedVertices)
@test all(abs(m .- [100*(42-30)/(42-21), 100*(30-21)/(42-21), 0]) .< 1e-5)

maturities = [10]
m = linearXMapping(maturities, exposures, standardizedVertices)
@test all(abs(m .- [100*(10/21), 0, 0]) .< 1e-5)

maturities = [70]
m = linearXMapping(maturities, exposures, standardizedVertices)
@test all(abs(m .- [100*(70/63), 0, 0]) .< 1e-5)

println("OK!")
