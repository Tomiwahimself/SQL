
--SELECT *
--FROM PortfolioProject..CovidDeaths$
--order by 3,4 


--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--order by 3,4 

--Selecting the Data Needed

--SELECT location,date, total_cases, new_cases,total_deaths, population 
--FROM PortfolioProject..CovidDeaths$
--order by 1,2  

--Looking at Total Cases vs Total Deaths
--This shows  the likehood to contact the covid virus in the United States
SELECT location,date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2

---- Showing the percentage population that got the virus
SELECT location,date, total_cases,total_deaths, (total_cases/population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
Where location like '%Nigeria%'
order by 1,2

---- Finding the countries with the higest infection rate compared to population
--SELECT location,max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as PercentPopulationInfected
--FROM PortfolioProject..CovidDeaths$
--Group by location, population
--order by PercentPopulationInfected desc

-- Finding Highest death count per population

SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
Group by location
order by TotalDeathCount desc


-- The script above groups the entire data including the world which is not a contry and asia which is a continent so the code below solves this problem 
SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
Where continent is not null
Group by location
order by TotalDeathCount desc

-- Analysing the dataset with respect to different continents
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
where continent is not null
Group by continent 
order by TotalDeathCount desc 


--SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
--FROM PortfolioProject..CovidDeaths$
--where continent is null
--Group by location
--order by TotalDeathCount desc 

--Global Numbers 
SELECT date,sum(new_cases)as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage--, total_cases,total_deaths, (total_cases/population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--Where location like '%Nigeria%'
where continent is not null
group by date
order by 1,2  

--Total cases 
SELECT sum(new_cases)as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage--, total_cases,total_deaths, (total_cases/population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--Where location like '%Nigeria%'
where continent is not null
order by 1,2  

-- Using the Covid Vaccination Table to do a descriptive analysis on what happened during the pandemic

-- Joining the Deaths and Vaccination Table to start analysis
SELECT * 
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date  = vac.date


--Finding theTotal Popluation vs Vaccinations 
SELECT  dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date  = vac.date
WHERE dea.continent is not null
order by 2,3 



--Vaccination Rolling Count according to locations
SELECT  dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int )) OVER (Partition by dea.location Order by dea.location,dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date  = vac.date
WHERE dea.continent is not null
order by 2,3 



-- Using CTE 
With PopulationvsVac (Continent, Location, Date , Population, RollingPeopleVaccinated,New_Vaccination)
as
(
SELECT  dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int )) OVER (Partition by dea.location Order by dea.location,dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date  = vac.date
--WHERE dea.continent is not null
 )  

 SELECT *, (RollingPeopleVaccinated/Population)*100
 FROM PopulationvsVac



--Using TEMP TABLE

Drop Table if exists #Percent
CREATE Table #PercentPopulationVac
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVac
SELECT  dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int )) OVER (Partition by dea.location Order by dea.location,dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date  = vac.date
--WHERE dea.continent is not null 
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVac


-- Creating View to store data For Visualisation 
Create View PercentPopulationVac as 
SELECT  dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int )) OVER (Partition by dea.location Order by dea.location,dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date  = vac.date
WHERE dea.continent is not null

SELECT * 
FROM #PercentPopulationVac