Select * 
From PortfolioProject..CovidDeaths
Where continent is not NULL
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not NULL
Order by 1,2

-- Looking at Total Cases vs Total Deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not NULL
and location like 'Viet%'
Order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select location, date, population, total_cases, (total_cases/population)*100 As PercentagePopulationInflection
From PortfolioProject..CovidDeaths
Where continent is not NULL
and location like 'Viet%'
Order by 1,2

-- Looking at Countries with inflection rate compared to Population
Select Location, Population, Max(total_cases) As HighestInflectionCount, Max((Total_Cases/Population))*100 As PercentagePopulationInflection  
From PortfolioProject..CovidDeaths
Where continent is not NULL
Group by Location, Population
Order by PercentagePopulationInflection desc


-- Showing Countries with Highest Death Count per Population
Select Location, max(cast(total_deaths as int)) as TotalDeaths
From PortfolioProject..CovidDeaths
Where continent is not NULL
group by location
order by TotalDeaths desc

-- Checking inflection by Continent
Select continent, max(cast(total_deaths as int)) as TotalDeaths
From PortfolioProject..CovidDeaths
Where continent is not NULL
group by continent
order by TotalDeaths desc

-- Showing continents with the Highest Death count per Population
Select continent, max(cast(total_deaths as int)) as TotalDeaths
From PortfolioProject..CovidDeaths
where continent is not NULL
group by continent
order by TotalDeaths desc

-- Global Numbers
Select Sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/Sum(new_cases) as Percentage
From PortfolioProject..CovidDeaths
Where continent is not NULL
--Group by date
Order by 1,2

-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
Order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 
From PopvsVac


-- Temp Table
Drop table if exists #PercentagePopulationVaccinated
Create table #PercentagePopulationVaccinated 
(
Continent nvarchar (255),
Location nvarchar (255),
Date Datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 
From #PercentagePopulationVaccinated


