Select *
From [portfolio project]..CovidDeaths
Where continent is not null
order by 3,4

--  selecting data 
Select Location, date, total_cases, new_cases, total_deaths, population
From [portfolio project] ..CovidDeaths
Where continent is not null 
order by 1,2

--total  cases vs total deaths 
-- affected percentage of people in india 
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [portfolio project] ..CovidDeaths
Where location like '%india%'
and continent is not null 
order by 1,2

--Total Cases vs Population
--people affected percentafe in india during covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From [portfolio project] ..CovidDeaths
Where location like '%india%'

order by 1,2


--countries with highest infection rate
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [portfolio project] ..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

--shows the countries with the highest death count 

Select Location, MAX(cast(Total_deaths as bigint)) as TotalDeathCount
From [portfolio project]..CovidDeaths
 Where continent is not null --to not group in orders of continents 
Group by Location
order by TotalDeathCount desc

-- exploration on the basis of continents 
-- total deaths according to the continents   

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [portfolio project]..CovidDeaths

Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- global effect 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [portfolio project]..CovidDeaths
where continent is not null 
--group by date
order by 1,2

--   -- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
--using rolling count 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [portfolio project]..CovidDeaths dea
Join [portfolio project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- using ctes  we can perform calculations on partition by
--number of columns should be same

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [portfolio project]..CovidDeaths dea
Join [portfolio project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
--run with cte
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--temp tables

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From [portfolio project]..CovidDeaths dea
Join [portfolio project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--creating views 

Create View PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [portfolio project]..CovidDeaths dea
Join [portfolio project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 






