/*
    COVID-19 Data Exploration Project

    This project analyzes COVID-19 data using SQL techniques including:
    - Joins
    - Common Table Expressions (CTEs)
    - Temporary Tables
    - Window Functions
    - Aggregate Functions
    - Creating Views
    - Data Type Conversions
*/

-- 1. Previewing the Data
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY country, date;

-- 2. Selecting relevant COVID-19 data for analysis
SELECT 
    country, 
    date, 
    total_cases, 
    new_cases, 
    total_deaths, 
    population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY country, date;

-- 3. Calculating the likelihood of death if infected with COVID-19
SELECT 
    country, 
    date, 
    total_cases, 
    total_deaths, 
    (CAST(total_deaths AS FLOAT) / NULLIF(total_cases, 0)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE country = 'India' 
AND continent IS NOT NULL 
ORDER BY date;

-- 4. Percentage of the population infected with COVID-19
SELECT 
    country, 
    population, 
    MAX(total_cases) AS HighestInfectionCount,  
    MAX((CAST(total_cases AS FLOAT) / NULLIF(population, 0))) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY country, population
ORDER BY PercentPopulationInfected DESC;

-- 5. Countries with the highest COVID-19 death counts
SELECT 
    country, 
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY country
ORDER BY TotalDeathCount DESC;

-- 6. Relationship between handwashing facilities and COVID-19 infection rates
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

-- 7. Continent-wise total death count
SELECT 
    continent, 
    SUM(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- 8. Global COVID-19 case and death summary with death percentage
SELECT 
    SUM(new_cases) AS TotalCases, 
    SUM(CAST(new_deaths AS INT)) AS TotalDeaths, 
    (SUM(CAST(new_deaths AS INT)) / NULLIF(SUM(new_cases), 0)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL;

-- 9. Rolling count of vaccinated people per country
SELECT 
    dea.continent, 
    dea.country, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
        OVER (PARTITION BY dea.country ORDER BY dea.date) AS RollingVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccines vac
    ON dea.country = vac.country
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY dea.country, dea.date;

-- 10. COVID-19 Death percentage per country
SELECT 
    country, 
    MAX(total_deaths) AS TotalDeathCount,  
    MAX(total_cases) AS HighestInfectionCount,  
    (MAX(CAST(total_deaths AS FLOAT)) / NULLIF(MAX(total_cases), 0)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY country
ORDER BY DeathPercentage DESC;

-- 11. COVID-19 Total Death Count by Country
SELECT 
    country, 
    MAX(total_deaths) AS TotalDeathCount  
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY country
ORDER BY TotalDeathCount DESC;

-- 12. COVID-19 Total Death Count by Continent
SELECT 
    continent, 
    SUM(total_deaths) AS TotalDeathCount  
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- 13. Global COVID-19 cases and deaths per day
SELECT date, 
       SUM(new_cases) AS GlobalCasesPerDay,
       SUM(new_deaths) AS GlobalDeathsPerDay,
       (CAST(NULLIF(SUM(new_deaths), 0) AS FLOAT) / NULLIF(SUM(new_cases), 0)) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

-- 14. Relationship between hospital capacity and COVID-19 mortality
SELECT 
    dea.country,
    MAX(CAST(dea.total_cases AS FLOAT)) AS TotalCases,
    MAX(CAST(dea.total_deaths AS FLOAT)) AS TotalDeaths,
    (MAX(CAST(dea.total_deaths AS FLOAT)) / NULLIF(MAX(CAST(total_cases AS FLOAT)), 0)) * 100 AS DeathRate,
    MAX(vac.hospital_beds_per_thousand) AS HospitalBedsPerThousand,
    MAX(vac.handwashing_facilities) AS HandwashingAvailability
FROM CovidDeaths dea
JOIN CovidVaccines vac
    ON dea.country = vac.country
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.country
ORDER BY DeathRate DESC;

-- 15. COVID-19 Testing Effectiveness by Country
SELECT 
    country,
    MAX(CAST(tests_per_case AS FLOAT)) AS MaxTestsPerCase,
    MAX(CAST(positive_rate AS FLOAT)) AS MaxPositiveRate,
    CASE 
        WHEN MAX(CAST(tests_per_case AS FLOAT)) > 10 AND MAX(CAST(positive_rate AS FLOAT)) < 5 THEN 'Good Testing'
        WHEN MAX(CAST(tests_per_case AS FLOAT)) BETWEEN 2 AND 10 AND MAX(CAST(positive_rate AS FLOAT)) BETWEEN 5 AND 15 THEN 'Moderate Testing'
        ELSE 'Undertesting'
    END AS TestingEffectiveness
FROM CovidVaccines
WHERE tests_per_case IS NOT NULL AND positive_rate IS NOT NULL
GROUP BY country
ORDER BY MaxPositiveRate DESC;
