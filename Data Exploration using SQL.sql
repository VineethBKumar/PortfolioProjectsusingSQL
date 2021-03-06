/*

Covid 19 Data Exploration 


Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types


*/

select * 
from PortfolioProject .. CovidDeaths
order by 3,4


-- Select Data that we are going to be starting with

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject .. CovidDeaths
order by 1,2


--Looking at Total cases vs Total deaths
--Shows the likelihood of dying if you have been infected with covid in India

select location,date,total_cases,total_deaths,(total_deaths/total_cases) *100 as DeathPercentage
from PortfolioProject .. CovidDeaths
Where location = 'India'
order by 1,2

--Looking at Total cases vs Population
--Shows what percentage of population got Covid

select location,date,population,total_cases,(total_cases/population) *100 as PercentPopulationInfected
from PortfolioProject .. CovidDeaths
Where location = 'India'
order by 1,2

--Looking at countries with highest infection rate compared to population

select location,population, max(total_cases) as HighestInfectionCount, max((total_cases/population)) *100 as PercentPopulationInfected
from PortfolioProject .. CovidDeaths
group by location,population 
order by PercentPopulationInfected desc


--Showing countries with highest death count per population

select location,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject .. CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--Showing continents with highest death count per population

select continent,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject .. CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers

select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases) * 100 as DeathPercentage 
from PortfolioProject .. CovidDeaths
where continent is not null
order by 1,2


select *
from PortfolioProject..CovidVaccinations

--Joining the tables CovidDeaths and CovidVaccinations

select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date 

--Looking at Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null


