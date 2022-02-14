--*****************************(SELECT ...FROM)**********************************
-- Initial check on tables, columns 
SELECT *
FROM COVID..CovidDeath

SELECT *
FROM COVID..CovidVaccinations

--******************************(ORDER BY)*********************************
-- Total cases, total deaths by date and location 
SELECT location, population, date, total_cases, total_deaths
FROM COVID..CovidDeath
ORDER BY 1,2

--********************************(WHERE/LIKE )******************************

-- Total Cases Vs Total Deaths for a specific location 
SELECT location,date,total_cases, total_deaths, (total_deaths *1.0/total_cases)*100 as Death_Percentage
FROM COVID..CovidDeath
WHERE location like '%Australia%'
ORDER BY 1,2

-- Total Cases Vs Population - specific location
SELECT location, population, date,total_cases, (total_cases *1.0/population)*100 as Infection_Percentage
FROM COVID..CovidDeath
WHERE location like '%Australia%'
ORDER BY 1,2

-- Total Deaths Vs Population - specific location
SELECT continent, location, population, date,total_deaths, (total_deaths *1.0/population)*100 as Death_Percentage
FROM COVID..CovidDeath
WHERE location like '%States%'
ORDER BY 1,2
--****************************** (AGGREGATE functions)*********************************
-- Total cases and total deaths
SELECT SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths, SUM(new_deaths) *1.0/SUM(new_cases)*100 as Death_Percentage
FROM COVID..CovidDeath

--******************************** (GROUP BY)*******************************
-- Total cases and total deaths by date
SELECT date, SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths
FROM COVID..CovidDeath
GROUP BY date
ORDER BY date ASC

-- Continents with highest death percentage
SELECT continent, SUM(total_deaths) as DeathCount, (SUM(total_deaths) *1.0/SUM(population))*100 as Death_Percentage 
FROM COVID..CovidDeath
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Death_Percentage DESC

-- Countries with highest death percentage
SELECT location, population, MAX(total_deaths) as DeathCount, MAX((total_deaths *1.0/population))*100 as Death_Percentage 
FROM COVID..CovidDeath
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Death_Percentage DESC

-- Countries with highest infection rate/population
SELECT location, population, MAX(total_cases) as InfectionCount, MAX((total_cases *1.0/population))*100 as Infection_Percentage 
FROM COVID..CovidDeath
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Infection_Percentage DESC

--*******************************(JOIN..ON)********************************
---- Details from Covid Deaths and Covid vaccinations tables 
SELECT *
FROM COVID..CovidDeath CD
JOIN COVID..CovidVaccinations CV
ON CD.location =CV.location AND CD.date=CV.date

---- Covid vaccination percentage by continent
SELECT CD.continent, MAX(CD.population) as Total_Population, MAX(CV.people_fully_vaccinated) as Total_Vaccinations, MAX(CAST(CV.people_fully_vaccinated as float))/MAX(CD.population)*100 as Vaccination_Percentage
FROM COVID..CovidDeath CD
JOIN COVID..CovidVaccinations CV
ON CD.location =CV.location AND CD.date=CV.date
WHERE CD.continent IS NOT NULL 
GROUP BY CD.continent
ORDER BY CD.continent

---- Covid vaccination percentage by country
SELECT CD.location, MAX(CD.population) as Total_Population, MAX(CV.people_fully_vaccinated) as Total_Vaccinations, MAX(CAST(CV.people_fully_vaccinated as float))/MAX(CD.population)*100 as Vaccination_Percentage
FROM COVID..CovidDeath CD
JOIN COVID..CovidVaccinations CV
ON CD.location =CV.location AND CD.date=CV.date
WHERE CD.continent IS NOT NULL 
GROUP BY CD.location
ORDER BY Vaccination_Percentage DESC

--***********************************(COMMON TABLE EXPRESSIONS)****************************
--Total Population, number of fully vaccinated people, Vaccination Percentage for each location 

With VaccPercent (location, population, people_fully_vaccinated,Vaccination_Percentage)
as
(
SELECT CD.location, MAX(CD.population) as Total_Population, MAX(CV.people_fully_vaccinated) as Total_Vaccinations, MAX(CAST(CV.people_fully_vaccinated as float))/MAX(CD.population)*100 as Vaccination_Percentage
FROM COVID..CovidDeath CD
JOIN COVID..CovidVaccinations CV
ON CD.location =CV.location AND CD.date=CV.date
WHERE CD.continent IS NOT NULL 
GROUP BY CD.location)
SELECT *
FROM VaccPercent
WHERE Vaccination_Percentage IS NOT NULL
ORDER BY Vaccination_Percentage

--***********************************(TEMP TABLE )*******************************
-- Vaccination Percentage by location 
DROP TABLE IF EXISTS #VaccinationPercentage
CREATE TABLE #VaccinationPercentage
(
continent varchar(250),
location varchar(250),
population bigint,
Vaccination_Percentage float,
)
INSERT INTO #VaccinationPercentage
SELECT CD.location, MAX(CD.population) as Total_Population, MAX(CV.people_fully_vaccinated) as Total_Vaccinations, MAX(CAST(CV.people_fully_vaccinated as float))/MAX(CD.population)*100 as Vaccination_Percentage
FROM COVID..CovidDeath CD
JOIN COVID..CovidVaccinations CV
ON CD.location =CV.location AND CD.date=CV.date
WHERE CD.continent IS NOT NULL
GROUP BY CD.location
SELECT *
FROM #VaccinationPercentage
ORDER BY Vaccination_Percentage

--******************************(VIEWS)************************************
--View for data to be reused later

CREATE VIEW VaccinationPercentage AS
SELECT CD.location, MAX(CD.population) as Total_Population, MAX(CV.people_fully_vaccinated) as Total_Vaccinations, MAX(CAST(CV.people_fully_vaccinated as float))/MAX(CD.population)*100 as Vaccination_Percentage
FROM COVID..CovidDeath CD
JOIN COVID..CovidVaccinations CV
ON CD.location =CV.location AND CD.date=CV.date
WHERE CD.continent IS NOT NULL
GROUP BY CD.location

SELECT *
FROM VaccinationPercentage


