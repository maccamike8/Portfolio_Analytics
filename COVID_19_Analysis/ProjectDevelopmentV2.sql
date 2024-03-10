--select * 
--from PortfolioProject..CovidDeaths
--where continent is not null
--order by 3, 4

--select * 
--from PortfolioProject..CovidVaccinations
--order by 3, 4

-- Selecting Data that I am going to be using 

--select location, date, total_cases, new_cases, total_deaths, population
--from PortfolioProject..CovidDeaths
--order by location, date 

--  Looking at Total Cases vs Total Deaths



--select location, 
--		 date,
--		 population,
--		 total_cases, 
--		 total_deaths,
--		 (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
--from PortfolioProject..CovidDeaths
--where location like 'Australia'
--order by location, date

-- Looking at Courtries with Highest Infection Rate compared to Population

--select location, population, Date 
--			MAX(total_cases) as highestInfectionCount,
--			ROUND(MAX((total_cases/population))*100, 2) as PercentagePopulationInfected
--FROM PortfolioProject..CovidDeaths
--group by location, population, Date
--order by 5 DESC

-- Showing the countries with the highest Death Count per Population
-- Note total deaths does need to be cast as an Integer or float

--select location, MAX(CAST(total_deaths as int)) as TotalDeathCount 
--FROM PortfolioProject..CovidDeaths
--where continent is not null
--group by location
--order by TotalDeathCount DESC

--  Breaking things down by Continent

--select location, MAX(CAST(total_deaths as int)) as TotalDeathCount 
--FROM PortfolioProject..CovidDeaths
--where continent is null
--group by location
--order by TotalDeathCount DESC

-- Showing the Continents with the Highest Death Count

--select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount 
--FROM PortfolioProject..CovidDeaths
--where continent is not null
-- and location not in ('World', 'European Union', 'International')
--group by location
--order by TotalDeathCount DESC

-- Global Numbers

-- Sum of the new Cases by Date

--select date, SUM(new_cases) -- total_deaths,
--		 -- (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
--from PortfolioProject..CovidDeaths
---- where location like 'Australia'
--where continent is not null
--group by date
--order by 1, 2

--select date, SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths
--		 -- total_deaths,
--		 -- (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
--from PortfolioProject..CovidDeaths
---- where location like 'Australia'
--where continent is not null
--group by date
--order by 1, 2

---- Death Percentage overall

--select date, sum(new_cases) as TotalNewCases, SUM(CAST(new_deaths as int)) as TotalNewDeaths,
--	(SUM(CAST(new_deaths as int))/nullif(sum(new_cases), 0)*100) as DeathPercentage
--from PortfolioProject..CovidDeaths
--where continent is not null
--group by date
--order by 1, 4

---- Overall Total Cases

--select sum(new_cases) as TotalNewCases, SUM(CAST(new_deaths as int)) as TotalNewDeaths,
--	(SUM(CAST(new_deaths as int))/nullif(sum(new_cases), 0)*100) as DeathPercentage
--from PortfolioProject..CovidDeaths
--where continent is not null
---- group by date
--order by 1, 2

-- Looking at the CovidVaccinations Table

--select *
--from PortfolioProject..CovidVaccinations

-- Joining the CovidDeaths and CovidVaccinations tables

--select *
--from PortfolioProject..CovidDeaths as dea
--join PortfolioProject..CovidVaccinations as vac
--	on dea.location = vac.location
--	and dea.date = vac.date

-- Looking at Total Population vs Vaccinations

--select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--	SUM(CONVERT(float, vac.new_vaccinations))  OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--from PortfolioProject..CovidDeaths as dea
--join PortfolioProject..CovidVaccinations as vac
--	on dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3

-- Working out how many people per country are vaccinated

-- Using a CTE

--with PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
--as
--(
--select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--	SUM(CONVERT(float, vac.new_vaccinations))  
--	OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--from PortfolioProject..CovidDeaths as dea
--join PortfolioProject..CovidVaccinations as vac
--	on dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null
---- order by 2, 3
--)
--select *
--from PopvsVac

--with PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
--as
--(
--select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--	SUM(CONVERT(float, vac.new_vaccinations))  
--	OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--from PortfolioProject..CovidDeaths as dea
--join PortfolioProject..CovidVaccinations as vac
--	on dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null
---- order by 2, 3
--)
--select *, (RollingPeopleVaccinated/Population)*100 as RollingPercentage
--from PopvsVac

--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations))  
	OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100 as RollingPercentage
From #PercentPopulationVaccinated

--  CREATING A VIEW TO STORE DATA FOR LATER VISUALISATIONS

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations))  
	OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3


Select *
from PercentPopulationVaccinated


-- Queries used for the Tableau Project

-- 1

select sum(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as TotalDeaths,
	(SUM(CAST(new_deaths as int))/nullif(sum(new_cases), 0)*100) as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
-- group by date
order by 1, 2

-- 2

select location, SUM(CAST(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths
where continent is null
 and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Low income', 'Lower middle income')
group by location
order by TotalDeathCount DESC

-- 3

select location, population, 
			MAX(total_cases) as highestInfectionCount,
			ROUND(MAX((total_cases/population))*100, 2) as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
group by location, population
order by 4 DESC

-- 4

select location, population, date,
			MAX(total_cases) as highestInfectionCount,
			ROUND(MAX((total_cases/population))*100, 2) as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
group by location, population, date
order by 5 DESC