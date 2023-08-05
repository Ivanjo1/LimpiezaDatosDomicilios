
-- CIFRAS RESPECTO A MUERTES POR COVID-19 (2020-2021)

USE PortfolioProject_1;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent is not null

--  NUMEROS GENERALES POR DIA EN EL MUNDO

SELECT SUM(new_cases) AS NewCases, SUM(new_deaths) AS NewDeaths, 
SUM(CAST(new_deaths AS float))/SUM(CAST(new_cases AS float))*100 AS TotalDeathPercentage
FROM CovidDeaths
WHERE continent is not null
--GROUP BY date 
ORDER BY 1,2

--  CASOS TOTALES VS MUERTES TOTALES

SELECT  location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS deathpercentage
FROM CovidDeaths
WHERE location LIKE '%states%' -- for example
 
--  CASOS TOTALES VS POBLACION

SELECT  location, date, total_cases, population, (total_cases / population)*100 AS casespercentage
FROM CovidDeaths
WHERE location LIKE '%states%' -- for example

--  PAISES CON LAS TASAS MAS ALTAS DE CONTAGIOS COMPARADO CON SU POBLACION

SELECT  location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases / population))*100 AS InfectedPopulationRate
FROM CovidDeaths
WHERE continent is not null
GROUP BY population, location
ORDER BY InfectedPopulationRate DESC

--  PAISES CON CIFRAS MAS ALTAS DE MUERTE DEACUERDO A LA POBLACION

SELECT  location, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- DIVIDIDO POR CONTINENTE

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location 
ORDER BY TotalDeathCount DESC

--  PERSONAS VACUNADAS POR PAIS

SELECT  cd.date, cd.location, cd.continent, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS VaccinationsByCountry
FROM CovidDeaths cd
JOIN CovidVaccinations_1 cv
  ON cd.location = cv.location
  AND cd.date = cv.date
WHERE cd.continent is not null
ORDER BY cd.location

-- USAR CTE 

WITH PopvsVac (date, location, continent, population, new_vaccinations, VaccinationsByCountry)
  AS
(  SELECT  cd.date, cd.location, cd.continent, cd.population, new_vaccinations, 
   SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS  VaccinationsByCountry
   FROM CovidDeaths cd
   JOIN CovidVaccinations_1 cv
   ON cd.location = cv.location
   AND cd.date = cv.date
   WHERE cd.continent is not null
  
)
SELECT *
FROM PopvsVac

-- TABLA DE PLANTILLA

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

--  CREAR VISTA PARA ALMACENAR DATOS PARA UNA FUTURA VISUALIZACION

CREATE VIEW PercentPopulationVaccinated 
AS
  SELECT  cd.date, cd.location, cd.continent, cd.population, cv.new_vaccinations,
  SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location) AS VaccinationsByCountryNumber
  FROM CovidDeaths cd
  JOIN CovidVaccinations_1 cv
  ON cd.location = cv.location
  AND cd.date = cv.date
  WHERE cd.continent is not null


