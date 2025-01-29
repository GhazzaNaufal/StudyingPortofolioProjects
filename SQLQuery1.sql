select * 
from PortofolioProject..CovidDeaths$
--where continent is not null
order by 3,4

--select * 
--from PortofolioProject..CovidVaccinations$
--order by 3,4

-- Select Data that we are going to be using

Select  location,date,total_cases,new_cases,total_deaths,population
from PortofolioProject..CovidDeaths$
order by 1,2


-- Looking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortofolioProject..CovidDeaths$
where location like '%states%'
and continent is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population get covid
select location,date,total_cases,Population,(total_cases/population)*100 as CasesPercentage
from PortofolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

--Looking at country with highest infection rate compared to population

select location,Population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as CasesPercentage
from PortofolioProject..CovidDeaths$
--where location like '%states%'
group by location,Population
order by CasesPercentage asc


-- Showing Countries with Highest Death Count per Popoulation

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortofolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc


--let's break things down by continent


--Showing continents with the highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortofolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortofolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths$ dea
join PortofolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

with PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths$ dea
join PortofolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select * ,(RollingPeopleVaccinated/population)*100
from PopvsVac


-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
 RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths$ dea
join PortofolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select * ,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating View to store data for later visualiztion

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths$ dea
join PortofolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated