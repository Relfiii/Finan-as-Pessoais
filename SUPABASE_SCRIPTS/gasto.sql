-- Criação da tabela categorias_gastos
CREATE TABLE IF NOT EXISTS public.categorias_gastos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome text NOT NULL
);

-- Criação da tabela de gastos
CREATE TABLE IF NOT EXISTS public.gastos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  valor numeric NOT NULL,
  categoria_id uuid REFERENCES public.categorias_gastos(id),
  descricao text,
  data timestamp with time zone NOT NULL DEFAULT now(),
  user_id uuid REFERENCES auth.users(id),
  recorrente boolean DEFAULT false,
  intervalo_meses integer
);

-- Criar índice para user_id
CREATE INDEX IF NOT EXISTS idx_gastos_user_id ON public.gastos(user_id);

-- Habilitar RLS
ALTER TABLE public.gastos ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança
CREATE POLICY "Gastos apenas do usuário" ON public.gastos
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Inserir gastos do próprio usuário" ON public.gastos
  FOR INSERT WITH CHECK (
    user_id = auth.uid() AND 
    (recorrente IS NOT TRUE OR (recorrente IS TRUE AND intervalo_meses IS NOT NULL))
  );

CREATE POLICY "Atualizar gastos do próprio usuário" ON public.gastos
  FOR UPDATE USING (user_id = auth.uid())
  WITH CHECK (
    user_id = auth.uid() AND 
    (recorrente IS NOT TRUE OR (recorrente IS TRUE AND intervalo_meses IS NOT NULL))
  );

CREATE POLICY "Deletar gastos do próprio usuário" ON public.gastos
  FOR DELETE USING (user_id = auth.uid());

-- Função para retornar total de gastos por período
create or replace function public.total_gastos_por_periodo(
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
    from public.gastos
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