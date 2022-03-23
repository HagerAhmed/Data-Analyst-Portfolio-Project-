/*Covid 19 Data Exploration */


--Checking the data has been imported right

SELECT * 
FROM [dbo].[CovidDeath]
--Where continent is not Null 
Order By 3,4


SELECT * 
FROM [dbo].[CovidVaccination]
Order By 3,4

-- Select Data that will be used 

SELECT Location, date, total_cases, new_cases,total_deaths, population 
FROM [dbo].[CovidDeath]
Order By 1,2

-- Looking at Total Cases vs total Deaths 
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [dbo].[CovidDeath]
--WHERE Location Like 'Egypt'
Order By 1,2


-- Looking at Total cases vs Population
SELECT Location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
FROM [dbo].[CovidDeath]
--WHERE Location Like 'Egypt'
Order By 1, 2

--Find countries with highest Infection Rate comparing to Population 

SELECT Location,  population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CasePercentage
FROM [dbo].[CovidDeath]
GROUP BY location, population
Order By 4 desc

-- Showing countries with highest Death Count per population 
SELECT Location,  population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CasePercentage
FROM [dbo].[CovidDeath]
GROUP BY location, population
Order By 4 desc


-- Showing countries with highest Death Count per country // CAST to convert the data type of the coloumn 
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [dbo].[CovidDeath]
Where continent is not null 
GROUP BY location
Order By TotalDeathCount desc

-- Break things down by location and continent is null
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [dbo].[CovidDeath]
Where continent is null 
GROUP BY location
Order By TotalDeathCount desc

-- Break things down by Continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [dbo].[CovidDeath]
Where continent is not null 
GROUP BY continent
Order By TotalDeathCount desc

--Showing the Continent with the highest death count per population 
SELECT Location,  population, continent, MAX(cast(total_deaths as int)) as HighestDeath, MAX((total_deaths/population))*100 as DeathPercentage
FROM [dbo].[CovidDeath]
Where continent is not null 
GROUP BY location, population, continent
Order By DeathPercentage desc



-- GLOBAL NUMBER  
SELECT  /*date,*/ SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,  (SUM(cast(new_deaths as int))/ SUM(new_cases))*100 as NewDeathsPercentage 
FROM [dbo].[CovidDeath]
Where continent is not null 
--Group by  date
Order By 1,2

-- GLOBAL NUMBER per location 
SELECT  location, date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,  (SUM(cast(new_deaths as int))/ SUM(new_cases))*100 as NewDeathsPercentage 
FROM [dbo].[CovidDeath]
Where continent is not null AND new_cases is not Null AND new_deaths is not null AND new_cases != 0
Group by location, date
Order By NewDeathsPercentage desc


--Looking at Total Population vs Vaccination 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM [dbo].[CovidDeath] dea
join [dbo].[CovidVaccination] vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null  
order by 2,3 

-- USE CTE 
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM [dbo].[CovidDeath] dea
join [dbo].[CovidVaccination] vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null  
--order by dea.location, dea.date
)
Select *, (RollingPeopleVaccinated/Population)*100 VacPercenatge 
From PopvsVac
Where new_vaccinations is not null


-- Temp Table 
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(225), 
Location nvarchar(225), 
Date datetime, 
Population nvarchar(225), 
new_vaccinations float, 
RollingPeopleVaccinated float)
INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM [dbo].[CovidDeath] dea
join [dbo].[CovidVaccination] vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null  
--order by dea.location, dea.date

Select *, (RollingPeopleVaccinated/Population)*100 VacPercenatge 
From #PercentPopulationVaccinated
Where new_vaccinations is not null


-- Creating view to store data for later visulaization 

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM [dbo].[CovidDeath] dea
join [dbo].[CovidVaccination] vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null  
--order by dea.location, dea.date

Select * from PercentPopulationVaccinated