--Select * from PortfolioProjects..CovidDeaths
--order by 3,4

--Select * from PortfolioProjects..CovidVaccinations
--order by 3,4


--Looking at Total Deaths vs TotalCases

Select location, date,total_cases, total_deaths,(CAST (total_deaths as float) / CAST ( total_cases as float)) *100 as DeathPercentage
from PortfolioProjects..CovidDeaths
Where continent is not null
order by 1,2

--Looking at TotalCases vs Population
Select location, date,total_cases, population, CAST ( total_cases as float) / population *100 as PopulationPercentage
from PortfolioProjects..CovidDeaths
--Where location like 'Iran'
Where continent is not null
order by 1,2


--Looking at Countries with highest infection rate compared to Population
Select location, population, MAX (total_cases) as HighestInfectionCount, MAX(CAST ( total_cases as float) / population *100) as PopulationPercentage
from PortfolioProjects..CovidDeaths
--Where location like 'Iran'
Where continent is not null
Group by location, population
order by PopulationPercentage desc

-- Showing contitnents with the highest death count per population 
Select continent, MAX(CAST ( total_deaths as int)) as TotalDeathCount 
from PortfolioProjects..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS
Select SUM(new_cases) as Total_New_Cases, SUM(new_deaths) as Total_Deaths, SUM(new_deaths) / SUM(new_cases) *100 as DeathPercentage
from PortfolioProjects..CovidDeaths
Where continent is not null
order by 1,2


-- Looking at Total Population vs Vaccination
With PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
As
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) Over (partition by dea.location Order by dea.location, dea.date) 
as RollingPeopleVaccinated 
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
		and dea.date = vac.date
		Where dea.continent is not null
--order by 2,3
)
select *,  (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- TEMP Table
DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar (255)
, Location nvarchar (255)
, Date datetime
, Population numeric
, New_Vaccination numeric
, RollingPeopleVaccinated numeric)

Insert Into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast (vac.new_vaccinations as bigint)) Over (partition by dea.location Order by dea.location, dea.date) 
as RollingPeopleVaccinated 
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
		and dea.date = vac.date
		Where dea.continent is not null
--order by 2,3

select *,  (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--Creating View to store data for later visulization

Create View PercentPopulationVaccinated
as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) Over (partition by dea.location Order by dea.location, dea.date) 
as RollingPeopleVaccinated 
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
		and dea.date = vac.date
		Where dea.continent is not null
		--order by 2,3