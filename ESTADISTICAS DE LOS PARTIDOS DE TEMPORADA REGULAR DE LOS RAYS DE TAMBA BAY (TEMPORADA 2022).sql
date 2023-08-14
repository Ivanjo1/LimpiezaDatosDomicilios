
-- BASE DE DATOS CON LAS ESTADISTICAS DE LOS PARTIDOS DE TEMPORADA REGULAR DE LOS RAYS DE TAMBA BAY (TEMPORADA 2022)

USE PortfolioProject_3

SELECT *
FROM LastPitchRays

-- 1. ANALISIS DEL PROMEDIO EN LANZAMIENTOS (Pitcheos) POR TURNO AL BATE

--  LANZAMIENTOS PROMEDIO POR TURNO AL BATE

SELECT AVG(1.00 * pitch_number) AS AvgPitchesPerAtBat
FROM LastPitchRays

-- LANZAMIENTOS PROMEDIO POR TURNO AL BATE LOCAL VS VISITANTE (filas)

SELECT 'Home' TypeofGame, AVG(1.00 * pitch_number) AS AvgPitchesPerAtBat
FROM LastPitchRays
WHERE home_team = 'TB'
UNION
SELECT 'Away' TypeofGame, AVG(1.00 * pitch_number) AS AvgPitchesPerAtBat
FROM LastPitchRays
WHERE away_team = 'TB'

-- LANZAMIENTOS PROMEDIO POR TURNO AL BATE DIESTRO VS ZURDO (columnas)

SELECT 
      AVG(CASE WHEN batter_position = 'L' THEN  1.00 * pitch_number END) AS LeftyAtBats,
	  AVG(CASE WHEN batter_position = 'R' THEN  1.00 * pitch_number END) AS RightyAtBats
FROM LastPitchRays

-- LANZAMIENTOS PROMEDIO POR TURNO AL BATE DIESTRO VS ZURDO | JUEGOS DE VISITA

SELECT DISTINCT
home_team, pitcher_position, AVG(1.00 * pitch_number) OVER (PARTITION BY home_team, pitcher_position) 
FROM LastPitchRays
WHERE away_team = 'TB'

-- los tres lanzamientos más comunes para los turnos al bate del 1 al 10 y la cantidad total

WITH TotalPitchSequence AS (
  SELECT DISTINCT
  pitch_name, pitch_number, COUNT(pitch_name) OVER (PARTITION BY pitch_name, pitch_number) AS PitchNumbers  
  FROM LastPitchRays
  WHERE pitch_number < 11
)
SELECT *
FROM TotalPitchSequence

