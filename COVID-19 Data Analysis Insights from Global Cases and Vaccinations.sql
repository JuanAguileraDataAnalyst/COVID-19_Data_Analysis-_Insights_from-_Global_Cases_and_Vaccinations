 /*
 Title:
 COVID-19 Data Analysis: Insights from Global Cases and Vaccinations

 Description:
 Explore the dynamics of the COVID-19 pandemic through comprehensive data analysis. 
 This project delves into two critical datasets — COVID-19 deaths and vaccinations — sourced from real-world data. 
 Utilizing Microsoft SQL Server Management Studio, I investigate patterns across continents and countries, examining total cases, deaths, 
 vaccination rates, and population impacts. From understanding infection rates to assessing vaccination effectiveness, this analysis provides 
 valuable insights into the pandemic's progression and global response efforts.
 */

-- Select all records from CovidDeaths table
SELECT *
FROM PortfolioProject.dbo.CovidDeaths;

-- Select all records from CovidVaccinations table
SELECT *
FROM PortfolioProject.dbo.CovidVaccinations;

-- Select records from CovidDeaths where continent is not null, ordered by column 3 and 4
SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4;

-- Select records from CovidVaccinations, ordered by column 3 and 4
SELECT *
FROM PortfolioProject.dbo.CovidVaccinations
ORDER BY 3, 4;

-- Select specific columns from CovidDeaths where continent is not null, ordered by location and date
SELECT location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Select specific columns from CovidDeaths for Canada where continent is not null, ordered by location and date
SELECT location, Date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Canada'
AND continent IS NOT NULL
ORDER BY 1, 2;

-- Select specific columns from CovidDeaths for Canada where continent is not null, ordered by location and date
SELECT location, Date, population, total_cases, (total_cases / population) * 100 AS PercentagePopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Canada'
AND continent IS NOT NULL
ORDER BY 1, 2;

-- Select location, population, maximum total cases, and percentage of population infected, grouped by location and population, ordered by percentage of population infected descending
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- Select location and maximum total death count, grouped by location, ordered by total death count descending
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Select continent and maximum total death count, grouped by continent, ordered by total death count descending
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Select sum of new cases as total cases, sum of new deaths as total deaths, and death percentage for all records where continent is not null, ordered by total cases and total deaths
SELECT SUM(New_cases) AS total_cases, SUM(CAST(New_deaths AS int)) AS TotalDeaths, SUM(CAST(New_deaths AS int)) / SUM(new_Cases) * 100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Select continent, location, date, population, new vaccinations, rolling people vaccinated, and percentage of population vaccinated using CTE
WITH Popvsvac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) 
    OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
    FROM PortfolioProject.dbo.CovidDeaths AS Dea
    JOIN PortfolioProject.dbo.CovidVaccinations AS Vac
    ON Dea.location = Vac.location
    AND Dea.date = Vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated / Population) * 100
FROM Popvsvac
ORDER BY 2, 3;

-- Using temporary table for percentage population vaccinated
DROP TABLE IF EXISTS #PercentPopulationVaccunated;

CREATE TABLE #PercentPopulationVaccunated
(
    Continent NVARCHAR(250),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_Vacccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

INSERT INTO #PercentPopulationVaccunated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
FROM PortfolioProject.dbo.CovidDeaths AS Dea
JOIN PortfolioProject.dbo.CovidVaccinations AS Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date;

SELECT *, (RollingPeopleVaccinated / Population) * 100
FROM #PercentPopulationVaccunated;

-- Creating a view to store data for later visualization
/*
CREATE VIEW PercentPopulationVaccunated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
FROM PortfolioProject.dbo.CovidDeaths AS Dea
JOIN PortfolioProject.dbo.CovidVaccinations AS Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
WHERE dea.continent IS NOT NULL;
*/
