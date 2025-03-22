/*
    COVID-19 Data Exploration 

    This SQL project explores COVID-19 data using various SQL techniques, including:
    - Joins
    - Common Table Expressions (CTEs)
    - Temporary Tables
    - Window Functions
    - Aggregate Functions
    - Creating Views
    - Data Type Conversions
*/

/* 1. Previewing the Data */
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 3, 4;

/* 2. Selecting relevant COVID-19 data for analysis */
SELECT 
    country, 
    date, 
    total_cases, 
    new_cases, 
    total_deaths, 
    population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1, 2;

/* 3. Calculating the likelihood of death if infected with COVID-19 */
SELECT 
    country, 
    date, 
    total_cases, 
    total_deaths, 
    (CAST(total_deaths AS FLOAT) / NULLIF(total_cases, 0)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE country LIKE '%INDIA%'
AND continent IS NOT NULL 
ORDER BY 1, 2;

/* 4. Percentage of the population infected with COVID-19 */
SELECT 
    country, 
    population, 
    MAX(total_cases) AS HighestInfectionCount,  
    MAX((CAST(total_cases AS FLOAT) / NULLIF(population, 0))) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY country, population
ORDER BY PercentPopulationInfected DESC;

/* 5. Countries with the highest COVID-19 death counts */
SELECT 
    country, 
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY country
ORDER BY TotalDeathCount DESC;

/* 6. Relationship between handwashing facilities and COVID-19 infection rates */
SELECT 
    dea.country, 
    dea.population, 
    MAX(dea.total_cases) AS HighestInfectionCount,  
    MAX(CAST(dea.total_cases AS FLOAT)) / NULLIF(dea.population, 0) * 100 AS PercentPopulationInfected,
    MAX(vac.handwashing_facilities) AS HandwashingAvailability
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccines vac
    ON dea.country = vac.country
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL  
GROUP BY dea.country, dea.population
ORDER BY HandwashingAvailability DESC;

/* 7. Continent-wise total death count */
SELECT 
    continent, 
    SUM(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC;

/* 8. Global COVID-19 case and death summary with death percentage */
SELECT 
    SUM(new_cases) AS TotalCases, 
    SUM(CAST(new_deaths AS INT)) AS TotalDeaths, 
    SUM(CAST(new_deaths AS INT)) / NULLIF(SUM(new_cases), 0) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL;

/* 9. Rolling count of vaccinated people per country */
SELECT 
    dea.continent, 
    dea.country, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
        OVER (PARTITION BY dea.country ORDER BY dea.country, dea.date) 
        AS RollingVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccines vac
    ON dea.country = vac.country
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY dea.country, dea.date;

/* 10. Highest infection count and population percentage infected per country */
SELECT 
    country, 
    population, 
    MAX(total_cases) AS HighestInfectionCount,  
    MAX(CAST(total_cases AS FLOAT) / NULLIF(population, 0)) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY country, population
ORDER BY PercentPopulationInfected DESC;

/* 11. COVID-19 Death percentage per country */
SELECT 
    country, 
    MAX(total_deaths) AS TotalDeathCount,  
    MAX(total_cases) AS HighestInfectionCount,  
    MAX(CAST(total_deaths AS FLOAT) / NULLIF(total_cases, 0)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY country
ORDER BY DeathPercentage DESC;

/* 12. COVID-19 Total Death Count by Country */
SELECT 
    country, 
    MAX(total_deaths) AS TotalDeathCount  
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY country
ORDER BY TotalDeathCount DESC;

/* 13. Total Death Count by Continent */
SELECT 
    continent, 
    SUM(total_deaths) AS TotalDeathCount  
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

SELECT date,country,total_cases,total_deaths,CAST(total_deaths AS FLOAT)/NULLIF(total_cases,0) AS death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL

SELECT date,SUM(new_cases) AS globalcasesperday,SUM(new_deaths) AS globaldeathssperday --total_cases,total_deaths,CAST(total_deaths AS FLOAT)/NULLIF(total_cases,0) AS death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2
    
SELECT 
    country,
    MAX(total_cases) AS highest_infection_count,
    MAX(total_deaths) AS total_death_count,
    (MAX(CAST(total_deaths AS FLOAT)) / NULLIF(MAX(total_cases), 0)) * 100 AS death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY country
ORDER BY death_percentage DESC;


SELECT date,SUM(new_cases) AS globalcasesperday,SUM(new_deaths)  AS globaldeathssperday,CAST(NULLIF(SUM(new_deaths),0)AS FLOAT)/NULLIF(SUM(new_cases),0)*100   --total_cases,total_deaths,CAST(total_deaths AS FLOAT)/NULLIF(total_cases,0) AS death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


SELECT 
    dea.country, 
    dea.population, 
    MAX(dea.total_cases) AS InfectionCount,
    MAX(dea.total_deaths) AS DeathCount, 
    MAX(CAST(dea.total_cases AS FLOAT) / NULLIF(dea.population, 0)) * 100 AS PercentPopulationInfected,
    MAX(CAST(dea.total_deaths AS FLOAT) / NULLIF(dea.total_cases, 0)) * 100 AS DeathRate,
    MAX(vac.diabetes_prevalence) AS DiabetesPrevalence
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccines vac
    ON dea.country = vac.country
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL  
GROUP BY dea.country, dea.population
ORDER BY DiabetesPrevalence DESC;

