Select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4

--Select *
--from PortfolioProject..CovidVaccinations
--order by 3, 4


--Select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.. CovidDeaths
where continent is not null
order by 1,2


--Looking at total cases vrs total deaths
--shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject.. CovidDeaths
where continent is not null
and location like '%Ghana%'
order by 1,2


--Looking at the total cases vrs population
--shows percentage of people in the country who have covid
Select Location, date, Population, total_cases, (total_cases/population) * 100 as InfectedPopulation
from PortfolioProject.. CovidDeaths
--where location like '%Ghana%'
order by 1,2


--Looking at countries with highes infection rate compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, 
MAX(total_cases/population) * 100 as InfectedPopulationPercentage
from PortfolioProject.. CovidDeaths
where continent is not null
--where location like '%Ghana%'
Group by Location, population
order by InfectedPopulationPercentage desc


--Showing countries with highest death count per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.. CovidDeaths
where continent is not null
--where location like '%Ghana%'
Group by Location
order by TotalDeathCount desc


--Let's break things down by continent



--showing the continents with the highest death count
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.. CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


--global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject.. CovidDeaths
where continent is not null
--Group by date
order by 1,2


--Looking at total population vrs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) 
OVER (Partition by dea.Location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--use CTE
with PopvsVac (continent, location, date,population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) 
OVER (Partition by dea.Location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVaccinated/population) * 100
From PopvsVac


--Temp table
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) 
OVER (Partition by dea.Location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select * , (RollingPeopleVaccinated/population) * 100
From #PercentPopulationVaccinated


--creating view to store data for later visualizations
--Drop view if exists [PercentPopulationVaccinated]
create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) 
OVER (Partition by dea.Location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3