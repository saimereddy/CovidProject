SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3,4

--SELECT Location, Date, total_cases, new_cases, total_deaths, population
--FROM PortfolioProject..CovidDeaths
--ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID-19 in your country of choice.
SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%united states%'
and continent is not null
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Displays the percentage of population that contracts COVID-19
SELECT Location, Date, population, total_cases,  (total_cases/population)*100 as Infection_Rate
FROM PortfolioProject..CovidDeaths
WHERE Location like '%united states%'
and continent is not null
ORDER BY 1,2

-- Finding Countries with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(total_cases) as Highest_Infection_Count,  MAX((total_cases/Population))*100 as Infection_Rate
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%united states%'
WHERE continent is not null
GROUP BY Location, Population
ORDER BY Infection_Rate DESC


-- Showing Countries with Highest Death Count per Population
SELECT Location, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY Total_Death_Count DESC


-- DEATH COUNT DOWN BY CONTINENT
SELECT continent, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent 
ORDER BY Total_Death_Count DESC


-- GLOBAL NUMBERS THROUGH THE PANDEMIC AND ONWARDS
SELECT Date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Rate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Date
ORDER BY 1,2

-- TOTAL GLOBAL COVID-19 STATS
SELECT SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Rate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
-- GROUP BY Date
ORDER BY 1,2


-- JOINING BOTH COVID DEATH AND COVID VACCINATION TABLES
-- LOOKING AT TOTAL POPULATION VS VACCINATIONS SINCE START OF THE PANDEMIC
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.location Order by dea.location, dea.Date) as People_Vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
--AND vac.new_vaccinations is not null
ORDER BY 2,3


-- LOOKING AT TOTAL POPULATION VS VACCINATIONS AFTER VACCINES WERE RELEASED
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.location Order by dea.location, dea.Date) as People_Vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
AND vac.new_vaccinations is not null
ORDER BY 2,3


-- USING A CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, People_Vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.location Order by dea.location, dea.Date) as People_Vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
--AND vac.new_vaccinations is not null
--ORDER BY 2,3
)
SELECT *, (People_Vaccinated/Population) *100 as Vaccination_Rate
FROM PopvsVac


-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent varchar(255), 
Location varchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
People_Vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.location Order by dea.location, dea.Date) as People_Vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
--AND vac.new_vaccinations is not null
--ORDER BY 2,3

SELECT *, (People_Vaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- CREATING VIEW TO STORE DATA FOR VISUALIZATION
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.location Order by dea.location, dea.Date) as People_Vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
--AND vac.new_vaccinations is not null
--ORDER BY 2,3
