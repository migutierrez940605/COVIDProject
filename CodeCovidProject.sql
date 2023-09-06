

Select * 
From COVIDProject.dbo.COVIDDeaths
Order by 3,4

--Select * 
--From COVIDProject.dbo.COVIDVaccinations
--Order by 3,4

--Select the Data that I am going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From COVIDProject.dbo.COVIDDeaths
Where continent is not null
order by 1,2

---Looking at Total Cases vs Totals Deaths in United States
---Shows likelihood of dying if you contract covid in your country or more specifically USA 
Select location, date, total_cases, total_deaths , 
(cast(total_deaths as float(20))/cast(total_cases as float(20))) *100 as DeathsPercentage
From COVIDProject.dbo.COVIDDeaths
Where location like '%states'
order by 1,2

---Looking at Total Cases vs Populations in United States
----Shows what percentege of populations got covid
Select location, date, total_cases, population , 
(cast(total_cases as float(20))/population) *100 as InfectedPercentage
From COVIDProject.dbo.COVIDDeaths
Where continent is not null
Where location like '%states'
order by 1,2

---Looking at counties with Highest infection rate compared to populations
Select location, population, Max(cast(total_cases as float)) as HighestInfectionCount, MAX((cast(total_cases as float(20))/population)) * 100 as PopulationPercentageInfected
From COVIDProject.dbo.COVIDDeaths
Where continent is not null
Group by location, population
order by PopulationPercentageInfected desc

---Showings Countries with Highest Death Count per Population
--Select location, population,  Max(cast(total_deaths as int)) as HighestDeathCount, 
--Max((cast(total_deaths as int)/population)) *100 as HighestDeathsPercentage
--From COVIDProject.dbo.COVIDDeaths
--where continent is not null 
--group by location, population
--order by HighestDeathsPercentage desc

Select location,  Max(cast(total_deaths as int)) as HighestDeathCount 
From COVIDProject.dbo.COVIDDeaths
where continent is not null
group by location
order by HighestDeathCount desc

---Let's Break Things Down by Continent 
---Showings continents with the highest death count per population

Select continent,  Max(cast(total_deaths as int)) as TotalDeathCount 
From COVIDProject.dbo.COVIDDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

---Global Numbers 
Select Sum(cast(new_cases as int)) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeath, 
Sum(cast(new_deaths as int))/Sum(cast(new_cases as int))*100  as DeathPercentage
From COVIDProject.dbo.COVIDDeaths
Where continent is not null
order by 1,2

---Looking at Population vs Vaccinations
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
Sum(Convert(float,vacc.new_vaccinations)) 
Over (Partition by deaths.location order by deaths.location, deaths.date)
as RollingPeopleVaccinated
From COVIDProject.dbo.COVIDDeaths deaths
join COVIDProject.dbo.COVIDVaccinations  vacc
      on deaths.location=vacc.location and
         deaths.date=vacc.date
Where deaths.continent is not null
order by 2,3


---Use CTE

With PopvsVac (Continent, Location, Date, Population,Vaccinations, RollingPeopleVaccinated)
as (
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
Sum(Convert(float,vacc.new_vaccinations)) 
Over (Partition by deaths.location order by deaths.location, deaths.date)
as RollingPeopleVaccinated
From COVIDProject.dbo.COVIDDeaths deaths
join COVIDProject.dbo.COVIDVaccinations  vacc
      on deaths.location=vacc.location and
         deaths.date=vacc.date
Where deaths.continent is not null
)
Select *
From PopvsVac

---Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated  numeric
)

Insert into #PercentPopulationVaccinated
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
Sum(Convert(float,vacc.new_vaccinations)) 
Over (Partition by deaths.location order by deaths.location, deaths.date)
as RollingPeopleVaccinated
From COVIDProject.dbo.COVIDDeaths deaths
join COVIDProject.dbo.COVIDVaccinations  vacc
      on deaths.location=vacc.location and
         deaths.date=vacc.date

--Where deaths.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


---Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as 
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
Sum(Convert(float,vacc.new_vaccinations)) 
Over (Partition by deaths.location order by deaths.location, deaths.date)
as RollingPeopleVaccinated
From COVIDProject.dbo.COVIDDeaths deaths
join COVIDProject.dbo.COVIDVaccinations  vacc
      on deaths.location=vacc.location and
         deaths.date=vacc.date
Where deaths.continent is not null

Select *
From PercentPopulationVaccinated