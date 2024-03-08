select * 
from portfolioproject..['covid deaths$']
where continent is not null
order by 3,4

--select * 
--from portfolioproject..['covid vaccinations$']
--order by 3,4

--select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject..['covid deaths$']
where continent is not null
order by 1,2

-- looking at the total cases vs the total deaths
-- shows likelihood of dying if you contract covid in your country

select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
from portfolioproject..['covid deaths$']
where continent is not null
order by 1,2

select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
from portfolioproject..['covid deaths$']
where location like 'nepal'
order by 1,2


-- looking at total cases vs population
-- shows what percentage of population got covid

select Location, date, total_cases, population, (cast(total_cases as float)/cast(population as float))*100 as percentpopulationinfected
from portfolioproject..['covid deaths$']
where location like 'nepal'
order by 1,2


-- looking at countries with highest infection rate compared to population

select Location, max(total_cases) as highestinfectioncount , population, max((total_cases/population))*100 as percenpopulationinfected
from portfolioproject..['covid deaths$']
where continent is not null
group by location, population
order by percenpopulationinfected desc


-- showing countries with highest death count per population

select Location, max(cast (total_deaths as int)) as totaldeathcount
from portfolioproject..['covid deaths$']
where continent is not null
group by location
order by totaldeathcount desc


-- lets break things down by continent
-- showing continents with the highest death count per population

select continent, max(cast (total_deaths as int)) as totaldeathcount
from portfolioproject..['covid deaths$']
where continent is not null
group by continent
order by totaldeathcount desc


-- global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as float))/NULLIF(sum(cast(new_cases as float)),0)*100 as deathpercent
from portfolioproject..['covid deaths$']
where continent is not null
--group by date
order by 1,2


-- looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from portfolioproject..['covid deaths$'] dea
join portfolioproject..['covid vaccinations$'] vac 
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- use cte

with PopvsVac(continent, location, date, population,new_vaccinations, rollingpeoplevaccinated) 
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from portfolioproject..['covid deaths$'] dea
join portfolioproject..['covid vaccinations$'] vac 
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (rollingpeoplevaccinated/population)*100
from PopvsVac



-- temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from portfolioproject..['covid deaths$'] dea
join portfolioproject..['covid vaccinations$'] vac 
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *, (rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated



-- creating view to store data for later visualization

create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from portfolioproject..['covid deaths$'] dea
join portfolioproject..['covid vaccinations$'] vac 
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select * from percentpopulationvaccinated