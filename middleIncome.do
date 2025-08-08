* (1) FIND THE DATA
*Final Growth rate 
*year
*GDP
*Net factor income from abroad 

*This version gets you two variables at once
wbopendata, indicator(NY.GNP.PCAP.CD; NY.GDP.PCAP.KD.ZG; NY.GDP.MKTP.KD.ZG) clear long
*GNI per capita (Atlas Methods), growth rate (per capita), growth rate 

**This command gets all the countries 
********************************************************************************

********************************************************************************
* (2) CREATE THE FUNCTION
*the growth rate 
**you can modify for whatever country you have
keep if countrycode == "MWI"
drop countrycode countryname region regionname adminregion adminregionname incomelevel incomelevelname lendingtype lendingtypename


*I've set this up so we can se the growth in 2030 but you can set the observations
*to the number of years you want
set obs 71
*replace year = 2024 in 65
**I commented this out because 2024 data is out
replace year = 2025 in 66
replace year = 2026 in 67
replace year = 2027 in 68
replace year = 2028 in 69
replace year = 2029 in 70
replace year = 2030 in 71

*Years until your target date (which in this case is 2030)
gen time = 2030 - year

*name variables for easy
ren ny_gnp_pcap_cd GNIper
ren ny_gdp_pcap_kd_zg growthRate_per
ren ny_gdp_mktp_kd_zg growthRate

*This is the GNI per capita threshold for a lower middle income country according to the WB
*https://blogs.worldbank.org/en/opendata/world-bank-country-classifications-by-income-level-for-2024-2025

*you may want to update it if its no longer 2025
gen want = 1146



***We need an average growth rate and average growth rate per capita for your country to put into a forecast
/*there are more sophisticated ways to do this but for now I will get the 
average growth rate for Malawi from 2019 to 2024. This is the time period of the 
current political regime*/

summarize growthRate if year >= 2019 & year <= 2024, meanonly
local mn_grRt = r(mean)
replace growthRate = `mn_grRt' if growthRate == .



*Apply the growth rate of GDP per capita to GNI because they are practically the same for Malawi 
sum growthRate_per if year >= 2014 & year <= 2024, meanonly
gen mn_grRtCap = r(mean)
replace GNIper = GNIper[_n-1]* (1+(mn_grRtCap/100)) if GNIper == .


*This wont work until you feed in the forecasts 
**((FV / PV) ^ (1/Years left)) - 1 
gen growth_need = (((want/GNIper)^(1/time))-1) * 100

********************************************************************************


********************************************************************************
* (3) USE THE VIEW COMMAND TO GET THE "growth_need" YOU NEED FOR EACH YEAR


********************************************************************************

*Profit



