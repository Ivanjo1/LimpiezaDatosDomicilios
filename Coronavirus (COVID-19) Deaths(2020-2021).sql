USE PortfolioProject_1;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent is not null

-- GENERAL NUMBERS BY DATE ACROSS THE WORLD

SELECT SUM(new_cases) AS NewCases, SUM(new_deaths) AS NewDeaths, 
SUM(CAST(new_deaths AS float))/SUM(CAST(new_cases AS float))*100 AS TotalDeathPercentage
FROM CovidDeaths
WHERE continent is not null
--GROUP BY date 
ORDER BY 1,2

-- TOTAL CASES VS TOTAL DEATHS

SELECT  location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS deathpercentage
FROM CovidDeaths
WHERE location LIKE '%states%' -- for example
 
-- TOTAL CASES VS POPULATION

SELECT  location, date, total_cases, population, (total_cases / population)*100 AS casespercentage
FROM CovidDeaths
WHERE location LIKE '%states%' -- for example

-- COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT  location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases / population))*100 AS InfectedPopulationRate
FROM CovidDeaths
WHERE continent is not null
GROUP BY population, location
ORDER BY InfectedPopulationRate DESC

-- COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

SELECT  location, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- BREAK THIS DOWN BY CONTINENT

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location 
ORDER BY TotalDeathCount DESC

-- TOTAL VACCINATIONS BY COUNTRY

SELECT  cd.date, cd.location, cd.continent, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS VaccinationsByCountry
FROM CovidDeaths cd
JOIN CovidVaccinations_1 cv
  ON cd.location = cv.location
  AND cd.date = cv.date
WHERE cd.continent is not null
ORDER BY cd.location

--USE CTE

WITH PopvsVac (continent, location,new_vaccinations, date, population, VaccinationsByCountry)
AS
(
SELECT  cd.date, cd.location, cd.continent, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS  VaccinationsByCountry
FROM CovidDeaths cd
JOIN CovidVaccinations_1 cv
  ON cd.location = cv.location
  AND cd.date = cv.date
WHERE cd.continent is not null

)
SELECT *
FROM PopvsVac

-- TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Date date,
Location nvarchar(50),
Continent nvarchar(50),
Population float,
New_Vaccinations int, 
VaccinationsByCountryNumber int
)

INSERT INTO  #PercentPopulationVaccinated
SELECT  cd.date, cd.location, cd.continent, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location) AS VaccinationsByCountryNumber
FROM CovidDeaths cd
JOIN CovidVaccinations_1 cv
  ON cd.location = cv.location
  AND cd.date = cv.date
WHERE cd.continent is not null


SELECT date, location, population, New_Vaccinations, (VaccinationsByCountryNumber/Population)*100 AS PercentageofthePopulation
FROM #PercentPopulationVaccinated

-- CREATING VIEW TO STORE DATA FOR  FUTURE VISUALIZATION

CREATE VIEW PercentPopulationVaccinated AS
SELECT  cd.date, cd.location, cd.continent, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location) AS VaccinationsByCountryNumber
FROM CovidDeaths cd
JOIN CovidVaccinations_1 cv
  ON cd.location = cv.location
  AND cd.date = cv.date
WHERE cd.continent is not null


