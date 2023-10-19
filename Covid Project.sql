Select * From CovidDeaths

Select * 
From CovidDeaths
Where continent is not NULL
Order by 3, 4 

Select * 
From CovidVaccinations
Order by 3, 4 

-- Select Data that we are going to be using 

Select Location, Date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, Date, total_cases, total_deaths, (total_deaths * 1.0/total_cases) * 100 as DeathPercentage
From CovidDeaths
Where Location Like '%states%'
Order by 1, 2

-- Looking at Total Cases vs Population
--Shows what percentage of population got Covid

Select Location, Date, Population, total_cases, (total_cases * 1.0/population) * 100 as PercentPopulationInfected
From CovidDeaths
-- Where Location Like '%states%'
Order by 1, 2

-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases * 1.0/population)) * 100 as PercentPopulationInfected 
From CovidDeaths
Group By Location, Population
Order By PercentPopulationInfected DESC

-- Showing Countries with the Highest Death Count per Population

Select Location, MAX(total_deaths) as TotalDeathCount
From CovidDeaths
Where continent is not Null
Group By Location
Order By TotalDeathCount DESC

--Let's break things down by Continent

Select Location, MAX(total_deaths) as TotalDeathCount
From CovidDeaths
Where continent is Null
Group By Location
Order By TotalDeathCount DESC

-- Showing continents with the highest death count per population

Select Continent, MAX(total_deaths) as TotalDeathCount
From CovidDeaths
Where continent is Null
Group By Continent
Order By TotalDeathCount DESC

-- Global Numbers

Select Date, Sum(new_cases) as total_cases, Sum(new_deaths) as total_deaths, Sum(1.0 * new_deaths)/Sum(new_cases) * 100 as DeathPercentage
From CovidDeaths
Where Continent is not NULL
Group By Date
Order by 1, 2

Select Sum(new_cases) as total_cases, Sum(new_deaths) as total_deaths, Sum(1.0 * new_deaths)/Sum(new_cases) * 100 as DeathPercentage
From CovidDeaths
Where Continent is not NULL
Order by 1, 2

-- Looking at Total Population vs Vaccination

Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
Sum(vac.new_vaccinations) OVER (Partition by Dea.location Order by Dea.location, dea.date) as RollingPeopleVaccinated,
-- (RollingPeopleVaccinated/population) * 100
From CovidDeaths Dea
Join CovidVaccinations Vac
     ON Dea.location = Vac.location
     AND Dea.date = Vac.date
Where Dea.Continent is not Null
Order by 2, 3

-- USE CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
Sum(vac.new_vaccinations) OVER (Partition by Dea.location Order by Dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population) * 100
From CovidDeaths Dea
Join CovidVaccinations Vac
     ON Dea.location = Vac.location
     AND Dea.date = Vac.date
Where Dea.Continent is not Null
-- Order by 2, 3
)

Select * , (RollingPeopleVaccinated * 1.0/Population) * 100
From PopvsVac

-- TEMP Table

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent varchar(50),
Location varchar(50),
Date date,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated NUMERIC    
)

Insert into #PercentPopulationVaccinated
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
Sum(vac.new_vaccinations) OVER (Partition by Dea.location Order by Dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population) * 100
From CovidDeaths Dea
Join CovidVaccinations Vac
     ON Dea.location = Vac.location
     AND Dea.date = Vac.date
-- Order by 2, 3

Select * , (RollingPeopleVaccinated * 1.0/Population) * 100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualization

CREATE VIEW PercentPopulationVaccinated as 
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
Sum(vac.new_vaccinations) OVER (Partition by Dea.location Order by Dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population) * 100
From CovidDeaths Dea
Join CovidVaccinations Vac
     ON Dea.location = Vac.location
     AND Dea.date = Vac.date
-- Order by 2, 3

Select *
From PercentPopulationVaccinated
