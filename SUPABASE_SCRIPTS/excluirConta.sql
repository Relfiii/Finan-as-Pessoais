create or replace function delete_current_user()
returns void
language plpgsql
security definer
as $$
begin
  delete from auth.users where id = auth.uid();
end;
$$;

-- Permitir que apenas o próprio usuário execute
grant execute on function delete_current_user() to authenticated;