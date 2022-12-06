-- ## TRIGGERS QUE CONTROLAN LA INSERCIÓN CORRECTA ## 
create or replace FUNCTION trigger_insert_rubro_presupuestal_montos() 
   RETURNS TRIGGER 
   LANGUAGE PLPGSQL
AS $$
BEGIN
  new.monto_disponible := new.monto;
  return new;
END;
$$;

CREATE TRIGGER igualar_montos
  BEFORE insert
  ON compras.rubro_presupuestal
  FOR EACH ROW
  EXECUTE PROCEDURE trigger_insert_rubro_presupuestal_montos();
-------------------------------------
 
 
create or replace FUNCTION trigger_contrato_deta_validados() 
   RETURNS TRIGGER 
   LANGUAGE PLPGSQL
AS $$
declare
	rec record;
BEGIN
	select * into rec
	from compras.solicitud s
	where s.id_solicitud = new.id_solicitud;

	raise notice '%', rec.autorizacion_director_financiero;

	if rec.autorizacion_director_financiero = false then
		return null;
	end if;

	return new;
END;
$$;

CREATE TRIGGER aceptar_contratos_deta_validados
  BEFORE insert
  ON compras.orden_contractual_deta
  FOR EACH ROW
  EXECUTE PROCEDURE trigger_contrato_deta_validados();
--------------------------------
 
 
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

 
 
-----------------
 
 
create or replace FUNCTION trigger_check_cant_salida() 
   RETURNS TRIGGER 
   LANGUAGE PLPGSQL
AS $$
declare
rec record;
begin
	select * into rec
		from almacen.entrada e
		where e.id_entrada = new.id_entrada;
	
	if rec.cantidad_entregada < new.cantidad then
		return null;
	end if;
	
	return new;
END;
$$;

CREATE TRIGGER cant_sal_menor_ent
  BEFORE insert
  ON almacen.salida
  FOR EACH ROW
  EXECUTE PROCEDURE trigger_check_cant_salida();
 
 
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
