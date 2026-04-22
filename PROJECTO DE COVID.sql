SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..MuertesCovid$
ORDER BY 1,2

-- Looking at the total cases vs Total Deaths in Colombia

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject..MuertesCovid$
WHERE location like 'Colombia' AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at the total cases vs population
-- Shows what percentage of population got covid in Colombia
SELECT location, date, population, total_cases, (total_cases/population)*100 AS Infected_percentage
FROM PortfolioProject..MuertesCovid$
WHERE location like 'Colombia' AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS Highest_infection_count_percountry, MAX((total_cases/population))*100 AS Infected_percentage
FROM PortfolioProject..MuertesCovid$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Infected_percentage desc

-- Showing countries with highest death count per population

SELECT location, MAX(cast(total_deaths AS INT)) AS Total_death_count
FROM PortfolioProject..MuertesCovid$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_death_count DESC

-- Showing continents with highest death count per population

SELECT continent, MAX(cast(total_deaths AS INT)) AS Total_death_count
FROM PortfolioProject..MuertesCovid$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_death_count DESC

-- Global numbers

SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 as Death_percentage
FROM PortfolioProject..MuertesCovid$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Looking at total population vs vaccinations

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(SELECT mue.continent, 
mue.location, 
mue.date, 
mue.population, 
vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY mue.location ORDER BY mue.location, mue.date) as RollingPeopleVaccinated
from PortfolioProject..MuertesCovid$ mue
JOIN PortfolioProject..VacunasCovid$ vac
	ON mue.location = vac.location
	and mue.date = vac.date
WHERE mue.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS Percentage_people_vaccinated
FROM PopVsVac

-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT mue.continent, 
mue.location, 
mue.date, 
mue.population, 
vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY mue.location ORDER BY mue.location, mue.date) as RollingPeopleVaccinated
from PortfolioProject..MuertesCovid$ mue
JOIN PortfolioProject..VacunasCovid$ vac
	ON mue.location = vac.location
	and mue.date = vac.date
WHERE mue.continent IS NOT NULL