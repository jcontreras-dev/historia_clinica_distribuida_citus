-- Crear extensión Citus (solo en el coordinador)
CREATE EXTENSION IF NOT EXISTS citus;

-- ======================
-- TABLA USUARIO
-- ======================
CREATE TABLE IF NOT EXISTS usuario (
    documento_id BIGINT PRIMARY KEY,
    pais_nacionalidad VARCHAR(100),
    nombre_completo VARCHAR(255),
    fecha_nacimiento DATE,
    edad INT,
    sexo VARCHAR(10),
    genero VARCHAR(20),
    ocupacion VARCHAR(100),
    voluntad_anticipada BOOLEAN,
    categoria_discapacidad VARCHAR(50),
    pais_residencia VARCHAR(100),
    municipio_residencia VARCHAR(100),
    etnia VARCHAR(50),
    comunidad_etnica VARCHAR(100),
    zona_residencia VARCHAR(50)
);
SELECT create_distributed_table('usuario', 'documento_id');

-- ======================
-- TABLA ATENCION
-- ======================
CREATE TABLE IF NOT EXISTS atencion (
    atencion_id BIGSERIAL,
    documento_id BIGINT NOT NULL,
    entidad_salud VARCHAR(255),
    fecha_ingreso TIMESTAMP,
    modalidad_entrega VARCHAR(50),
    entorno_atencion VARCHAR(50),
    via_ingreso VARCHAR(50),
    causa_atencion TEXT,
    fecha_triage TIMESTAMP,
    clasificacion_triage VARCHAR(10),
    PRIMARY KEY (documento_id, atencion_id),
    CONSTRAINT fk_atencion_usuario
        FOREIGN KEY (documento_id)
        REFERENCES usuario(documento_id)
);
SELECT create_distributed_table('atencion', 'documento_id');

-- ======================
-- TABLA PROFESIONAL SALUD (REFERENCE)
-- ======================
CREATE TABLE IF NOT EXISTS profesional_salud (
    id_personal_salud UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(255),
    especialidad VARCHAR(100)
);
SELECT create_reference_table('profesional_salud');

-- ======================
-- TABLA TECNOLOGIA SALUD
-- ======================
CREATE TABLE IF NOT EXISTS tecnologia_salud (
    documento_id BIGINT NOT NULL,
    tecnologia_id UUID DEFAULT gen_random_uuid(),
    atencion_id BIGINT,
    descripcion_medicamento VARCHAR(255),
    dosis VARCHAR(50),
    via_administracion VARCHAR(50),
    frecuencia VARCHAR(50),
    dias_tratamiento INT,
    unidades_aplicadas INT,
    id_personal_salud UUID,
    finalidad_tecnologia VARCHAR(255),
    PRIMARY KEY (documento_id, tecnologia_id),
    CONSTRAINT fk_tecnologia_atencion
        FOREIGN KEY (documento_id, atencion_id)
        REFERENCES atencion(documento_id, atencion_id)
);
SELECT create_distributed_table('tecnologia_salud', 'documento_id');

-- ======================
-- TABLA DIAGNOSTICO
-- ======================
CREATE TABLE IF NOT EXISTS diagnostico (
    diagnostico_id BIGSERIAL,
    documento_id BIGINT NOT NULL,
    atencion_id BIGINT,
    tipo_diagnostico_ingreso VARCHAR(50),
    diagnostico_ingreso VARCHAR(255),
    tipo_diagnostico_egreso VARCHAR(50),
    diagnostico_egreso VARCHAR(255),
    diagnostico_rel1 VARCHAR(255),
    diagnostico_rel2 VARCHAR(255),
    diagnostico_rel3 VARCHAR(255),
    PRIMARY KEY (documento_id, diagnostico_id),
    CONSTRAINT fk_diagnostico_atencion
        FOREIGN KEY (documento_id, atencion_id)
        REFERENCES atencion(documento_id, atencion_id)
);
SELECT create_distributed_table('diagnostico', 'documento_id');

-- ======================
-- TABLA EGRESO
-- ======================
CREATE TABLE IF NOT EXISTS egreso (
    egreso_id BIGSERIAL,
    documento_id BIGINT NOT NULL,
    atencion_id BIGINT,
    fecha_salida TIMESTAMP,
    condicion_salida VARCHAR(100),
    diagnostico_muerte VARCHAR(255),
    codigo_prestador VARCHAR(20),
    tipo_incapacidad VARCHAR(100),
    dias_incapacidad INT,
    dias_lic_maternidad INT,
    alergias TEXT,
    antecedente_familiar TEXT,
    riesgos_ocupacionales TEXT,
    responsable_egreso VARCHAR(255),
    PRIMARY KEY (documento_id, egreso_id),
    CONSTRAINT fk_egreso_atencion
        FOREIGN KEY (documento_id, atencion_id)
        REFERENCES atencion(documento_id, atencion_id)
);
SELECT create_distributed_table('egreso', 'documento_id');