

select *
from ['Covid Deaths$']
where continent is not null
order by 3,4

select *
from ['Covid Vaccinations$']
order by 3,4

--select data that we are going to be using


select location,date,total_cases,new_cases,total_deaths,population
from ['Covid Deaths$']
order by 1,2

--looking at total_cases vs total_death
--likelihood of you dying when you contract covid in your country

select location,date,total_cases,total_deaths,(cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
from ['Covid Deaths$']
where location like '%Zambia%'
order by 1,2

--looking at total_cases vs population
--shows what percentage of population got covid

select location,date, total_cases,population,(cast(total_cases as float)/cast(population as float))*100 as PercentagePopulationInfected
from ['Covid Deaths$']
--where location like '%Zambia%'
order by 1,2

--looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HghestInfectioncount, max(cast(total_cases as float)/cast(population as float))*100 as PercentagePopulationInfected
from ['Covid Deaths$']
WHERE continent IS NOT NULL
group by location,population
order by PercentagePopulationInfected desc

-- looking at countries with highest death count per population

select location, max(CAST(total_deaths AS float)) as TotalDeathCount
from ['Covid Deaths$']
WHERE continent IS NOT NULL
group by location
order by TotalDeathCount desc

--lets break things down by continents

select continent,max(cast(total_deaths as float)) as TotalDeathCount
from ['Covid Deaths$']
WHERE continent is not null
group by continent
order by TotalDeathCount desc


--Global Number

select SUM(cast(new_cases as float))as totalcases ,SUM(CAST(new_deaths as float))as totaldeaths,sum(cast(total_deaths as float))/sum(cast(total_cases as float))*100 as DeathPercentage
from ['Covid Deaths$']
--where location like '%Zambia%'
where continent is not null
--group by date
order by 1,2


select *
from ['Covid Deaths$']  dea
join ['Covid Vaccinations$']  vac
on dea.location=vac.location
and dea.date=vac.date


-- looking at total population vs vaccination

select dea.date,dea.location,dea.continent,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
from ['Covid Deaths$']  dea
join ['Covid Vaccinations$']  vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--WITH CTE

WITH PopvsVac (location,date,continent,population,new_vaccinations,RollingPeopleVaccinated)
as
(select dea.date,dea.location,dea.continent,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
from ['Covid Deaths$']  dea
join ['Covid Vaccinations$']  vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)

select *,(RollingPeopleVaccinated/population)*100
from PopvsVac

--creating views to later store in data visualization

create view PopvsVac as
(select dea.date,dea.location,dea.continent,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
from ['Covid Deaths$']  dea
join ['Covid Vaccinations$']  vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)

select *
from PopvsVac