CREATE DATABASE AppVirtual; 

USE AppVirtual;

CREATE TABLE usuarios (
	IdUsuario INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Apellido VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL UNIQUE,
	FotoPerfil LONGTEXT DEFAULT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    FechaRegistro DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE plagas (
    id_plaga INT AUTO_INCREMENT PRIMARY KEY,
    nombre_comun VARCHAR(100) NOT NULL, -- Ej: Pulgón, Roya
    nombre_cientifico VARCHAR(150),
    descripcion TEXT,
    sintomas TEXT
);

CREATE TABLE cultivos (
    id_cultivo INT AUTO_INCREMENT PRIMARY KEY,
    idPlaga INT NOT NULL,
    nombre VARCHAR(100) NOT NULL, -- Ej: Maíz, Café
    variedad VARCHAR(100),
    ubicacion VARCHAR(255), -- ej. finca, parcela
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (idPlaga) REFERENCES plagas(id_plaga)
);

CREATE TABLE incidencias (
    id_incidencia INT AUTO_INCREMENT PRIMARY KEY,
    id_cultivo INT NOT NULL,
    id_plaga INT,
    fecha_incidencia DATE NOT NULL,
    foto VARCHAR(255), -- ruta de la imagen tomada por el agricultor
    diagnostico VARCHAR(255), -- IA o técnico
    estado ENUM('pendiente', 'en control', 'resuelto') DEFAULT 'pendiente',
    FOREIGN KEY (id_cultivo) REFERENCES cultivos(id_cultivo),
    FOREIGN KEY (id_plaga) REFERENCES plagas(id_plaga)
);

INSERT INTO plagas (nombre_comun, nombre_cientifico, descripcion, sintomas)
VALUES
('Pulgón', 'Aphis gossypii', 'Pequeños insectos que se alimentan de la savia de las plantas, debilitándolas.', 'Hojas enrolladas, amarillentas y presencia de melaza.'),
('Roya del café', 'Hemileia vastatrix', 'Hongo que afecta las hojas del cafeto, reduciendo la fotosíntesis.', 'Manchas anaranjadas en el envés de las hojas.'),
('Mosca blanca', 'Bemisia tabaci', 'Insecto chupador que transmite virus y debilita las plantas.', 'Hojas con puntos amarillos y sustancia pegajosa.'),
('Gusano cogollero', 'Spodoptera frugiperda', 'Larva que daña el cogollo del maíz y otras gramíneas.', 'Agujeros en hojas y destrucción del brote central.'),
('Trips', 'Frankliniella occidentalis', 'Insectos diminutos que raspan hojas y flores.', 'Manchas plateadas y deformaciones en flores.'),
('Araña roja', 'Tetranychus urticae', 'Ácaro que succiona la savia, causando daño en hojas.', 'Hojas con puntos amarillos y telarañas finas.'),
('Minador de hoja', 'Liriomyza trifolii', 'Larva que excava galerías dentro de las hojas.', 'Hojas con líneas o túneles blanquecinos.'),
('Chinche verde', 'Nezara viridula', 'Insecto que succiona los frutos y semillas.', 'Frutos deformes o con manchas negras.'),
('Picudo del plátano', 'Cosmopolites sordidus', 'Escarabajo que daña el rizoma del plátano.', 'Marchitez y caída de la planta.'),
('Barrenador del tallo', 'Diatraea saccharalis', 'Larva que penetra tallos de caña o maíz.', 'Tallos perforados y debilitados.'),
('Nematodo del tomate', 'Meloidogyne incognita', 'Gusano microscópico que afecta raíces.', 'Raíces engrosadas y plantas marchitas.'),
('Mosca de la fruta', 'Ceratitis capitata', 'Insecto que pone huevos en frutos maduros.', 'Frutos podridos con larvas dentro.');

INSERT INTO cultivos (idPlaga, nombre, variedad, ubicacion)
VALUES
(4, 'Maíz', 'Híbrido amarillo', 'Chinandega, finca San José'),
(2, 'Café', 'Caturra', 'Matagalpa, finca La Esperanza'),
(3, 'Tomate', 'Roma', 'León, parcela Los Pinos'),
(1, 'Frijol', 'Rojo seda', 'Estelí, finca El Progreso'),
(5, 'Plátano', 'Cuadrado', 'Rivas, plantación Santa Rosa'),
(6, 'Caña de azúcar', 'CP72-2086', 'Chichigalpa, ingenio San Antonio'),
(3, 'Pepino', 'Marketmore 76', 'Masaya, huerto comunitario'),
(5, 'Rosa', 'Rosal rojo intenso', 'Jinotega, vivero Flores del Norte'),
(2, 'Naranja', 'Valencia', 'Boaco, plantación El Sol'),
(1, 'Algodón', 'Delta Pine', 'Chinandega, hacienda La Palma'),
(4, 'Sorgo', 'Pioneer 84G62', 'Somoto, finca El Rosario'),
(3, 'Chiltoma', 'California Wonder', 'Managua, parcela El Porvenir');


