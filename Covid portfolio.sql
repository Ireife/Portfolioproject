-- Data exporation in SQL
select*
from Project_portfolio..CovidDeaths$
order by 2,3

--Data selection
select continent,location,date,population,total_cases,new_cases,new_deaths,total_deaths
from Project_portfolio..CovidDeaths$
order by 2,3

-- Cases by Cases basis

select continent,location,date,population,total_cases,new_cases, (new_cases/total_cases)*100 as Percentage_Cases
from Project_portfolio..CovidDeaths$
order by 2,3

--Percentage_death vs percentage cases
select continent,location,date,population,total_cases,new_cases,new_deaths,total_deaths,(new_cases/total_cases)*100 as Percentage_Cases,(CAST(new_deaths as int)/CAST(total_deaths as int))*100 as Percentage_Deaths
from Project_portfolio..CovidDeaths$
order by Percentage_Deaths desc

--Population vs death

select continent,population, (CAST(total_deaths as int)/population)*100 as deaths_population
from Project_portfolio..CovidDeaths$

--Global numbers 1

select date, sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from Project_portfolio..CovidDeaths$
where continent is not null
Group by date
order by 1,2

--Global numbers 1
select date, SUM(new_cases) , SUM(cast(new_deaths as int)) , sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from Project_portfolio..CovidDeaths$
where continent is not null
Group by date
order by 1,2


--Total_death per Continent
select continent, sum(CAST(total_deaths as int)) as TotalDeathCount
from Project_portfolio..CovidDeaths$
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Joining operation



	-- Total Population vs Vacinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Project_portfolio..CovidDeaths$ dea
join Project_portfolio..Covidvacinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
with popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Project_portfolio..CovidDeaths$ dea
join Project_portfolio..Covidvacinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*, (RollingPeopleVaccinated/population)*100
from popvsvac


-- Temp Table

Drop table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Project_portfolio..CovidDeaths$ dea
join Project_portfolio..Covidvacinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- View Table to store data for visualisation

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Project_portfolio..CovidDeaths$ dea
join Project_portfolio..Covidvacinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*
from  PercentPopulationVaccinated
