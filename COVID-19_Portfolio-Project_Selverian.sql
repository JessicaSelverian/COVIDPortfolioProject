select*
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4 

--select*
--from PortfolioProject..CovidVaccinations
--order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of dying if you contract Covid in your country (1.78%)
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2


-- Looking at Total Cases vs Population 
-- Showing what percentage of population got Covid (10%)
select location, date, population, total_cases, (total_cases/population)*100 as PercentOfPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compare to population (Andorra = 17.13%)

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentOfPopulationInfected
from PortfolioProject..CovidDeaths
Group by location, population 
order by PercentOfPopulationInfected

-- Showing the countries with the Highest death count per population  
select location,Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc


-- Breaking things down by continent (vs location)
select location,Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc
-- Before we were looking at the location and it was the countries itself and then there were ones where is not null to remove things like 'world.'
-- Now we're filtering on those instead of deleting them. Before we were looking at everything but those, now we're only looking at these.


-- Showing the continents with the highest death count per popluation
select continent,Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global numbers 
select date, SUM(new_cases), SUM (cast(new_deaths as int))
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2
-- new cases is a float but new deaths is a varchar, which is why we need to cast as an int

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2
--this is per day

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2
-- this is across the world (total); death percentage a bit over 2%	


-- USING CTE (common table expression)

with PopVsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
--Looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVavvinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)

Select*, (RollingPeopleVaccinated/Population)*100
From PopVsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVavvinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVavvinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
