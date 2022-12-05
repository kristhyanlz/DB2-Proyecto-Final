INSERT INTO rrhh."area"
VALUES 
	(default, 'rrhh', '001'),
	(default,'almacen', '002'),
	(default,'gerencia', '003'),
	(default,'contabilidad', '004'),
	(default,'logistica', '005-00');

--truncate table rrhh.empleado cascade;
--ALTER SEQUENCE rrhh.empleado_id_emp_seq RESTART WITH 1;

--SELECT currval('rrhh.empleado_id_emp_seq');


INSERT INTO rrhh.empleado
VALUES 
	(default, 'Sharla Bahia', '4905298486597063', 'Jefe de area', 1),
	(default, 'Violet Redpath', '3542593476785400', 'Jefe de area', 2),
	(default, 'Ludovika Louca', '3570809275677019', 'Jefe de area', 3),
	(default, 'Flossy Wille', '201601177995927', 'Jefe de area', 4),
	(default, 'Hali Riguard', '374622580654761', 'Jefe de area', 5),
	(default, 'Merla Stanlake', '4742926414379', 'Director Financiero', 4);

insert into rrhh.empleado
values
	(default, 'Mattie Raymen', '3570218952741751', 'Design Engineer', 1, 3),
	(default, 'Lemuel Kilmurry', '3529327268226076', 'Data Coordiator', 5, 4),
	(default, 'Felike MacCarter', '3536914418824974', 'Help Desk Technician', 3, 4),
	(default, 'Phedra Estable', '3545144722441526', 'Product Engineer', 1, 6),
	(default, 'Kat Redwing', '4913609005629387', 'Assistant Professor', 5, 2),
	(default, 'Jonell Flaunders', '3537596952515701', 'Junior Executive', 1, 3),
	(default, 'Philipa Falcus', '344826924479796', 'Technical Writer', 5, 6),
	(default, 'Brady Boyer', '630449551732540666', 'Account Coordinator', 2, 2),
	(default, 'Genovera Emberson', '5576650540227217', 'Senior Cost Accountant', 5, 5),
	(default, 'Leeland Dann', '4017950142824407', 'Financial Analyst', 2, 3),
	(default, 'Sibyl Geater', '5048379381025395', 'Financial Advisor', 3, 4),
	(default, 'Daisy Chiplen', '5602225342961604165', 'Electrical Engineer', 5, 2),
	(default, 'Garrek Leppington', '56022119901101273', 'Cost Accountant', 5, 3),
	(default, 'Bernelle Einchcombe', '5002350383824600', 'Recruiting Manager', 1, 5);

do
$$
declare
i int;
begin
	i := 0;
	loop
		update rrhh.empleado
		set id_jefe = i
		where id_emp = i;
	i := i + 1;
	exit when i > 5;	
	end loop;
end;
$$ language plpgsql;



update rrhh.empleado
	set id_jefe = 4
	where id_emp = 6;

	
insert into rrhh.responsable_centros_costo
values
	(1, 5),
	(2, 5),
	(3, 1),
	(4, 4),
	(5, 5),
	(6, 3),
	(7, 4),
	(8, 5),
	(9, 1),
	(10, 4),
	(11, 1),
	(12, 5),
	(13, 2),
	(14, 3),
	(15, 2),
	(16, 3),
	(17, 5),
	(18, 3),
	(19, 2),
	(20, 2);

--truncate table compras.bien cascade;
--ALTER SEQUENCE compras.bien_id_bien_seq RESTART WITH 1;

INSERT INTO compras.bien
VALUES 
	(default,'mesa', 20,'unidad','suministro'),
	(default,'silla', 30,'unidad','suministro'),
	(default,'librero', 10,'unidad','suministro'),
	(default,'laptops', 50,'unidad','suministro'),
	(default, 'Beef - Tenderlion, Center Cut', 11, 'decenas', 'suministro'),
	(default, 'Pork - Bacon,back Peameal', 6, 'decenas', 'suministro'),
	(default, 'St. Paulin', 10, 'decenas', 'inmueble'),
	(default, 'Cheese - Cream Cheese', 22, 'decenas', 'suministro'),
	(default, 'Local nuevo', 17, 'decenas', 'inmueble'),
	(default, 'Complejo de mini departamentos', 11, 'decenas', 'inmueble'),
	(default, 'Sucurzal en provincia', 28, 'decenas', 'inmueble'),
	(default, 'Chips - Miss Vickies', 3, 'unidad', 'suministro'),
	(default, 'Bread - 10 Grain Parisian', 3, 'decenas', 'suministro'),
	(default, 'Catfish - Fillets', 20, 'unidad', 'suministro'),
	(default, 'Veal - Provimi Inside', 8, 'decenas', 'suministro'),
	(default, 'Wine - Rioja Campo Viejo', 5, 'decenas', 'suministro'),
	(default, 'Appetizer - Shrimp Puff', 2, 'unidad', 'suministro'),
	(default, 'Cucumber - English', 11, 'unidad', 'suministro'),
	(default, 'Mousse - Passion Fruit', 2, 'decenas', 'suministro'),
	(default, 'Wine - Masi Valpolocell', 10, 'decenas', 'suministro'),
	(default, 'Sauce - White, Mix', 17, 'kilos', 'suministro'),
	(default, 'Chicken - Wings, Tip Off', 16, 'unidad', 'suministro'),
	(default, 'Wine - White, Pelee Island', 15, 'decenas', 'suministro'),
	(default, 'Soy Protein', 15, 'kilos', 'suministro');

	
insert into almacen.proveedor 
values 
	(default, '42-6727542', '1590 Helena Pass', 'Jabberbean'),
	(default, '40-1242906', '202 Ruskin Circle', 'Kaymbo'),
	(default, '84-9387926', '5501 Randy Alley', 'Linkbuzz'),
	(default, '91-3510049', '8762 Lake View Circle', 'Shuffledrive'),
	(default, '44-4264695', '18903 Hovde Road', 'Skinix'),
	(default, '22-5126717', '879 Becker Terrace', 'Twitterworks'),
	(default, '65-0541318', '217 Fuller Circle', 'Dabtype'),
	(default, '32-4953746', '9 Mayfield Avenue', 'Tanoodle'),
	(default, '44-7683825', '82037 Ridgeview Court', 'Leexo'),
	(default, '21-1243365', '89289 Ridge Oak Point', 'Meevee');



insert into compras.rubro_presupuestal
values
	(default, 'compra inmuebles', 6000000),
	(default, 'viveres', 7000),
	(default, 'moviliario', 9000),
	(default, 'varios', 3000);
--ALTER SEQUENCE compras.rubro_presupuestal_id_rp_seq RESTART WITH 5;

--select * from now();

insert into compras.solicitud
values
	(default, '2021-06-25', 1, 5, 3, 3, true),
	(default, '2021-08-06', 2, 5, 3, 1, true),
	(default, '2021-02-21', 3, 1, 2, 1, true),
	(default, '2021-09-22', 4, 4, 4, 2, false),
	(default, '2021-09-25', 5, 5, 2, 3, true),
	(default, '2021-06-25', 6, 3, 2, 3, false),
	(default, '2021-03-13', 7, 4, 1, 3, true),
	(default, '2021-11-16', 8, 5, 1, 2, true),
	(default, '2021-11-13', 9, 1, 4, 2, true),
	(default, '2021-07-01', 10, 4, 4, 4, true),
	(default, '2021-04-01', 10, 4, 1, 1, true),
	(default, '2021-03-09', 2, 5, 1, 4, true),
	(default, '2021-04-01', 4, 4, 1, 4, true),
	(default, '2021-03-05', 6, 3, 4, 2, true),
	(default, '2021-06-09', 7, 4, 3, 1, true),
	(default, '2021-12-13', 10, 4, 1, 4, true),
	(default, '2021-12-15', 4, 4, 3, 1, true),
	(default, '2021-09-30', 7, 4, 3, 1, true),
	(default, '2021-06-24', 2, 5, 1, 4, true),
	(default, '2021-07-24', 3, 1, 2, 2, false);


insert into compras.solicitud_deta
values
	(6, 6, 12, 813.36),
	(7, 23, 1, 574.5),
	(16, 11, 9, 314.0),
	(16, 22, 6, 501.51),
	(8, 3, 5, 994.97),
	(18, 18, 1, 894.98),
	(14, 6, 1, 283.78),
	(2, 8, 14, 423.36),
	(9, 21, 11, 717.39),
	(8, 22, 11, 813.92),
	(11, 9, 12, 853.17),
	(4, 23, 10, 575.81),
	(15, 17, 4, 17.67),
	(18, 6, 7, 218.7),
	(5, 2, 5, 841.77),
	(9, 22, 2, 693.55),
	(12, 4, 6, 253.0),
	(9, 23, 8, 625.64),
	(9, 7, 5, 764.06),
	(16, 24, 9, 163.18);
	
insert into compras.orden_contractual
values
	(default, 2, true, '2021-09-19', null, '5565254560087495', 'terrestre', 'convencional', 'gratis', null),
	(default, 8, false, '2021-05-08', now(), '3584149376198761', 'terrestre', 'convencional', 'gratis', null),
	(default, 6, true, '2021-10-05', null, '3586909971511413', 'aereo', 'convencional', 'gratis', null),
	(default, 1, true, '2021-12-10', null, '5048373805389321', 'terrestre', 'convencional', 'gratis', null),
	(default, 4, false, '2021-01-23', now(), '3577311207217991', 'aereo', 'convencional', 'gratis', null),
	(default, 7, true, '2022-01-01', now(), '3570780311717160', 'aereo', 'convencional', 'gratis', null),
	(default, 2, false, '2022-01-07', null, '3575576896163779', 'aereo', 'convencional', 'gratis', null),
	(default, 1, true, '2022-07-28', null, '3551537146239221', 'aereo', 'convencional', 'gratis', null),
	(default, 10, false, '2022-11-05', null, '5581980016664806', 'aereo', 'convencional', 'gratis', null),
	(default, 2, false, '2022-07-24', now(), '3547714510523483', 'aereo', 'convencional', 'gratis', null),
	(default, 3, false, '2021-09-06', null, '5100170997710081', 'terrestre', 'convencional', 'gratis', null),
	(default, 8, false, '2021-01-07', null, '3582516875277555', 'aereo', 'convencional', 'gratis', null),
	(default, 6, true, '2021-05-08', now(), '560225406755193480', 'terrestre', 'convencional', 'gratis', null),
	(default, 9, false, '2021-03-19', null, '3558111576531110', 'terrestre', 'convencional', 'gratis', null),
	(default, 10, false, '2021-12-19', now(), '5602214266338365', 'aereo', 'convencional', 'gratis', null);


insert into compras.orden_contractual_deta
values
	(default, 1, 4, 23, 12, 230.50),
	(default, 2, 2, 8,  65, 120.70),
	(default, 3, 5, 2, 3, 18.60),
	(default, 3, 7, 23, 8, 23.60),
	(default, 5, 8, 3, 1, 18.0),
	(default, 4, 8, 22, 1, 47.70),
	(default, 6, 9, 21, 23, 128.25);
	

 
insert into almacen.entrada
values
	(default, 2, 65, default),
	(default, 3, 3, default),
	(default, 4, 8, default),
	(default, 5, 1, default),
	(default, 6, 1, default),
	(default, 7, 23, default);


  
 insert into almacen.salida 
 values
	(default, 1, 5, now(), now(), 5, 20),
	(default, 3, 7, now(), now(), 4, 2),
	(default, 1, 1, now(), now(), 4, 15),
	(default, 4, 3, now(), now(), 4, 1),
	(default, 1, 8, now(), now(), 3, 2),
	(default, 4, 17, now(), now(), 3,99999);