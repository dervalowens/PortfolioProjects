/*
Covid 19 Data Explorations

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Views, COnverting Data Types

*/

select *
From CovidDeath
Where continent is not null
order by 3,4


--Select Data that we are going to be starting with 
Select location, date, total_cases , new_cases, total_deaths, population
From CovidDeath
order by 1, 2

--Looking at Total cases vs Total Deaths
--- Shows the likelihood of dying if you contract Covid in the United States

Select location, date, total_cases, total_deaths,(Total_deaths/total_cases)*100 as percentofpopulationinfected
From CovidDeath
Where location like '%states%'
order by 1, 2

--Looking at the Total cases vs population
--Shows what percentage of Population got covid
Select location,population, Max(Total_cases) as Highestinfectioncount, max(Total_cases/population)*100 as percentofpopulationinfected
from CovidDeath
--Where location like '%states%'
Group by location, population
order by percentofpopulationinfected desc
   
--Showing the countries with the highest death count per population

Select location, Max(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeath
--Where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc


-- Breaking things down by Continent 

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeath
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Let's break things down by Continent 


--This is showing continents with the highest death count per population

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeath
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select sum(new_cases)as total_cases, sum(cast(new_deaths as int)), SUM(cast(New_deaths as int))/Sum (new_cases)*100 as deathpercentage
From CovidDeath
--Where location like '%states%'
WHERE continent is not null
--Group by DATE
order by 1, 2


--LOOKING AT TOTAL POPULATION VS VACCINATIONS
--Shows Percentage of population that has received at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location, dea.Date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
From CovidDeath dea
Join CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3 


 --Use CTE to perform Calculation on Partition By previous query

 with popvsVac (continent, location, date, population, New_Vaccinations, rollingpeoplevaccinated)
 as
 (
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location, dea.Date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
From CovidDeath dea
Join CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3 
 )


 Select*,(rollingpeoplevaccinated/population)*100
 From popvsvac






---Using TEMP TABLE to perform calculation on partition by in previous query

 Drop table if exists #PercentPopulationVaccinated
 Create table #PercentPopulationvaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 date datetime,
 Population numeric,
 New_vaccinatioms numeric,
 Rollingpeoplevaccinated numeric
 )


 Insert into #PercentPopulationvaccinated
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location, dea.Date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
From CovidDeath dea
Join CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 --where dea.continent is not null
 --order by 2,3 
 
 Select*, (Rollingpeoplevaccinated/population)*100
 From #PercentPopulationvaccinated



 --Creating view to store data for later visualizations

 Create view percentpopulationvaccinated as
   Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location, dea.Date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
From CovidDeath dea
Join CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3 

 select*
 From percentpopulationvaccinated
 

 Create view TotalDeathcount as
 Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From CovidDeath dea
--Where location like '%states%'
where continent is not null
Group by continent
--order by TotalDeathCount desc

select*
from TotalDeathcount

Create view PercentofPopulationinfected as
Select location,population, Max(Total_cases) as Highestinfectioncount, max(Total_cases/population)*100 as percentofpopulationinfected
from CovidDeath
--Where location like '%states%'
Group by location, population
--order by percentofpopulationinfected desc

Select*
From PercentofPopulationinfected