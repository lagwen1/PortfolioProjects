Select * 
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4

Select * 
From PortfolioProject..CovidVaccinations$
order by 3,4

-- Select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

--Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2


-- Looking at countries with Highest Infection Rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc


-- Showing countries with Highest Death per population
Select Location, MAX(Total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states%'
Group by location
order by TotalDeathCount desc


--LETS BREAK THINGS DOWN BY CONTINENT
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths$
--where continent like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
--Group By date
order by 1,2

--Looking at Total Populatoin vs Vaccinations

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated)/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--TEMP TABLE
Drop table if exists #PercentagePopulationVaccinated
(
CREATE Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated)/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentagePopulationVaccinated
From #PercentagePopulationVaccinated;


-- Creating view to store data for later visualizations

Create view PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated)/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentagePopulationVaccinated