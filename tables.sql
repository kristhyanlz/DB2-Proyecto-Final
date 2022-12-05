/*
Host:
ec2-34-230-153-41.compute-1.amazonaws.com

Database:
daf88jptjtitas

User:
vesvtvuzpjdlrk

Passwd:
84b8a4b4e048c06e1b1cfcf2245fb58fa74ac936d722d2744199ab0e8510847b
*/

create schema rrhh;
create schema compras;
CREATE SCHEMA almacen;
create schema inventario;

create table rrhh."area"(
	id_area serial not null primary key,
	nombre_area varchar(60),
	centro_costo varchar(30)
);

create table rrhh.empleado(
	id_emp serial not null primary key,
	nombres_emp varchar(100) not null,
	cedula varchar(30) not null unique,
	cargo varchar(30),
	id_area int not null references rrhh."area",
	id_jefe int references rrhh.empleado
);

create table rrhh.responsable_centros_costo(
	id_emp int not null references rrhh.empleado,
	id_area int not null references rrhh."area",
	primary key (id_emp, id_area)
);

CREATE TYPE compras.tipo_bien AS ENUM ('suministro', 'inmueble');

create table compras.bien(
	id_bien serial not null primary key,
	nombre_bien varchar(60),
	cantidad real,
	unidad_medida varchar(30),
	tipo compras.tipo_bien
);

create table almacen.Proveedor(
	id_proveedor serial not null primary key,
	NIT varchar(20) NOT NULL UNIQUE,
	domicilio varchar(60),
	razon_social varchar(30)
);

CREATE TABLE compras.rubro_presupuestal(
	id_rp serial NOT NULL PRIMARY KEY,
	nombre varchar(50),
	monto real,
	monto_disponible real check (monto_disponible <= monto)
);

CREATE TABLE compras.solicitud(
	id_solicitud serial NOT NULL PRIMARY KEY,
	fecha date NOT NULL,
	responsable int NOT null,-- REFERENCES rrhh.empleado,
	id_centro_costo int NOT null,-- REFERENCES rrhh."area",
	id_rp int NOT NULL REFERENCES compras.rubro_presupuestal,
	autorizacion_jefe_area int REFERENCES rrhh.empleado,
	autorizacion_director_financiero boolean DEFAULT false,
	
	foreign key (responsable, id_centro_costo) references rrhh.responsable_centros_costo
);

CREATE TABLE compras.solicitud_deta(
	id_solicitud int NOT NULL REFERENCES compras.solicitud,
	id_bien int NOT NULL REFERENCES compras.bien,
	cantidad REAL,
	valor_unitario REAL,
	PRIMARY KEY (id_solicitud, id_bien)
);

CREATE TABLE compras.orden_contractual(-- También llamado ORDEN DE COMPRA
	id_orden_c serial NOT NULL PRIMARY KEY,
	id_proveedor int not NULL REFERENCES almacen.Proveedor,
	autorizacion_director_financiero boolean DEFAULT FALSE,
	fecha_orden date DEFAULT now(),
	fecha_entrega date,
	numero_factura_proveedor varchar(20) null,
	
	via_de_envio varchar(30),
	metodo_de_envio varchar(30),
	condiciones_de_envio varchar(30),
	observaciones varchar(200)
);



CREATE TABLE compras.orden_contractual_deta(
	id_orden_cd serial not null primary key,
	id_orden_c int NOT NULL REFERENCES compras.orden_contractual,
	id_solicitud int NOT NULL,
	id_bien int NOT NULL,
	cantidad REAL,-- 
	valor_unitario REAL,-- El precio de la cotización puede ser diferente al de la solicitud
	-- En la entrega fisica, esta orden de compra se compara con la factura del proveedor
	FOREIGN KEY (id_solicitud, id_bien) REFERENCES compras.solicitud_deta
);

create table inventario.mov_bien(
	id_mov serial not null primary key,
	id_bien int NOT NULL REFERENCES compras.bien,
	id_emp int references rrhh.empleado,
	fecha_entrega date,
	id_area int references rrhh."area",
	cantidad real not null
);

--ALTER TABLE inventario.mov_bien ALTER COLUMN id_emp DROP NOT NULL;

create table almacen.entrada(
	id_entrada serial not null primary key,
	id_orden_cd int not null references compras.orden_contractual_deta,
	cantidad_entregada real not null,
	fecha_entrega timestamp not NULL DEFAULT now()
);	

create table almacen.salida(
	id_salida serial not null primary key,
	id_entrada int not null references almacen.entrada,
	empleado_responsable int not NULL REFERENCES rrhh.empleado,
	fecha_salida timestamp not null,
	fecha_entrega timestamp,
	id_area int references rrhh."area",
	cantidad real not null
);