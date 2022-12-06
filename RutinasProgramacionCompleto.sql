-----------------------------------------------------------------------------CONSULTAS--------------------------------------------------------------------------------------


----Kristhyan
--1.Dado un id de orden contractual, mostrar los bienes vinculadas a este.---kristhyan
select ocd.id_orden_c, oc.numero_factura_proveedor, b.nombre_bien, b.tipo 
from compras.orden_contractual_deta ocd
inner join compras.orden_contractual oc
	on oc.id_orden_c = ocd.id_orden_c
inner join compras.bien b 
	on ocd.id_bien = b.id_bien
where ocd.id_orden_c = $orden_contractual;


----Stephanie
--2.Dado un id_solicitud devolver la informaci�n de compra solicitud y al mismo tiempo los detalles---Stephanie
select * from compras.solicitud as S inner join compras.solicitud_deta as SD
ON S.id_solicitud=SD.id_solicitud WHERE S.id_solicitud=5;


----Gary
--3.Mostrar qu� bienes entran y c�mo se reparten a las diferentes �reas del almac�n y el id del empleado que lleva a cabo dicha acci�n

select b.nombre_bien , a.id_area , a.nombre_area , a.centro_costo, e.nombres_emp , e.id_area  from compras.bien b
inner join inventario.mov_bien mb on mb.id_bien = b.id_bien 
inner join rrhh.empleado e on e.id_emp =mb.id_emp 
inner join rrhh."area" a on a.id_area = e.id_area 
where e.id_area = a.id_area and mb.id_bien = b.id_bien
order by 1,2,3;








------------------------------------------------------------------PROCEDIMIENTOS ALMACENADOS Y DE MANTENIMIENTO-----------------------------------------------------------------

----Kristhyan
--1.Listar los centros de costo de los que un empleado es responsable
create or replace procedure listar_centros_costo_emp(idemp int)
as $$
declare
	cur cursor for select * from rrhh.responsable_centros_costo where id_emp = idemp;
	rec record;
	rec_area record;
	nombres rrhh.empleado.nombres_emp%type;
begin
	open cur;
	fetch cur into rec;
	select nombres_emp into nombres
		from rrhh.empleado
		where id_emp = rec.id_emp;
	
	raise notice '%', nombres;
	
	loop
		select * into rec_area
			from rrhh."area" a
		where a.id_area = rec.id_area;
	
		raise notice '% - %', rec_area.nombre_area, rec_area.centro_costo;
		fetch cur into rec;
		exit when not found;
	end loop;
	close cur;
end;
$$ LANGUAGE PLPGSQL;

call listar_centros_costo_emp(1);





--2.Mantenimiento de la tabla bienes


--DROP PROCEDURE insert_bien(character varying,real,character varying,compras.tipo_bien);
create or replace procedure insert_bien(nombre varchar(60), cant real, unidad varchar(30), tipp compras.tipo_bien )
as $$
declare
begin 
	insert into compras.bien
	values
		(default, nombre, can, unidad, tipp);
end;
$$ LANGUAGE PLPGSQL;

create or replace procedure delete_bien( idbien int )
as $$
declare
begin 
	delete from compras.bien where id_bien = idbien;
end;
$$ LANGUAGE PLPGSQL;

create or replace procedure update_bien(idbien int, nombre varchar(60), cant real, unidad varchar(30), tipp compras.tipo_bien )
as $$
declare
begin 
	update compras.bien
	set nombre_bien = nombre,
		cantidad = cant,
		unidad_medida = unidad,
		tipo = tipp
	where id_bien = idbien;
		
end;
$$ LANGUAGE PLPGSQL;



----Stephanie
--3.Imprimir los nombres de los jefes de �rea junto con el id y nombre del �rea.


create or replace procedure jefes_area(cod_empleado int)
language plpgsql
as $$
declare 
	rec record;
	rec2 record;
begin 

	SELECT 
	    E.nombres_emp, 
	    A.id_area, 
	    A.nombre_area,
	    E.id_jefe 
	    into strict rec
	FROM rrhh.empleado E
	INNER JOIN rrhh.area A 
	ON E.id_area=A.id_area
	WHERE E.id_emp=cod_empleado;

	raise notice 'Nombres			: %', rec.nombres_emp;
	raise notice 'ID Area			: %', rec.id_area;
	raise notice 'Nombre de area	: %', rec.nombre_area;
	raise notice 'ID Jefe			: %', rec.id_jefe;

	select * into strict rec2
	from rrhh.empleado e 
	where e.id_emp = rec.id_jefe;

	raise notice 'Jefe:			: %', rec2.nombres_emp;
	
end;
$$;


select * from rrhh.empleado;

 call jefes_ area (3);




--4.Todos los suministros que han sido comprados por un precio mayor a 1000 y agruparlos por �rea

create or replace procedure suministro_1000()
language plpgsql
as $$
declare
	cur cursor for select a.nombre_area, cd.id_orden_c, b.nombre_bien
		from compras.orden_contractual_deta cd
		inner join compras.bien b
			on b.id_bien = cd.id_bien
		inner join compras.solicitud s
			on s.id_solicitud  = cd.id_solicitud 
		inner join rrhh."area" a
			on a.id_area = s.id_centro_costo
		where (cd.cantidad*cd.valor_unitario) > 1000 and b.tipo = 'suministro';----
	rec record;
begin
	for rec in cur loop 
		raise notice 'Nombre bien:       %', rec.nombre_bien;
		raise notice 'Orden contractual: %', rec.id_orden_c;
		raise notice 'Area:              %', rec.nombre_area;	
	end loop;
end;
$$;

call suministro_1000();

----Gary
--5.Mostrar el responsable y la fecha de cada una de las solicitudes. Adem�s, mostrar el nombre y monto del rubro presupuestal respectivo.
--Paso 1: Consulta inicial
select s.responsable , s.fecha , s.fecha , rp.nombre ,rp.nombre  from compras.solicitud s 
inner join compras.solicitud_deta sd on sd.id_solicitud = s.id_solicitud 
inner join compras.rubro_presupuestal rp on rp.id_rp = s.id_rp 
where s.id_rp = rp.id_rp 
order by 1,2,3,4 desc 

--Paso 2: Agregandolo al procedimiento
create or replace procedure procedimiento_v1()
language plpgsql
as $$
DECLARE
    reg          RECORD;--Trabajamos con esta variable, que recibe los datos del cursor
    	cur_solicitud cursor for select s.responsable , s.fecha , s.fecha , rp.nombre , rp.monto  from compras.solicitud s 
															inner join compras.solicitud_deta sd on sd.id_solicitud = s.id_solicitud 
															inner join compras.rubro_presupuestal rp on rp.id_rp = s.id_rp 
															where s.id_rp = rp.id_rp 
															order by 1,2,3,4 desc ;
begin
   FOR rec IN cur_solicitud loop
	   RAISE NOTICE '% - % - % - % - %' , rec.responsable ,rec.fecha, rec.fecha , rec.nombre, rec.monto;
   end loop;
end; 
$$;

call procedimiento_v1();









6.Mantenimiento de la tabla proveedor



/*
 * INSERTAR PROVEEDOR
 */
select * from almacen.proveedor 
insert into almacen.proveedor values (default, '123', '1232 domicilio', '123razon_social');


create or replace procedure insert_proveedor_v2(nit varchar, domicilio varchar,razon_social varchar)
as $$
declare
begin 
	insert into almacen.proveedor values (default, nit, domicilio, razon_social);
end;
$$ LANGUAGE PLPGSQL;

call insert_proveedor_v2('123456','123 la salle', 'Prueba');

/*
 * ELEMINAR PROVEEDOR
 */


select * from compras.orden_contractual oc 

create or replace procedure delete_proveedor(
	delete_id_proveedor int
)
language plpgsql
as $$
begin
	delete from compras.orden_contractual where id_proveedor = delete_id_proveedor;--Eliminamos de la tabla que usa proveedor como FK
	delete from almacen.proveedor where id_proveedor  = delete_id_proveedor;--Eliminamos de la misma tabla proveedor

end; 
$$;

call delete_proveedor(20);
select * from almacen.proveedor p;
select * from compras.orden_contractual;

drop procedure delete_proveedor;
select * from almacen.proveedor 
/*
 * ACTUALIZAR PROVEEDOR
 */

select * from almacen.proveedor p 

create or replace procedure update_proveedor(
	upd_id_proveedor int,
	upd_nit varchar,
	upd_domicilio varchar,
	upd_razon_social varchar
)
language plpgsql
as $$
begin
	update almacen.proveedor 
	set nit  = upd_nit,
	    domicilio  = upd_domicilio,
	    razon_social = upd_razon_social
	where id_proveedor = upd_id_proveedor;
end; 
$$;

call update_proveedor(21,'ACTUALIZACION','EJEMPLO123','PRUEBA123') ;











-------------------------------------------------FUNCIONES PARA CALCULOS-----------------------------------------------------

----Kristhyan 
--1.Una funci�n que tome la funci�n anterior y devuelva el monto total que costar� una solicitud.
create or replace function calc_costo_total_soli(idsoli int)
returns real
as $$
declare
	total real;
	cur cursor for select * 
		from compras.solicitud_deta sd
		where sd.id_solicitud = idsoli;
	rec record;
begin
	total := 0;

	open cur;
	loop
		fetch cur into rec;
		exit when not found;
		--raise notice 'total: %', total;
		--raise notice 'cant: % - unitario: %', rec.cantidad, rec.valor_unitario;
		total := total + (rec.cantidad * rec.valor_unitario);
		--raise notice 'total fetch: %', total;
	end loop;
	close cur;
	--raise notice '%', total;
	return total;
end;
$$ language plpgsql;

select * from calc_costo_total_soli(4);


----Stephanie 
--2.Una funci�n que devuelva una lista de los bienes que fueron comprados a un determinado proveedor
create or replace function listaBienes(idproveedor_ int)
returns setof RECORD as $$
		SELECT PP.id_proveedor ID_PROV,
		PP.razon_social AS proveedor,
		B.nombre_bien as BIEN
		FROM almacen.Proveedor PP INNER JOIN compras.orden_contractual CC ON
		PP.id_proveedor=CC.id_proveedor INNER JOIN
		compras.orden_contractual_deta CD ON CC.id_orden_c=CD.id_orden_c
		INNER JOIN compras.bien B ON CD.id_bien=B.id_bien
		WHERE PP.id_proveedor=idproveedor_;
$$ LANGUAGE sql STABLE;

select * from listaBienes(4) as (id_proveedor int,razon_social varchar, nombre_bien varchar);


----Gary 
--3.Funci�n que devuelve el promedio de la cantidad de los bienes,  dada una de las �reas y su fecha de entrega. 

CREATE or replace FUNCTION funcion_calculo ( ) RETURNS
TABLE( promedio_cantidad int, nombre_area varchar , fecha_entrega date) AS
$$
select avg(b.cantidad), a.nombre_area , mb.fecha_entrega  from compras.bien b 
inner join inventario.mov_bien mb on mb.id_bien = b.id_bien 
inner join rrhh.area a on a.id_area = mb.id_area 
where b.id_bien = mb.id_bien and mb.id_area = a.id_area 
group by 2,3
order by 1,2,3;
$$ LANGUAGE sql

select * from funcion_calculo();






--------------------------------------------------------------------------------------------DETONADORES PARA CONTROL DE MODIFICACIONES---------------------------------
----kristhyan 
--1.Un detonador que vincule la entrada de almac�n con el inventario.
create or replace FUNCTION trigger_entrada_inventario() 
   RETURNS TRIGGER 
   LANGUAGE PLPGSQL
AS $$
declare
area_almacen int;
rec record;
begin
	select * into rec
		from compras.orden_contractual_deta cd 
		where cd.id_orden_cd = new.id_orden_cd;
	
	select a.id_area into area_almacen
		from rrhh."area" a 
		where nombre_area = 'almacen';

	insert into inventario.mov_bien
	values
		(default, rec.id_bien, null, now(), area_almacen, new.cantidad_entregada);
	
	return new;
END;
$$;

CREATE TRIGGER entrada_inventario
  BEFORE insert
  ON almacen.entrada
  FOR EACH ROW
  EXECUTE PROCEDURE trigger_entrada_inventario();






--2.Un detonador que se activa al momento que hay una salida de almac�n para realizar una inserci�n en la tabla de movimiento de bienes.

create or replace FUNCTION trigger_salida_update_inv() 
   RETURNS TRIGGER 
   LANGUAGE PLPGSQL
AS $$
declare
area_almacen int;
rec record;
id_cd int;
begin
	select a.id_area into area_almacen
		from rrhh."area" a 
		where nombre_area = 'almacen';
	
	select id_orden_cd into id_cd
		from almacen.entrada e
		where e.id_entrada = new.id_entrada;
	
	select * into rec
		from compras.orden_contractual_deta
		where id_orden_cd = id_cd;
	
	update inventario.mov_bien mb
		set cantidad = cantidad - new.cantidad
	where mb.id_area = area_almacen and mb.id_bien = rec.id_bien;

	insert into inventario.mov_bien
	values
		(default, 
		rec.id_bien, 
		new.empleado_responsable,
		new.fecha_entrega,
		new.id_area,
		new.cantidad);

	return new;
	
END;
$$;

CREATE TRIGGER update_inv_salida
  AFTER insert
  ON almacen.salida
  FOR EACH ROW
  EXECUTE PROCEDURE trigger_salida_update_inv();








----Stephanie
--3.Creaci�n de una tabla orden_contractual_log que se llenar� con un detonador cuando se inserta modifica o elimina un registro de la tabla hom�nima
CREATE table if not exists compras.orden_contractual_log(
	id_log serial not null primary key,
	id_orden_c int not null,
	id_proveedor int not null,
	autorizacion_director_financiero boolean,
	fecha_orden date,
	fecha_entrega date,
	numero_factura_proveedor varchar(20),
	
	via_de_envio varchar(30),
	metodo_de_envio varchar(30),
	condiciones_de_envio varchar(30),
	observaciones varchar(200),
	tipo_op varchar(20),
	update_date timestamp default CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION trigger_orden_contractual_log() RETURNS TRIGGER
AS $$
BEGIN

	IF (TG_OP = 'INSERT' or TG_OP = 'UPDATE') THEN
		INSERT INTO compras.orden_contractual_log 
		VALUES 
			(default,
			new.id_orden_c,
			new.id_proveedor,
			new.autorizacion_director_financiero,
			new.fecha_orden,
			new.fecha_entrega,
			new.numero_factura_proveedor,
			
			new.via_de_envio,
			new.metodo_de_envio,
			new.condiciones_de_envio,
			new.observaciones,
			TG_OP,
			CURRENT_TIMESTAMP);
		
		RETURN NEW;
	ELSIF (TG_OP = 'DELETE') THEN
		INSERT INTO compras.orden_contractual_log 
		VALUES 
			(default,
			old.id_orden_c,
			old.id_proveedor,
			old.autorizacion_director_financiero,
			old.fecha_orden,
			old.fecha_entrega,
			old.numero_factura_proveedor,
			
			old.via_de_envio,
			old.metodo_de_envio,
			old.condiciones_de_envio,
			old.observaciones,
			TG_OP,
			CURRENT_TIMESTAMP);
		return old;
	END IF;
	RETURN null;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER log_orden_contractual
AFTER INSERT OR UPDATE OR DELETE ON compras.orden_contractual
FOR EACH ROW EXECUTE PROCEDURE trigger_orden_contractual_log();

insert into compras.orden_contractual
values
	(default, 3, default, default, null, 'boleta nueva', null, null, null, null);

----Gary
--4.Creaci�n de una tabla log_proveedor que se llenar� con un detonador cuando se inserta, actualiza o elimina un registro.
CREATE TABLE almacen.log_proveedor /* Tabla LOG de proveedores */
(
   id_proveedor     INT,
   nit     VARCHAR(20),
   domicilio  VARCHAR(60),
   razon_social  VARCHAR(30),
   /* Indicaremos que operacion se ejecuta */
   log_movimiento  VARCHAR(10),
   log_fecha_mov   timestamp
);


/* PARTE 1 : CREAR LA FUNCION DE TRIGGER :
   USAR� LA VARIABLE TG_OP PARA CAPTURAR EL EVENTO A EJECUTAR */
CREATE OR REPLACE FUNCTION tg_log_proveedor() RETURNS TRIGGER AS
$BODY$
BEGIN
    IF (TG_OP='INSERT' OR TG_OP='UPDATE') THEN
        INSERT INTO almacen.log_proveedor
        ( id_proveedor, nit, domicilio,
          razon_social, log_movimiento, log_fecha_mov )
        VALUES /* Registramos en Log los valores nuevos */
        ( NEW.id_proveedor, NEW.nit, NEW.domicilio,
          NEW.razon_social, TG_OP, CURRENT_TIMESTAMP );
        RETURN NEW;
    END IF;
    IF (TG_OP='DELETE') THEN
        INSERT INTO almacen.log_proveedor
        ( id_proveedor, nit, domicilio,
          razon_social, log_movimiento, log_fecha_mov )
    VALUES /* Registramos en Log los valores eliminados */
        ( OLD.id_proveedor, OLD.nit, OLD.domicilio,
          OLD.razon_social, TG_OP, CURRENT_TIMESTAMP );
    RETURN OLD;
    END IF;
END;
$BODY$ LANGUAGE 'plpgsql';


/* PARTE 2 : CREA EL TRIGGER VINCULADO A LA TABLA Y FUNCION */
CREATE TRIGGER tg_log AFTER INSERT OR UPDATE OR DELETE
ON  almacen.proveedor FOR EACH ROW EXECUTE PROCEDURE tg_log_proveedor()

select * from almacen.proveedor p;
select * from almacen.log_proveedor p;







-----------------------------------------------------------------------DETONADORES PARA AUDITORIA DE TABLAS TRANSACCIONALES------------------------------------------------------------------------
----Kristhyan 
--1.Creaci�n de un loog para la tabla responsable_centros_costo

create or replace FUNCTION trigger_log_responsable_centros_costo() 
   RETURNS TRIGGER 
   LANGUAGE PLPGSQL
AS $$
BEGIN
	IF (TG_OP='INSERT' OR TG_OP='UPDATE') THEN
        INSERT INTO rrhh.log_responsable_centros_costo
        VALUES /* Registramos en Log los valores nuevos */
		( default,
		NEW.id_emp,
		NEW.id_area,
		TG_OP,
		CURRENT_TIMESTAMP );
        RETURN NEW;
    END IF;
    IF (TG_OP='DELETE') THEN
        INSERT INTO rrhh.log_responsable_centros_costo
    VALUES /* Registramos en Log los valores eliminados */
		( default,
		OLD.id_emp,
		OLD.id_area,
		TG_OP,
		CURRENT_TIMESTAMP );
		RETURN OLD;
    END IF;
END;
$$;

CREATE TRIGGER log_responsable_centros_costo
  AFTER INSERT OR UPDATE OR DELETE
  ON rrhh.responsable_centros_costo
  FOR EACH ROW
  EXECUTE PROCEDURE trigger_log_responsable_centros_costo();




----Stephanie
--2.Creaci�n de una tabla solicitud_deta_log que se llenar� con un detonador cuando se inserta, modifica o elimina un registro de la tabla.hom�nima
CREATE table if not exists compras.solicitud_deta_log(
	id_log serial not null primary key,
	id_solicitud int,
	id_bien int,
	cantidad real,
	valor_unitario real,
	tipo_op varchar(20),
	update_date timestamp default CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION trigger_solicitud_deta_log() RETURNS
TRIGGER AS $$
BEGIN

	IF (TG_OP='INSERT' OR TG_OP='UPDATE') THEN
        INSERT INTO compras.solicitud_deta_log
        VALUES
			( default,
			new.id_solicitud,
			new.id_bien,
			new.cantidad,
			new.valor_unitario,
			TG_OP,
			CURRENT_TIMESTAMP);
        RETURN NEW;
    END IF;
    IF (TG_OP='DELETE') THEN
        INSERT INTO compras.solicitud_deta_log
        VALUES
			( default,
			old.id_solicitud,
			old.id_bien,
			old.cantidad,
			old.valor_unitario,
			TG_OP,
			CURRENT_TIMESTAMP);
		RETURN OLD;
    END IF;
	
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER solicitud_deta_log
AFTER INSERT OR UPDATE OR DELETE ON compras.solicitud_deta
FOR EACH ROW EXECUTE PROCEDURE trigger_solicitud_deta_log();

insert into compras.solicitud_deta
values
	(2,14,9999,666);

update compras.solicitud_deta
	set valor_unitario = 777
where id_solicitud = 2 and id_bien = 14;




----------------------------------------------REPORTES CON CURSORES SIMPLES--------------------------------------------------------
----Kristhyan 
--1.Reporte que dado un mismo bien mostrar su informaci�n (nombre, tipo, etc) a qu� ordenes contractuales est� vinculada, las entradas de almacen que se efectuaron para ese bien,
--as� como la ubicaci�n actual de la distribuci�n de ese bien.

create or replace procedure compras.reporte_bien(idbien int)
as $$
declare
	cur cursor for select b.nombre_bien, b.unidad_medida, b.tipo, ocd.id_orden_c, e.id_entrada, a.nombre_area
		from compras.bien b
		inner join compras.orden_contractual_deta ocd
			on b.id_bien = ocd.id_bien
		inner join almacen.entrada e 
			on e.id_orden_cd = ocd.id_orden_cd
		inner join inventario.mov_bien mb
			on mb.id_bien = b.id_bien
		inner join rrhh."area" a
			on a.id_area = mb.id_area 
		where b.id_bien = idbien;
	rec record;
begin
	open cur;
	fetch cur into rec;
	raise notice 'Nombre:			%', rec.nombre_bien;
	raise notice 'Unidad medida:	%', rec.unidad_medida;
	raise notice 'Tipo:			%', rec.tipo;
	
	raise notice 'Orden compra:	%', rec.id_orden_c;
	raise notice 'Entrada:		%', rec.id_entrada;
	raise notice 'Area:			%', rec.nombre_area;
	
	loop
		
		fetch cur into rec;
		exit when not found;
		
		raise notice 'Orden compra:	%', rec.id_orden_c;
		raise notice 'Entrada:		%', rec.id_entrada;
		raise notice 'Area:			%', rec.nombre_area;
	end loop;	
end;
$$ language plpgsql;

call compras.reporte_bien(2);





----Stephanie 
--3.Cursorr para obtener el total de cada producto junto con su id, de una orden de compra.
create or replace procedure total_bien_orden_c(idbien int)
as $$
declare
	cur cursor for select b.nombre_bien, cd.id_orden_c, cd.cantidad, cd.valor_unitario
		from compras.orden_contractual_deta cd
		inner join compras.bien b
			on b.id_bien = cd.id_bien
		where cd.id_bien = idbien;
	rec record;   --cada fila se guarda en un registro
begin
	--for rec in cur loop
	open cur;
	fetch cur into rec;  --introduce las siguiente fila en el registro
	raise notice 'Nombre del bien: %', rec.nombre_bien;
	loop   --hacemos un bucle
		raise notice 'Orden de compra: %', rec.id_orden_c;
		raise notice 'Total:           %', (rec.cantidad * rec.valor_unitario);
		fetch cur into rec;
		exit when not found; --si no hay una fila en el registro, sale
	end loop;
	close cur;
end;
$$ language plpgsql;

call total_bien_orden_c(3);


----Gary    
--4.Reporte que muestre la fecha de salida, fecha de entrega y el id del empleado responsable de cada salida aprobada.

--Consulta inicial
select s.fecha_salida , s.fecha_entrega , e.nombres_emp  , s.empleado_responsable, s.id_salida  from almacen.salida s
inner join rrhh.empleado e on s.empleado_responsable = e.id_emp 
inner join rrhh.area a on a.id_area = e.id_area  
where e.id_emp = s.empleado_responsable and e.id_emp = a.id_area 
order by 1,2,3 asc


create or replace procedure cursor_siemple_uno()
as $$
declare
	rec record;
begin
	for rec in select s.fecha_salida , s.fecha_entrega , e.nombres_emp  , s.empleado_responsable, s.id_salida  from almacen.salida s
				inner join rrhh.empleado e on s.empleado_responsable = e.id_emp 
				inner join rrhh."area" a on a.id_area = e.id_area  
				where e.id_emp = s.empleado_responsable and e.id_emp = a.id_area 
	loop 
	raise notice '% - % - % - % -%', rec.fecha_salida, rec.fecha_entrega, rec.nombres_emp, rec.empleado_responsable, rec.id_salida;
	end loop;
end;
$$language plpgsql

call cursor_siemple_uno();






-----------------------------------------------REPORTES CON CURSORES ANIDADOS------------------------------------------------------
----Kristhyan:
--1.Dado un rango de n�meros de solicitud, hacer un reporte de todas las �rdenes contractuales junto con los bienes de esa orden.
create or replace procedure datos_range_soli(ini int, fin int)
as $$
declare
	tem int;
	rec record;
	rec2 record;
begin
	if ini > fin then
		tem := ini;
		ini := fin;
		fin := tem;
	end if;

	tem := ini;

	FOR rec in
	SELECT *
	FROM compras.orden_contractual_deta ocd
	where ocd.id_solicitud = tem
	loop
		if tem > fin then 
			exit;
		end if;
		raise notice 'Orden contractual: %', rec.id_orden_c;
	
		for rec2 in
		select nombre_bien
		from compras.bien b
		where b.id_bien = rec.id_bien
		loop 
			raise notice 'Bien: %', rec2.nombre_bien;
		end loop;
		tem := tem + 1;
	END LOOP;
end;
$$ language plpgsql;

call datos_range_soli(2,2);


----Gary
--2.Reporte que muestre el id, nombre y cargo del empleado seg�n el �rea que corresponda, en la cual se mostrar� el nombre de dicha �rea y su id.

---PRIMER CURSOR 
select e.id_emp , e.nombres_emp , e.cargo  from rrhh.empleado e 

create or replace function reporte_empleado()
 RETURNS VOID as 
$BODY$
declare
    cur_report1 cursor for select e.id_emp , e.nombres_emp , e.cargo  from rrhh.empleado e ;
	rec   record; 
begin
   FOR rec IN cur_report1 LOOP
       RAISE NOTICE 'ID % - NOMBRE % - CARGO %', rec.id_emp , rec.nombres_emp , rec.cargo;
   END LOOP ;
   RETURN;
end;
$BODY$
language plpgsql;
select * from reporte_empleado();


--- SEGUNDO CURSOR
select a.id_area ,a.nombre_area  from rrhh."area" a inner join rrhh.empleado e on e.id_area = a.id_area where e.id_area =a.id_area  
create or replace function reporte_area()
 RETURNS VOID as 
$BODY$
declare
    cur_report2 cursor for select a.id_area ,a.nombre_area  from rrhh."area" a inner join rrhh.empleado e 
    					   on e.id_area = a.id_area where e.id_area =a.id_area;
	rec2   record; 
begin
   FOR rec2 IN cur_report2 LOOP
       RAISE NOTICE 'ID AREA  % - NOMBRE AREA % ', rec2.id_area ,rec2.nombre_area;
   END LOOP ;
   RETURN;
end;
$BODY$
language plpgsql;
select * from reporte_area();

--- ENSAMBLE
create or replace function reporte_area_empleado()
 RETURNS VOID as 
$BODY$
declare
    cur_report1 cursor for select e.id_emp , e.nombres_emp , e.cargo , e.id_area  from rrhh.empleado e ;
	rec   record; 
begin
	   FOR rec IN cur_report1 LOOP
	       RAISE NOTICE 'ID % - NOMBRE % - CARGO % - ID_AREA %', rec.id_emp , rec.nombres_emp , rec.cargo , rec.id_area;
	    --2DO CURSOR
        declare
	    cur_report2 cursor for select a.id_area ,a.nombre_area  from rrhh."area" a inner join rrhh.empleado e 
	    					   on e.id_area = a.id_area where e.id_area = rec.id_area;
		rec2   record; 
		begin
	    FOR rec2 IN cur_report2 LOOP
	       RAISE NOTICE 'ID AREA  % - NOMBRE AREA % ', rec2.id_area ,rec2.nombre_area;
		   END LOOP ;
		   RETURN;
		end;
       -- FIN 2DO CURSOR
      END LOOP ;
   RETURN;
end;
$BODY$
language plpgsql;

select * from reporte_area_empleado();