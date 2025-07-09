-- Criação da tabela usuarios vinculada ao auth.users
create table public.usuarios (
  id uuid primary key references auth.users(id),
  nome text,
  email text,
  apelido text
);

-- 2. Cria a extensão para usar bcrypt (pgcrypto)
create extension if not exists pgcrypto;

-- 3. Função para criptografar a senha
create or replace function public.criptografar_senha()
returns trigger as $$
begin
  if NEW.senha is not null and NEW.senha != OLD.senha then
    NEW.senha := crypt(NEW.senha, gen_salt('bf'));
  end if;
  return NEW;
end;
$$ language plpgsql;

-- 4. Trigger para criptografar a senha ao inserir ou atualizar
drop trigger if exists trigger_criptografar_senha on public.usuarios;
create trigger trigger_criptografar_senha
before insert or update of senha
on public.usuarios
for each row
execute function public.criptografar_senha();

drop trigger if exists trigger_criptografar_senha on public.usuarios;
drop function if exists public.criptografar_senha();

create or replace function public.criptografar_senha()
returns trigger as $$
begin
  if NEW.senha is not null and (TG_OP = 'INSERT' or NEW.senha != OLD.senha) then
    NEW.senha := crypt(NEW.senha, gen_salt('bf'));
  end if;
  return NEW;
end;
$$ language plpgsql;

create trigger trigger_criptografar_senha
before insert or update of senha
on public.usuarios
for each row
execute function public.criptografar_senha();

ALTER TABLE public.gastos
ADD COLUMN user_id uuid references auth.users(id);

CREATE INDEX idx_gastos_user_id ON public.gastos(user_id);