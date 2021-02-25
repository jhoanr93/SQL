/** @Jhoan R - Colombia **/
/* LIBROS */
/*Obtener todos los libros escritos por autores que cuenten con un seudónimo*/
SELECT titulo, autor_id
FROM libros
WHERE autor_id IN(
	 SELECT autor_id 
	 FROM autores
	 WHERE seudonimo IS NULL);

/* Obtener el título de todos los libros publicados en el año actual cuyos autores poseen un pseudónimo */
SET @year = YEAR(NOW());

SELECT  autor_id, titulo, fecha_publicacion
FROM libros
WHERE autor_id IN(
	 SELECT autor_id 
	 FROM autores
	 WHERE seudonimo IS NOT NULL) AND YEAR(fecha_publicacion) = @year;

/* Obtener todos los libros escritos por autores que cuenten con un seudónimo y que hayan nacido ante de 1965.*/
SELECT  autor_id, titulo, fecha_publicacion
FROM libros
WHERE autor_id IN(
	 SELECT autor_id 
	 FROM autores
	 WHERE seudonimo IS NOT NULL AND YEAR (fecha_nacimiento) < YEAR ('1965-01-01'));

/* Colocar el mensaje no disponible a la columna descripción, en todos los libros publicados antes del año 2000 */
UPDATE libros SET descripcion = 'no disponible' WHERE YEAR(fecha_publicacion) < YEAR('2000-01-01') ;

/* Obtener la llave primaria de todos los libros cuya descripción sea diferente de no disponible.*/
SELECT libro_id FROM libros WHERE descripcion != 'no disponible';

/* Obtener el título de los últimos 3 libros escritos por el autor con id 2 --> (11). */
SELECT titulo FROM libros WHERE autor_id = 11 ORDER BY fecha_creacion DESC LIMIT 3;

/* Obtener en un mismo resultado la cantidad de libros escritos por autores con seudónimo y sin seudónimo. */
select (
	select count(*) from libros where autor_id in 
		(select autor_id from autores where seudonimo is null)) as sin_seudonimo,
	(select count(*) from libros where autor_id in 
		(select autor_id from autores where seudonimo is not null)) as con_seudonimo;

/* Obtener la cantidad de libros publicados entre enero del año 2000 y enero del año 2005. --> (Enero 1995 - Enero 2000)*/
SELECT * FROM libros WHERE fecha_publicacion BETWEEN '1995-01-01' AND '2000-01-01';

Obtener el título y el número de ventas de los cinco libros más vendidos.
SELECT titulo, ventas FROM libros ORDER BY ventas DESC LIMIT 5;

/* Obtener el título y el número de ventas de los cinco libros más vendidos de los ultimos 100 años.*/
SELECT titulo, ventas FROM libros WHERE fecha_publicacion BETWEEN ('1920-01-01') AND ('2020-01-01') ORDER BY ventas DESC LIMIT 5;

/*Obtener la cantidad de libros vendidos por los autores con id 1, 2 y 3 -> (7,8,9)
Ejemplo
autor	ventas
1	10
2	20
3	30
*/
SELECT autor_id, SUM(ventas) AS total FROM libros GROUP BY autor_id HAVING autor_id < 10;

/*Obtener el título del libro con más páginas.*/
SELECT titulo, paginas FROM libros ORDER BY paginas DESC LIMIT 1;

/*Obtener todos los libros cuyo título comience con la palabra “La”.*/
SELECT * FROM libros WHERE titulo LIKE 'la%';

/*Obtener todos los libros cuyo título comience con la palabra “La” y termine con la letra “a”.*/
SELECT * FROM libros WHERE titulo LIKE 'la%' AND titulo LIKE '%a';


/*Establecer el stock en cero a todos los libros publicados antes del año de 1995*/
UPDATE libros SET stock = 0 
WHERE fecha_publicacion < '1995-01-01';

/*Mostrar el mensaje Disponible si el libro con id 1 (id -> 7) posee más de 5 ejemplares en stock, en caso contrario mostrar el mensaje No disponible.*/
SELECT IF(stock > 5, 'Disponible', 'No Disponible') as stock
FROM libros
WHERE libro_id = 7;


/*Obtener el título los libros ordenador por fecha de publicación del más reciente al más viejo.*/
SELECT titulo
FROM libros
    ORDER BY fecha_publicacion DESC;


/*AUTORES*/
/*Obtener el nombre de los autores cuya fecha de nacimiento sea posterior a 1950*/
SELECT nombre FROM autores WHERE YEAR(fecha_nacimiento) > YEAR('1950-12-31');

/* Obtener la el nombre completo y la edad de todos los autores */
/* UPDATE fecha_nacimiento='1837-05-01' FROM autores WHERE nombre='Jorge'; */
SET @now = NOW();
SELECT CONCAT(nombre, " ", apellido) AS nombre_autor, YEAR(@now) - YEAR(fecha_nacimiento) AS edad FROM autores;

/*Obtener el nombre completo de todos los autores cuyo último libro publicado sea posterior al 2005*/
select * from autores where autor_id in 
		(select autor_id from libros where YEAR(fecha_publicacion) > YEAR('2005-01-01'));

/*Obtener el id de todos los escritores cuyas ventas en sus libros superen el promedio.*/
SET @prom_ventas = (SELECT AVG(ventas) FROM libros);
SELECT @prom_ventas AS promedio_ventas;
SELECT autor_id, ventas AS total FROM libros GROUP BY autor_id HAVING ventas > @prom_ventas;

/*Obtener el id de todos los escritores cuyas ventas en sus libros sean mayores a cien mil ejemplares "mayores a 500"*/
SELECT autor_id, SUM(ventas) AS total FROM libros GROUP BY autor_id HAVING SUM(ventas) >500;

/* FUNCIONES */
/* Crear una función la cual nos permita saber si un libro es candidato a préstamo o no. Retornar “Disponible” si el libro posee por lo menos un ejemplar en stock, en caso contrario retornar “No disponible.” */
ALTER TABLE libros ADD stock INT;

/* Funcion cantidad de ventas aleatorio */
/* Crear funciones */
DELIMITER //

CREATE FUNCTION obtener_stock()
RETURNS INT
BEGIN
	SET @stock = (SELECT FLOOR(0 + (RAND() * 11)));
	RETURN @stock;


END//

DELIMITER ;

/* Actualizar los registros de libros con stock aleatorio */
UPDATE libros SET stock = obtener_stock();

/* Funcion disponible, no disponible */
DELIMITER //


CREATE FUNCTION obtener_disponibilidad()
RETURNS VARCHAR(50)
BEGIN
	SET @disponible = (SELECT IF(stock = 0, "no disponible", "disponible") FROM libros);
	RETURN @disponible;


END//

DELIMITER ;
