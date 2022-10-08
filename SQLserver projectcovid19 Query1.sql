select* from dbo.CovidDeaths$
where continent is not null
order by 3 ,4;


--select* from dbo.CovidVaccinations$
--order by 3 ,4;

--deaths_rate in usa
select location,date,(new_cases),(total_cases),(total_deaths),(total_deaths/total_cases)*100 as deaths_rate
from dbo.CovidDeaths$
where location like '%states%'
order by 1,2;

--infectionrate
select location,date,population,(total_cases),(total_cases/population)*100 as infection_rate
from dbo.CovidDeaths$
--where location like '%states%'
order by 1,2;

--location wise infection rate
select location,population,MAX(total_cases)AS highestinfectioncount,max((total_cases/population))*100 as highestinfection_rate
from dbo.CovidDeaths$
where continent is not null
group by location,population
order by highestinfection_rate desc;

--location wise deathrate
select location,population,MAX(cast(total_deaths as int)) AS highestdeathcounts,max((total_deaths/population))*100 as highestdeath_rate
from dbo.CovidDeaths$
where continent is not null
group by location,population 
order by highestdeath_rate desc;


--location wise deathrates
select location,MAX(cast(total_deaths as int)) AS highestdeathcounts
from dbo.CovidDeaths$
where continent is not null
group by location
order by  highestdeathcounts desc;

--continent wise total deathcounts
select continent,sum(cast(total_deaths as int)) AS highestdeathcounts
from dbo.CovidDeaths$
where continent is not null
group by continent
order by  highestdeathcounts desc;

--loation wise  death counts
select location,max(cast(total_deaths as int)) AS highestdeathcounts
from dbo.CovidDeaths$
where continent is not null
group by location
order by  highestdeathcounts desc;


--continents with the highest death count per population.
select continent,max(cast(total_deaths as int)) AS highestdeathcounts
from dbo.CovidDeaths$
where continent is not null
group by continent
order by  highestdeathcounts desc;


--global number 
	select date,sum(new_cases) as newcases,sum(cast(new_deaths as int)) as newdeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage--,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
	from dbo.CovidDeaths$
	where continent is not null
	group by date
	order by 1 asc;

--death percentage
select sum(new_cases) as newcases,sum(cast(new_deaths as int)) as newdeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage--,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
	from dbo.CovidDeaths$
	where continent is not null
	order by 1 asc;

--join two tables for vaccination and death table for vaccination details


select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order) as RollingPeopleVaccinated
from dbo.CovidVaccinations$ cv
join dbo.CovidDeaths$ cd
	on
	cv.location=cd.location and cv.date=cd.date
	where cd.continent is not null
	order by 2,3;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From dbo.CovidDeaths$ dea
Join dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;


-- Using CTE to perform Calculation on Partition By in previous query using cast .

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast (vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From dbo.CovidDeaths$ dea
Join dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)

Select *, (RollingPeopleVaccinated/Population)*100 as percentage_vaccination
From PopvsVac;



-- Using CTE to perform Calculation on Partition By in previous query using convert

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From dbo.CovidDeaths$ dea
Join dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as percentage_vaccination
From PopvsVac;


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
Rollingpeoplevaccinated numeric)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From dbo.CovidDeaths$ dea
Join dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View percentagepopulation
as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From dbo.CovidDeaths$ dea
Join dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null )


select* from percentagepopulation;