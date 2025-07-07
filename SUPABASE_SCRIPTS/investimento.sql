-- Script para criar tabela de investimentos no Supabase
create table investimentos (
  id uuid primary key default uuid_generate_v4(),
  descricao text not null,
  valor numeric not null,
  data date not null,
  tipo text not null default 'Outro',
  tipo_outro text,
  created_at timestamp with time zone default timezone('utc', now())
);

-- Permissões para usuários autenticados
grant all on table investimentos to authenticated;

-- Índice para busca rápida por data
create index idx_investimentos_data on investimentos(data);

-- Índice para busca por tipo de investimento
create index idx_investimentos_tipo on investimentos(tipo);