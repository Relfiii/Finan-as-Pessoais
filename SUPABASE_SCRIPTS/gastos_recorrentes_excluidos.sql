-- Script para adicionar suporte a exclusões de gastos recorrentes por mês
-- Este script deve ser executado no Supabase para criar a tabela necessária

-- Criar tabela para armazenar gastos recorrentes excluídos por mês
CREATE TABLE IF NOT EXISTS public.gastos_recorrentes_excluidos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  gasto_original_id uuid NOT NULL REFERENCES public.gastos(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  ano integer NOT NULL,
  mes integer NOT NULL,
  data_exclusao timestamp with time zone DEFAULT now(),
  
  -- Garantir que não haja duplicatas para o mesmo gasto/ano/mês
  UNIQUE(gasto_original_id, ano, mes)
);

-- Criar índices para melhorar performance
CREATE INDEX IF NOT EXISTS idx_gastos_recorrentes_excluidos_user_id 
  ON public.gastos_recorrentes_excluidos(user_id);

CREATE INDEX IF NOT EXISTS idx_gastos_recorrentes_excluidos_gasto_id 
  ON public.gastos_recorrentes_excluidos(gasto_original_id);

CREATE INDEX IF NOT EXISTS idx_gastos_recorrentes_excluidos_ano_mes 
  ON public.gastos_recorrentes_excluidos(ano, mes);

-- Habilitar RLS (Row Level Security)
ALTER TABLE public.gastos_recorrentes_excluidos ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança
CREATE POLICY "Exclusões apenas do usuário" ON public.gastos_recorrentes_excluidos
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Inserir exclusões do próprio usuário" ON public.gastos_recorrentes_excluidos
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Deletar exclusões do próprio usuário" ON public.gastos_recorrentes_excluidos
  FOR DELETE USING (user_id = auth.uid());

-- Função para limpar exclusões órfãs (quando o gasto original é deletado)
-- Isso é feito automaticamente pelo ON DELETE CASCADE, mas é bom ter para limpeza manual
CREATE OR REPLACE FUNCTION public.limpar_exclusoes_orfas()
RETURNS void
LANGUAGE sql
AS $$
  DELETE FROM public.gastos_recorrentes_excluidos
  WHERE gasto_original_id NOT IN (SELECT id FROM public.gastos);
$$;

-- Comentários para documentação
COMMENT ON TABLE public.gastos_recorrentes_excluidos IS 
  'Armazena as exclusões de gastos recorrentes por mês específico. 
   Permite que um gasto recorrente seja excluído apenas de determinados meses.';

COMMENT ON COLUMN public.gastos_recorrentes_excluidos.gasto_original_id IS 
  'ID do gasto recorrente original na tabela gastos';

COMMENT ON COLUMN public.gastos_recorrentes_excluidos.ano IS 
  'Ano do mês em que o gasto foi excluído (ex: 2025)';

COMMENT ON COLUMN public.gastos_recorrentes_excluidos.mes IS 
  'Mês em que o gasto foi excluído (1-12)';

COMMENT ON COLUMN public.gastos_recorrentes_excluidos.data_exclusao IS 
  'Timestamp de quando a exclusão foi feita';
