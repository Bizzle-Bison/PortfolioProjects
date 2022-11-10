select * 
from Covid_Project.dbo.CovidDeath
where continent is not null
order by 3,4

--select * 
--from Covid_Project..CovidVaccination
--order by 3,4

-- select columns that are needed

select location, date, total_cases, new_cases, total_deaths, population
from Covid_Project.dbo.CovidDeath
order by 1,2

-- Total cases vs Total Deaths

select location, date, total_cases, total_deaths, Round((total_deaths/total_cases),3) * 100 AS DeathPercentage
from Covid_Project.dbo.CovidDeath
where location like '%Nigeria%'
order by 1,2

-- Total cases vs Population

select location, date,  population, total_cases, Round((total_cases/population),3) * 100 AS PopulationPercentageInfected
from Covid_Project.dbo.CovidDeath
where location like '%Nigeria%'
order by 1,2

-- Countries with highest infection rate compared to population

select location, population, MAX(total_cases) AS highest_infection_count, Max((total_cases/population)) * 100 AS PopulationPercentageInfected
from Covid_Project.dbo.CovidDeath
-- where location like '%Nigeria%'
group by Location, Population
order by PopulationPercentageInfected desc

-- Countries with highest death rate

select location, max(cast(total_deaths as int)) as TotalDeathCount
from Covid_Project.dbo.CovidDeath
-- where location like '%Nigeria%'
where continent is not null
group by Location
order by TotalDeathCount desc

-- Break things down by continent
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from Covid_Project.dbo.CovidDeath
-- where location like '%Nigeria%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- Continent with highest death count

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from Covid_Project.dbo.CovidDeath
-- where location like '%Nigeria%'
where continent is not null
group by continent
order by TotalDeathCount desc


--Checking the global number of cases and deaths

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from Covid_Project.dbo.CovidDeath
-- where location like '%Nigeria%'
where continent is not null
-- group by continent
order by 1,2 

-- Total population and vaccinations

-- USE CTE

with PopvsVac (Continent,location, Date, Population, New_vaccinations, RollingPeopleVaccinated )
as 
(

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.date) as RollingPeopleVaccinated 
from Covid_Project.dbo.CovidDeath dea
join Covid_Project..CovidVaccination vac
on dea.location = vac.location and dea.date = vac.date
-- where location like '%Nigeria%'
where dea.continent is not null
-- order by 2,3
)
select *, (RollingPeopleVaccinated/Population) * 100 from PopvsVac


-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as numeric)) OVER (partition by dea.location order by dea.date) as RollingPeopleVaccinated 
from Covid_Project.dbo.CovidDeath dea
join Covid_Project..CovidVaccination vac
on dea.location = vac.location and dea.date = vac.date
-- where dea.continent is not null
-- order by 2,3

select *, (RollingPeopleVaccinated/Population) * 100 as percentVaccinated from #PercentPopulationVaccinated

-- Creating view to store data for visualizations

CREATE VIEW rolling_pop_vax as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as numeric)) OVER (partition by dea.location order by dea.date) as RollingPeopleVaccinated 
from Covid_Project.dbo.CovidDeath dea
join Covid_Project..CovidVaccination vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
-- order by 2,3


select * from rolling_pop_vax

