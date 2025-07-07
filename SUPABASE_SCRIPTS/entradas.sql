-- Script para criar tabela de entradas (receitas) no Supabase
create table entradas (
  id uuid primary key default uuid_generate_v4(),
  descricao text not null,
  valor numeric not null,
  data date not null,
  created_at timestamp with time zone default timezone('utc', now())
);

-- Índice para busca rápida por data
grant all on table entradas to authenticated;
create index idx_entradas_data on entradas(data);
