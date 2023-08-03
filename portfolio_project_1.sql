CREATE DATABASE PortfolioProject_1;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths;

-- TOTAL DE CASOS VS TOTAL DE MUERTES
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100  AS deathpercentage 
FROM coviddeaths;

