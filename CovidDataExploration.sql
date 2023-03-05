-- COVID DEATHS TABLE

--Explore Data
SELECT * FROM DataExplorationProject..CovidDeaths
ORDER BY 3,4

--We observe that in column continent there is NULL values because as a location it takes the whole continent and we only want countries 
SELECT * FROM DataExplorationProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4

--Select Data that we will explore
SELECT Location,date,total_cases,new_cases,total_deaths,population FROM DataExplorationProject..CovidDeaths
ORDER BY Location


--Find a daily DeathPercentage of every country
--We use ROUND() function to keep to round number to 3 decimal places 
SELECT Location,date,total_cases,new_cases,total_deaths,population,ROUND((total_deaths/total_cases)*100,3) as DeathPercentage 
FROM DataExplorationProject..CovidDeaths

--Find the possibility of dying if you get sick in a country(DeathPercentage)
SELECT Location,population,max(total_cases) as Total_Cases,max(total_deaths) as Total_Deaths,ROUND((max(total_deaths)/max(total_cases))*100,3) as DeathPercentage
FROM DataExplorationProject..CovidDeaths
GROUP BY Location,population
ORDER BY Location

--Find what percentage of population got Covid(order by Country name) 
SELECT Location,population,max(total_cases) as Total_Cases,ROUND((max(total_cases)/population)*100,3) as InfectionRate
FROM DataExplorationProject..CovidDeaths
GROUP BY Location,population
ORDER BY Location

--Find countries with highest infection rate
SELECT Location,population,max(total_cases) as Total_Cases,ROUND(max((total_cases/population)*100),3) as InfectionRate
FROM DataExplorationProject..CovidDeaths
GROUP BY Location,population
ORDER BY InfectionRate DESC

--Find Countries with Highest Death Count  per Population
--Because total_deaths is stored as nvarchar there is a string compare so we cast it to int
SELECT Location,population,max(cast(total_deaths as int)) as Total_Deaths
FROM DataExplorationProject..CovidDeaths
WHERE continent is not NULL
GROUP BY Location,population
ORDER BY Total_Deaths DESC


--Create a Procedure which find DeathPercentage of the country which is passed as a parameter
--Once Procedure is created we cannot run again this query and recreate it
CREATE PROCEDURE DeathPerc
@Location nvarchar(100)
AS SELECT Location,population,max(total_cases) as Total_Cases,max(total_deaths) as Total_Deaths,ROUND((max(total_deaths)/max(total_cases))*100,3) as DeathPercentage
FROM DataExplorationProject..CovidDeaths
WHERE Location = @Location
GROUP BY Location,population


--Example of Greece's DeathPercentage
EXEC DeathPerc "Greece"
--Example of China's DeathPercentage
EXEC DeathPerc "Italy"
--etc...



-- EXPLORE DATA BY CONTINENT

--Continents with most total deaths
SELECT continent,max(cast(total_deaths as int)) as Total_Deaths
FROM DataExplorationProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY Total_Deaths DESC


-- GLOBAL STATS
Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM DataExplorationProject..CovidDeaths
WHERE continent is not null 
ORDER BY 1,2

-- In case we want to check the daily course of pandemic
Select date,SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM DataExplorationProject..CovidDeaths
WHERE continent is not null 
GROUP BY date
ORDER BY 1,2





--COVID VACCINATIONS TABLE

--Explore Data
SELECT * FROM DataExplorationProject..CovidVaccinations


--Progress of Vaccinations
SELECT dea.continent,dea.location ,dea.date,dea.population,vac.new_vaccinations FROM DataExplorationProject..CovidDeaths dea
JOIN DataExplorationProject..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 1,2,3

--Check Percentage of Population that has received at least one Covid Vaccine in each country
--We can use column total_vaccinations but we make it by our own

-- USE CTE
WITH PercVac(continent, location, date, population, new_vaccinations, Total_Vaccinations)
as (SELECT dea.continent,dea.location ,dea.date,dea.population,vac.new_vaccinations,SUM(convert(int,vac.new_vaccinations))  OVER (Partition By dea.location ORDER By dea.location,dea.date) as Total_Vaccinations
	FROM DataExplorationProject..CovidDeaths dea
	JOIN DataExplorationProject..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
	WHERE dea.continent is not NULL
)

SELECT *,ROUND((Total_Vaccinations/population)*100,4) as VaccinatedPercentage FROM PercVac


--USE TEMP TABLE

DROP TABLE if exists #PercPeopleVac
CREATE TABLE #PercPeopleVac
(	
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	Total_Vaccinations numeric
)

INSERT INTO #PercPeopleVac
SELECT dea.continent,dea.location ,dea.date,dea.population,vac.new_vaccinations,SUM(convert(int,vac.new_vaccinations))  OVER (Partition By dea.location ORDER By dea.location,dea.date) as Total_Vaccinations
	FROM DataExplorationProject..CovidDeaths dea
	JOIN DataExplorationProject..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
	WHERE dea.continent is not NULL


SELECT *,ROUND((Total_Vaccinations/population)*100,4) as VaccinatedPercentage FROM #PercPeopleVac




-- Create View of our findings to store them for later visualization
CREATE VIEW TotalDeathsByContinent as
	SELECT continent,max(cast(total_deaths as int)) as Total_Deaths
	FROM DataExplorationProject..CovidDeaths
	WHERE continent is not NULL
	GROUP BY continent
	--ORDER BY Total_Deaths DESC