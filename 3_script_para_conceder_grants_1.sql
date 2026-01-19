DECLARE
  V_DDL_SYNOM          VARCHAR2(200);
  V_DDL_GRANT          VARCHAR2(200);
  V_USER          VARCHAR2(30) := 'TARGET_USER';     -- Nome do usuário do sistema (genérico)
  V_SCHEMA        VARCHAR2(30) := 'TARGET_SCHEMA';          -- Schema principal do sistema (genérico)
  V_SCHEMA_AUDIT  VARCHAR2(30) := 'TARGET_SCHEMA_AUDIT';    -- Schema de auditoria do sistema (genérico)
BEGIN
  FOR C_OBJETO IN (    SELECT OWNER, OBJECT_NAME, OBJECT_TYPE
                    FROM ALL_OBJECTS
                    WHERE    OWNER IN (V_SCHEMA, V_SCHEMA_AUDIT) 
                    AND OBJECT_TYPE IN ('TABLE','SEQUENCE','VIEW') 
                    ORDER BY OBJECT_TYPE )
  LOOP
   begin
    CASE C_OBJETO.OBJECT_TYPE
      WHEN 'TABLE' THEN
        IF C_OBJETO.OWNER = V_SCHEMA_AUDIT THEN
          V_DDL_SYNOM := 'CREATE OR REPLACE SYNONYM ' || V_USER || '.' || C_OBJETO.OBJECT_NAME || ' FOR ' || C_OBJETO.OWNER || '.' || C_OBJETO.OBJECT_NAME;
          V_DDL_GRANT := 'GRANT SELECT,INSERT ON ' || C_OBJETO.OWNER || '.' || C_OBJETO.OBJECT_NAME || ' TO ' || V_USER;
        ELSE
          if c_objeto.object_name not like 'HT_%' then 
            V_DDL_SYNOM := 'CREATE OR REPLACE SYNONYM ' || V_USER || '.' || C_OBJETO.OBJECT_NAME || ' FOR ' || C_OBJETO.OWNER || '.' || C_OBJETO.OBJECT_NAME;
            V_DDL_GRANT := 'GRANT SELECT, INSERT, UPDATE, DELETE ON ' || C_OBJETO.OWNER || '.' || C_OBJETO.OBJECT_NAME || ' TO ' || V_USER;
          end if;
        END IF;
      WHEN 'SEQUENCE' THEN
        V_DDL_SYNOM := 'CREATE OR REPLACE SYNONYM ' || V_USER || '.' || C_OBJETO.OBJECT_NAME || ' FOR ' || C_OBJETO.OWNER || '.' || C_OBJETO.OBJECT_NAME;
        V_DDL_GRANT := 'GRANT SELECT ON ' || C_OBJETO.OWNER || '.' || C_OBJETO.OBJECT_NAME || ' TO ' || V_USER;
      WHEN 'VIEW' THEN
        V_DDL_SYNOM := 'CREATE OR REPLACE SYNONYM ' || V_USER || '.' || C_OBJETO.OBJECT_NAME || ' FOR ' || C_OBJETO.OWNER || '.' || C_OBJETO.OBJECT_NAME;
        V_DDL_GRANT := 'GRANT SELECT ON ' || C_OBJETO.OWNER || '.' || C_OBJETO.OBJECT_NAME || ' TO ' || V_USER;
	  WHEN 'FUNCTION' THEN
        V_DDL_SYNOM := 'CREATE OR REPLACE SYNONYM ' || V_USER || '.' || C_OBJETO.OBJECT_NAME || ' FOR ' || C_OBJETO.OWNER || '.' || C_OBJETO.OBJECT_NAME;
        V_DDL_GRANT := 'GRANT EXECUTE ON ' || C_OBJETO.OWNER || '.' || C_OBJETO.OBJECT_NAME || ' TO ' || V_USER;
	  WHEN 'PROCEDURE' THEN
        V_DDL_SYNOM := 'CREATE OR REPLACE SYNONYM ' || V_USER || '.' || C_OBJETO.OBJECT_NAME || ' FOR ' || C_OBJETO.OWNER || '.' || C_OBJETO.OBJECT_NAME;
        V_DDL_GRANT := 'GRANT EXECUTE ON ' || C_OBJETO.OWNER || '.' || C_OBJETO.OBJECT_NAME || ' TO ' || V_USER;
	  WHEN 'PACKAGE' THEN
        V_DDL_SYNOM := 'CREATE OR REPLACE SYNONYM ' || V_USER || '.' || C_OBJETO.OBJECT_NAME || ' FOR ' || C_OBJETO.OWNER || '.' || C_OBJETO.OBJECT_NAME;
        V_DDL_GRANT := 'GRANT EXECUTE ON ' || C_OBJETO.OWNER || '.' || C_OBJETO.OBJECT_NAME || ' TO ' || V_USER;
	 
    END CASE;

    -- Execução
    EXECUTE IMMEDIATE V_DDL_SYNOM;
    EXECUTE IMMEDIATE V_DDL_GRANT;
   exception
      when others then
        dbms_output.put_line('Erro ao executar '||V_DDL_SYNOM ||' =>>> '||sqlerrm);
        dbms_output.put_line('Erro ao executar '||V_DDL_GRANT ||' =>>> '||sqlerrm);
   end;     
  END LOOP;

END;