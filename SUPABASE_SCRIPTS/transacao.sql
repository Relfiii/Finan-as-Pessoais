-- Criação da tabela categorias
CREATE TABLE IF NOT EXISTS public.categorias (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome text NOT NULL
);

-- Criação da tabela transacoes
CREATE TABLE IF NOT EXISTS public.transacoes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  valor numeric NOT NULL,
  tipo text NOT NULL CHECK (tipo IN ('gasto', 'investimento', 'receita')),
  categoria_id uuid REFERENCES public.categorias(id),
  descricao text,
  data timestamp with time zone NOT NULL DEFAULT now(),
  user_id uuid REFERENCES auth.users(id)
);

-- Criar índice para user_id
CREATE INDEX IF NOT EXISTS idx_transacoes_user_id ON public.transacoes(user_id);

-- Habilitar RLS
ALTER TABLE public.transacoes ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança
CREATE POLICY "Transações apenas do usuário" ON public.transacoes
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Inserir transações do próprio usuário" ON public.transacoes
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Atualizar transações do próprio usuário" ON public.transacoes
  FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Deletar transações do próprio usuário" ON public.transacoes
  FOR DELETE USING (user_id = auth.uid());