-- Criação da tabela de entradas
CREATE TABLE IF NOT EXISTS entradas (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  descricao text NOT NULL,
  valor numeric NOT NULL,
  data date NOT NULL,
  created_at timestamp with time zone DEFAULT timezone('utc', now()),
  user_id uuid REFERENCES auth.users(id)
);

-- Criar índice para user_id
CREATE INDEX IF NOT EXISTS idx_entradas_user_id ON entradas(user_id);

-- Habilitar RLS
ALTER TABLE entradas ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança
CREATE POLICY "Entradas apenas do usuário" ON entradas
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Inserir entradas do próprio usuário" ON entradas
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Atualizar entradas do próprio usuário" ON entradas
  FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Deletar entradas do próprio usuário" ON entradas
  FOR DELETE USING (user_id = auth.uid());

create or replace function public.entradas_por_periodo(
  periodo text
)
returns table(
  label text,
  total numeric
)
language sql
as $$
  with base as (
    select
      case
        when periodo = 'Semana' then to_char(date_trunc('week', data), 'IW/YYYY')
        when periodo = 'Mês' then to_char(date_trunc('month', data), 'MM/YYYY')
        when periodo = 'Ano' then to_char(date_trunc('year', data), 'YYYY')
      end as label,
      valor
    from public.entradas
    where user_id = auth.uid()
      and (
        (periodo = 'Semana' and data >= date_trunc('week', now()) - interval '3 week')
        or (periodo = 'Mês' and data >= date_trunc('month', now()) - interval '5 month')
        or (periodo = 'Ano' and data >= date_trunc('year', now()) - interval '4 year')
      )
  )
  select label, sum(valor) as total
  from base
  group by label
  order by label;
$$;