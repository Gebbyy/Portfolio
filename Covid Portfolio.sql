Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4


Select *
From PortfolioProject..CovidVaccinations
Where continent is not null
order by 3,4


Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


--Looking at Total Deaths vs Total Cases
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%china%'
order by 1,2


--Looking at Total Cases vs Population
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentofPopulationinfected
From PortfolioProject..CovidDeaths
Where continent is not null
Where location like '%states%'
order by 1,2


--Countries with Highest Infection Rate compared to Population
Select Location, population, Max(total_cases) as HighestInfecionCount, Max((total_cases/population))*100 as PercentofPopulationinfected
From PortfolioProject..CovidDeaths
Where continent is not null
group by Location, population
order by PercentofPopulationinfected desc


--Countries with Highest Death Rate compared to Population
Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
group by Location
order by TotalDeathCount desc


--Looking at world and continent death count
Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
group by location
order by TotalDeathCount desc



Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
group by continent
order by TotalDeathCount desc



--Global Numbers

Select date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
group by date
order by 1,2

Select SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2



Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as TotalPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


--Use CTE

With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, TotalPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as TotalPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
)
Select *,(TotalPeopleVaccinated/Population)*100
From PopvsVac



--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
TotalPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as TotalPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
order by 2,3

Select *,(TotalPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visual

Create View TotalPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as TotalPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null