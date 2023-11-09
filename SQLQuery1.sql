USE PortfolioProject
GO

--SELECT*
--FROM PortfolioProject.dbo.CovidDeaths$
--Order by 3,4

SELECT location, date, total_cases,new_cases,total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not Null 
ORDER BY 1,2



-- Looking at Total Cases vs Total Deaths 
-- Shows likelyhood of dying if you contract covid in your country

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE location like '%states%'  and  continent is not Null 
ORDER BY 1,2



-- Looking at Total Cases vs Population 
-- Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as CasesPercent
FROM PortfolioProject.dbo.CovidDeaths$
WHERE location like '%states%' and  continent is not Null 
ORDER BY 1,2



-- Looking at countries with highest infection rate compared to population 

SELECT location, population, MAX (total_cases) as HighestInfectionCount, MAX( (total_cases/population))*100 as CasesPercent
FROM PortfolioProject.dbo.CovidDeaths$
--WHERE location like '%states%'
WHERE  continent is not Null 
GROUP BY location, population
ORDER BY CasesPercent DESC



-- Showing Countries with the Highest Death count per Population 

SELECT location, MAX (total_deaths) as HighestDeathCount, MAX( (total_deaths/population))*100 as HighestDeathPercent
FROM PortfolioProject.dbo.CovidDeaths$
--WHERE location like '%states%'
--ORDER BY 
WHERE  continent is not Null 
GROUP BY location, population
ORDER BY HighestDeathPercent DESC

-- BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX (CAST (total_deaths as int)) as HighestDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
--WHERE location like '%states%'
--ORDER BY 
Where continent is not Null 
GROUP BY continent
ORDER BY HighestDeathCount DESC


-- Showing the continents with the highest death count per population 

SELECT continent, MAX( (total_deaths/population))*100 as HighestDeathPercent
--MAX (total_deaths) as HighestDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
--WHERE location like '%states%'
--ORDER BY 
WHERE  continent is not Null 
GROUP BY continent, population
ORDER BY HighestDeathPercent DESC


--GLOBAL NUMBERS

---- Break down by date
SELECT date, SUM (new_cases) as TotalCases, SUM(CAST (new_deaths as int)) as TotalDeaths, SUM(CAST (new_deaths as int))/ SUM (new_cases)*100 AS DeathPercent
FROM PortfolioProject.dbo.CovidDeaths$
--WHERE location like '%states%'  and  
WHERE continent is not Null 
Group BY date
ORDER BY 1,2



---- Overall Globally 
SELECT  SUM (new_cases) as TotalCases, SUM(CAST (new_deaths as int)) as TotalDeaths, SUM(CAST (new_deaths as int))/ SUM (new_cases)*100 AS DeathPercent
FROM PortfolioProject.dbo.CovidDeaths$
--WHERE location like '%states%'  and  
WHERE continent is not Null 
--Group BY date
ORDER BY 1,2



-- Looking at Total Population VS Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT (int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ as dea
JOIN PortfolioProject..CovidVaccinations$ as vac
ON dea.date = vac.date
AND dea.location = vac.location
WHERE dea.continent is not null
ORDER BY 2,3


-- USE CTE


WITH PopvsVac AS 
  ( 
   SELECT dea.continent AS continent, dea.location AS location, dea.date AS date, dea.population AS population, vac.new_vaccinations as NewVac, 
SUM(CONVERT (int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ as dea
JOIN PortfolioProject..CovidVaccinations$ as vac
ON dea.date = vac.date
AND dea.location = vac.location
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT*
FROM
    PopvsVac
--GROUP BY PopvsVac.location

-- USE CTE 2

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
   AS
  (
   SELECT dea.continent, dea.location, dea.date , dea.population , vac.new_vaccinations , 
SUM(CONVERT (int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ as dea
JOIN PortfolioProject..CovidVaccinations$ as vac
ON dea.date = vac.date
AND dea.location = vac.location
WHERE dea.continent is not null
--ORDER BY 2,3
   )
SELECT*, (RollingPeopleVaccinated/population)*100
FROM PopvsVac 


-- TEMP TABLE

DROP TABLE if exists  #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
 (
  continent nvarchar (255),
             location nvarchar (255),
			 Date datetime,
			 population numeric,
			 New_vaccination numeric, 
			  RollingPeopleVaccinated numeric
 )
INSERT INTO #PercentPopulationVaccinated
  SELECT dea.continent, dea.location, dea.date , dea.population , vac.new_vaccinations , 
SUM(CONVERT (int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ as dea
JOIN PortfolioProject..CovidVaccinations$ as vac
ON dea.date = vac.date
AND dea.location = vac.location
WHERE dea.continent is not null

SELECT*, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Create View to store data for later visualization 

CREATE VIEW PercentPopulationVaccinated AS 

SELECT dea.continent, dea.location, dea.date , dea.population , vac.new_vaccinations , 
SUM(CONVERT (int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ as dea
JOIN PortfolioProject..CovidVaccinations$ as vac
ON dea.date = vac.date
AND dea.location = vac.location
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT*
FROM PercentPopulationVaccinated