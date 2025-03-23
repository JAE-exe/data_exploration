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

-- (1) Previewing the Data
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY country, date;

-- (2) Selecting Relevant COVID-19 Data for Analysis
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

-- (3) Likelihood of Death if Infected with COVID-19
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

-- (4) Percentage of Population Infected with COVID-19
SELECT 
    country, 
    population, 
    MAX(total_cases) AS HighestInfectionCount,  
    MAX((CAST(total_cases AS FLOAT) / NULLIF(population, 0))) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY country, population
ORDER BY PercentPopulationInfected DESC;

-- (5) Countries with the Highest COVID-19 Death Counts
SELECT 
    country, 
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY country
ORDER BY TotalDeathCount DESC;

-- (6) Relationship Between Handwashing Facilities and COVID-19 Infection Rates
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

-- (7) Continent-wise Total Death Count
SELECT 
    continent, 
    SUM(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- (8) Global COVID-19 Case and Death Summary with Death Percentage
SELECT 
    SUM(new_cases) AS TotalCases, 
    SUM(CAST(new_deaths AS INT)) AS TotalDeaths, 
    (SUM(CAST(new_deaths AS INT)) / NULLIF(SUM(new_cases), 0)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL;

-- (9) Rolling Count of Vaccinated People Per Country
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

-- (10) COVID-19 Death Percentage Per Country
SELECT 
    country, 
    MAX(total_deaths) AS TotalDeathCount,  
    MAX(total_cases) AS HighestInfectionCount,  
    (MAX(CAST(total_deaths AS FLOAT)) / NULLIF(MAX(total_cases), 0)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY country
ORDER BY DeathPercentage DESC;

-- (11) COVID-19 Total Death Count by Country
SELECT 
    country, 
    MAX(total_deaths) AS TotalDeathCount  
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY country
ORDER BY TotalDeathCount DESC;

-- (12) COVID-19 Total Death Count by Continent
SELECT 
    continent, 
    SUM(total_deaths) AS TotalDeathCount  
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- (13) Global COVID-19 Cases and Deaths Per Day
SELECT 
    date, 
    SUM(new_cases) AS GlobalCasesPerDay,
    SUM(new_deaths) AS GlobalDeathsPerDay,
    (CAST(NULLIF(SUM(new_deaths), 0) AS FLOAT) / NULLIF(SUM(new_cases), 0)) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

-- (14) Relationship Between Hospital Capacity and COVID-19 Mortality
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

-- (15) COVID-19 Testing Effectiveness by Country
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

-- (16) Rolling Count of Vaccinated People Per Country
SELECT 
    dea.continent,
    dea.country,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (
        PARTITION BY dea.country 
        ORDER BY dea.date
    ) AS total_vaccinations_rolling
FROM CovidDeaths dea
JOIN CovidVaccines vac
    ON dea.country = vac.country
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.country, dea.date;

-- (17) Using a Common Table Expression (CTE) to Track Vaccination Percentage Over Time
WITH VaccinationRoll AS (
    SELECT 
        dea.continent,
        dea.country,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (
            PARTITION BY dea.country 
            ORDER BY dea.date
        ) AS total_vaccinations_rolling
    FROM CovidDeaths dea
    JOIN CovidVaccines vac
        ON dea.country = vac.country
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT 
    continent,
    country,
    date,
    population,
    new_vaccinations,
    total_vaccinations_rolling,
    (CAST(total_vaccinations_rolling AS FLOAT) / NULLIF(CAST(population AS FLOAT), 0)) * 100 AS vaccination_percentage_rolling
FROM VaccinationRoll
ORDER BY country, date;
