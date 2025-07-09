-- Função para excluir o usuário atual
CREATE OR REPLACE FUNCTION delete_current_user()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  DELETE FROM auth.users WHERE id = auth.uid();
END;
$$;

-- Permitir que apenas o próprio usuário execute
GRANT EXECUTE ON FUNCTION delete_current_user() TO authenticated;