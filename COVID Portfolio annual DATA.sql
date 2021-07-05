----
	** SQL QUERIES FOR DATA EXPLOARATION
-----



SELECT *
FROM ProjectCovid..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM ProjectCovid..CovidVaccines
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProjectCovid..CovidDeaths
WHERE continent IS NOT NULL
ORDER  BY 1,2

-- Looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contracted COVID in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
FROM ProjectCovid..CovidDeaths
WHERE location LIKE '%INDIA%' AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at toatl cases vs total population
-- show what % of population got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS InfectedPercentage 
FROM ProjectCovid..CovidDeaths
WHERE location LIKE '%INDIA%' AND continent IS NOT NULL
ORDER BY 1,2


-- Looking at countries with highest infection rate comapred to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectedPercentage 
FROM ProjectCovid..CovidDeaths
--WHERE location LIKE '%INDIA%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY InfectedPercentage DESC


-- Showing the countries with highest death counts per population

SELECT location, MAX(cast(total_deaths as INT)) AS TotalDeathCount 
FROM ProjectCovid..CovidDeaths
--WHERE location LIKE '%INDIA%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- BREAKING THINGS W.R.T CONTINENT

SELECT continent, MAX(cast(total_deaths as INT)) AS TotalDeathCount 
FROM ProjectCovid..CovidDeaths
--WHERE location LIKE '%INDIA%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Showing the continent with highest death count per population

SELECT continent, MAX(cast(total_deaths as INT)) AS TotalDeathCount 
FROM ProjectCovid..CovidDeaths
--WHERE location LIKE '%INDIA%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT SUM(total_cases) AS TotalCases, SUM(cast(new_deaths AS int)) AS TotalDeaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage 
FROM ProjectCovid..CovidDeaths
--WHERE location LIKE '%INDIA%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- Looking at total population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations AS INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
FROM ProjectCovid..CovidDeaths AS dea
JOIN ProjectCovid..CovidVaccines AS vac
	ON dea.location=vac.location 
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3




-- USE CTE

With PopvsVac (continent, loaction, date, population, new_vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations AS INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM ProjectCovid..CovidDeaths AS dea
JOIN ProjectCovid..CovidVaccines AS vac
	ON dea.location=vac.location 
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac



--- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (
continent nvarchar(255),
loaction nvarchar(255),
date DATETIME,
population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations AS INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM ProjectCovid..CovidDeaths AS dea
JOIN ProjectCovid..CovidVaccines AS vac
	ON dea.location=vac.location 
	AND dea.date=vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--- Creating VIEW to store data for later visualization

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations AS INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM ProjectCovid..CovidDeaths AS dea
JOIN ProjectCovid..CovidVaccines AS vac
	ON dea.location=vac.location 
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * FROM PercentPopulationVaccinated

