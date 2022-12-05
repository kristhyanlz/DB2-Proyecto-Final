--Rutinas de programación

--Mantenimiento de la tabla bienes
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

--Dado un ID de orden contractual, mostrar los bienes vinculadas a este.

select ocd.id_orden_c, oc.numero_factura_proveedor, b.nombre_bien, b.tipo 
from compras.orden_contractual_deta ocd
inner join compras.orden_contractual oc
	on oc.id_orden_c = ocd.id_orden_c
inner join compras.bien b 
	on ocd.id_bien = b.id_bien
where ocd.id_orden_c = $orden_contractual;

--PROCEDIMIENTO
--Listar los centros de costo de los que un empleado es responsable

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


------------------------

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


create table if not exists rrhh.log_responsable_centros_costo(
	id_log serial not null primary key,
	id_emp int not null references rrhh.empleado,
	id_area int not null references rrhh."area",
	accion varchar(20),
	fecha timestamp
);
---- ##########################
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

-------------

select e.nombres_emp, count(a.centro_costo) as n_centros_costo
	from  rrhh.empleado e
	inner join rrhh.responsable_centros_costo rcc 
		on rcc.id_emp = e.id_emp
	inner join public."area" a
		on a.id_area = rcc.id_area
	group by e.nombres_emp;

select oc.fecha_orden, b.nombre_bien, b.cantidad
	from compras.orden_contractual oc 
	inner join compras.orden_contractual_deta ocd 
		on oc.id_orden_c = ocd.id_orden_c
	inner join compras.bien b
		on b.id_bien = ocd.id_bien 
		
a) Consultas
1. Dado un id solicitud devolver la información de compra solicitud y al mismo tiempo los detalles
select * from compras.solicitud inner join compras.solicitud_deta
using(id_solicitud) where compras.id_solicitud=1



b) Procedimientos almacenados y mantenimiento
1.Imprimir los nombres de los jefes de área junto con el id y nombre del área.




2.Todos los inmuebles que han sido comprados por un precio mayor a mil y agruparlos por área




c) Funciones para cálculos
1.Una función que devuelva una lista de los bienes que fueron comprados a un determinado proveedor
resuelto
create or replace function listaBienes(idproveedor integer) RETURNS varchar
as $$
	BEGIN
		SELECT * FROM compras.bien WHERE almacen.proveedor inner join compras.bien
		using(id_proveedor) where almacen.proveedor=idproveedor;
	END;
$$ LANGUAGE 'plpgsql'


--Consulta
Mostrar qu� bienes entran y c�mo se reparten a las diferentes �reas del almac�n y el id del empleado que lleva a cabo dicha acci�n 
(Entrada, bien, mov_bien, empleado, responsable_centros_costo, area)


select * from inventario.mov_bien mb 
select * from compras.bien b 
select * from almacen.entrada e 

select b.id_bien, a.id_area, e2.nombres_emp  from almacen.entrada e 
inner join compras.bien b  on b.id_bien  = e.id_bien
inner join inventario.mov_bien mb  on mb.id_bien  = b.id_bien
inner join rrhh.empleado e2 on e2.id_emp = mb.id_emp 
inner join public."area" a on a.id_area = mb.id_area 

--Procedimiento almacenado
Mostrar el responsable y la fecha de cada una de las solicitudes. Adem�s, mostrar el nombre y monto del rubro presupuestal respectivo.

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


--Procedimiento de mantenimiento
Mantenimiento de la tabla proveedor
/*
 * INSERTAR PROVEEDOR
 */
select * from almacen.proveedor p 

create or replace procedure insert_proveedor(
	new_id_proveedor int, 
	new_nit varchar,
	new_domicilio varchar,
	new_razon_social varchar)
language plpgsql	
as $$
begin
	insert into almacen.proveedor(id_proveedor, NIT, domicilio, razon_social)
	values(new_id_proveedor,new_nit,new_domicilio,new_razon_social);
end;
$$;

call insert_proveedor();--Agregar parametros

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
call delete_proveedor(1);
select * from almacen.proveedor p;
select * from compras.orden_contractual;

drop procedure delete_proveedor;

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


--FUNCIONES PARA CALCULO

Funci�n que devuelve el promedio de la cantidad de los bienes,  de cada una de las �reas y su fecha de entrega. 


select avg(b.cantidad) promedio_cantidad, a.nombre_area , mb.fecha_entrega  from compras.bien b 
inner join inventario.mov_bien mb on mb.id_bien = b.id_bien 
inner join public."area" a on a.id_area = mb.id_area 
where b.id_bien = mb.id_bien and mb.id_area = a.id_area 
group by 2,3
order by 1,2,3;


CREATE or replace FUNCTION funcion_calculo ( id_area_param int ) RETURNS
TABLE( promedio_cantidad int4, nombre_area varchar , fecha_entrega date) AS
$$
select avg(b.cantidad) promedio_cantidad, a.nombre_area , mb.fecha_entrega  from compras.bien b 
inner join inventario.mov_bien mb on mb.id_bien = b.id_bien 
inner join public."area" a on a.id_area = mb.id_area 
where b.id_bien = mb.id_bien and mb.id_area = id_area_param 
group by 2,3
order by 1,2,3;
$$ LANGUAGE sql

select * from public."area"

select * from funcion_calculo(1);

--DETONADORES PARA EL CONTROL DE MODIFICACIONES
Creaci�n de una tabla log_proveedor que se llenar� con un detonador cuando se inserta, actualiza o elimina un registro.

select * from almacen.proveedor p 

CREATE TABLE almacen.log_proveedor /* Tabla LOG de clientes */
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
CREATE OR REPLACE FUNCTION almacen.tg_log_proveedor() RETURNS TRIGGER AS
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
CREATE TRIGGER tg_log_proveedor AFTER INSERT OR UPDATE OR DELETE
ON  almacen.proveedor FOR EACH ROW EXECUTE PROCEDURE almacen.tg_log_proveedor();

select * from almacen.proveedor p;
select * from compras.orden_contractual;

insert into almacen.Proveedor (id_proveedor, nit, domicilio, razon_social) values (1, 'f647d0e85c7f', '66 Rigney Place', 'CA-SK');
insert into almacen.Proveedor (id_proveedor, nit, domicilio, razon_social) values (2, '922011703bfa', '0 Milwaukee Junction', 'PG-WPD');

--REPORTES DE CURSORES SIMPLES
Reporte que muestre la fecha de salida, fecha de entrega y el id del empleado responsable de cada salida.

--Consulta inicial
select s.fecha_salida , s.fecha_entrega , e.nombres_emp  , s.empleado_responsable, s.id_salida  from almacen.salida s
inner join rrhh.empleado e on s.empleado_responsable = e.id_emp 
inner join public."area" a on a.id_area = e.id_area  
where e.id_emp = s.empleado_responsable and e.id_emp = a.id_area 
order by 1,2,3 asc


create or replace procedure cursor_siemple_uno()
as $$
declare
	rec record;
begin
	for rec in select s.fecha_salida , s.fecha_entrega , e.nombres_emp  , s.empleado_responsable, s.id_salida  from almacen.salida s
				inner join rrhh.empleado e on s.empleado_responsable = e.id_emp 
				inner join public."area" a on a.id_area = e.id_area  
				where e.id_emp = s.empleado_responsable and e.id_emp = a.id_area 
	loop 
	raise notice '% - % - % - % -%', rec.fecha_salida, rec.fecha_entrega, rec.nombres_emp, rec.empleado_responsable, rec.id_salida;
	end loop;
end;
$$language plpgsql

--REPORTES DE CURSORES ANIDADOS
Reporte que muestre el id, nombre y cargo del empleado seg�n el �rea que corresponda, en la cual se mostrar� el nombre de dicha �rea y su id.



 