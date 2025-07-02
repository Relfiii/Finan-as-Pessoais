--Execute este script SQL no painel do Supabase (SQL Editor) para criar a tabela transacoes:
create table public.transacoes (
  id uuid primary key default gen_random_uuid(),
  valor numeric not null,
  tipo text not null check (tipo in ('gasto', 'investimento', 'receita')),
  categoria_id uuid,
  descricao text,
  data timestamp with time zone not null default now()
);

--Se quiser relacionar com uma tabela de categorias, crie também:
create table public.categorias (
  id uuid primary key default gen_random_uuid(),
  nome text not null
);

--E adicione a chave estrangeira na tabela de transações:
alter table public.transacoes
  add constraint fk_categoria
  foreign key (categoria_id) references public.categorias (id);

-- Substitua os valores conforme necessário ao executar
insert into public.categorias (id, nome)
values (gen_random_uuid(), 'Nome da Categoria Exemplo');