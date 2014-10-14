﻿--
-- Exercício 1
--
ALTER TABLE medico DROP CONSTRAINT medico_pkey CASCADE;
ALTER TABLE medico ADD PRIMARY KEY (id_medico,crm);
ALTER TABLE medico ALTER crm SET NOT NULL;
--
-- Exercício 2
--
ALTER TABLE consulta ADD PRIMARY KEY (id_paciente,id_medico,data_consulta);
--
-- Exercício 3
--
ALTER TABLE paciente ADD CHECK (data_nascimento > '01/01/1990');
--
-- Exercício 4
--
CREATE TABLE paciente_convenio
(
  id_convenio integer NOT NULL,
  id_paciente integer NOT NULL,
  CONSTRAINT paciente_convenio_pkey PRIMARY KEY (id_convenio, id_paciente),
  CONSTRAINT paciente_convenio_id_convenio_fkey FOREIGN KEY (id_convenio)
      REFERENCES convenio (id_convenio),
  CONSTRAINT paciente_convenio_id_paciente_fkey FOREIGN KEY (id_paciente)
      REFERENCES paciente (id_paciente)
);
--
-- Exercício 5.a
--
SELECT *
FROM   paciente
WHERE  data_nascimento BETWEEN '01/01/1980' and '31/12/1989';
--
-- Exercício 5.b
--
SELECT m.nome,
       c.descricao
FROM   medico   m,
       convenio c,
       medico_convenio mc
WHERE  mc.id_medico   = m.id_medico  AND
       mc.id_convenio = c.id_convenio;
--
-- Exercício 5.c
--

--
-- Exercício 5.d
--
SELECT *
FROM medico
WHERE id_medico NOT IN ( SELECT id_medico
                         FROM   medico_convenio);
--
-- Exercício 5.e
--
SELECT id_convenio, count(1)
FROM medico_convenio mc
GROUP BY mc.id_convenio;
--
-- Exercício 5.f
--
SELECT *
FROM medico
WHERE id_medico NOT IN ( SELECT id_medico
                         FROM   consulta );
--
-- Exercício 5.g
--
DELETE FROM consulta
WHERE id_medico IN ( SELECT m.id_medico 
                     FROM   medico m,
                            medico_convenio mc,
                            convenio c 
                     WHERE  c.descricao = 'CASSI' 
                       AND  m.id_medico = mc.id_medico
                       AND  mc.id_convenio = c.id_convenio
                     GROUP  BY m.id_medico
                    );
--
-- Exercício 5.h
--
UPDATE paciente_convenio SET id_convenio = ( SELECT id_convenio 
                                             FROM   convenio 
                                             WHERE  descricao = 'CASSI'
                                           )
WHERE id_paciente in ( SELECT id_paciente
                       FROM   paciente
		       WHERE  data_nascimento BETWEEN '01/01/1980' AND '31/12/1989'
		     );

UPDATE paciente_convenio SET id_convenio = ( SELECT id_convenio 
                                             FROM   convenio 
                                             WHERE  descricao = 'Unimed Campinas'
                                           )
WHERE id_paciente in ( SELECT id_paciente
                       FROM   paciente
		       WHERE  data_nascimento BETWEEN '01/01/1990' AND '31/12/1999'
		     );

UPDATE paciente_convenio SET id_convenio = ( SELECT id_convenio 
                                             FROM   convenio 
                                             WHERE  descricao = 'Bradesco'
                                           )
WHERE id_paciente in ( SELECT id_paciente
                       FROM   paciente
		       WHERE  data_nascimento >= '01/01/2000'
		     );
--
-- Exercício 5.i
--
CREATE OR REPLACE FUNCTION AtendeMaisDeUm(medico int) RETURNS varchar AS $$
DECLARE
	quantidade_medico int;
BEGIN
	SELECT count(1)
	INTO   quantidade_medico
	FROM   medico_convenio
	WHERE  id_medico = medico;
	IF (quantidade_medico > 1) THEN
		RETURN 'Médico atende mais de um convênio';
	END IF;
	return '';
END;
$$LANGUAGE plpgsql;

